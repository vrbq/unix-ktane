#!/bin/bash

# Fichier contenant la liste des mini-jeux
mini_games_list="mini_games_list"

# Fichier qui contient le temps restant
time_file="time"

# Fichier qui contient le statut des erreurs
error_status_file="error_status"
total_errors=0
max_errors=3  # Nombre maximum d'erreurs avant la perte de la partie

# Déclaration d'un tableau pour stocker l'état actuel des erreurs dans chaque module
declare -A previous_error_values

# Fonction pour mettre à jour le fichier error_status
update_error_status() {
    local current_total_errors=$1
    echo "$current_total_errors / $max_errors" > "$error_status_file"
}

stop_the_bomb() {

        echo "BOOM, DOMMAGE !" > .stop_counter
    
        # Stocker le contenu du fichier modules_list dans une variable
        modules=$(cat modules_list)

        
        # Boucle à travers chaque module
        for module in $modules; do
            module_ok_file="./modules/$module/.module_OK"
            can_go_file="./modules/$module/.can_go"
            error_file="./modules/$module/.error"
            
            if [ -f "$module_ok_file" ]; then
                # Suppression de .module_OK
                rm "$module_ok_file"
            fi
            
            if [ -f "$can_go_file" ]; then
                # Suppression de .can_go
                rm "$can_go_file"
            fi

            if [ -f "$error_file" ]; then
                # Suppression de .can_go
                rm "$error_file"
            fi
        done

        # Vérifier s'il y a un processus check_bomb_status en cours et l'arrêter
        if [ -f .check_status_pid ]; then
            old_pid_check=$(cat .check_status_pid)
            
            # Vérifier si le PID correspond toujours à un processus actif
            if ps -p $old_pid_check > /dev/null; then
                # echo "Arrêt du processus check_bomb_status en cours (PID: $old_pid)"
                kill $old_pid_check
                rm .check_status_pid
            else
                # echo "Le processus check_bomb_status avec PID $old_pid_check n'est plus actif."
                rm .check_status_pid
            fi
        else
            # Si le fichier .check_status_pid n'existe pas, utiliser ps aux pour rechercher check_bomb_status.sh
            echo "Le fichier .check_status_pid est introuvable, recherche du processus check_bomb_status..."

            # Utiliser ps aux pour trouver le processus countdown.sh
            check_status_pid=$(ps aux | grep '[c]heck_bomb_status.sh' | awk '{print $2}')
            countdown_pid=$(ps aux | grep '[c]ountdown.sh' | awk '{print $2}')

            if [ -n "$check_status_pid" ]; then
                # echo "Arrêt du processus check_bomb_status trouvé (PID: $check_status_pid)"
                kill $check_status_pid
                kil  $countdown_pid	
            fi
        fi

        exit 0
        break
}

check_errors_in_modules() {
    if [ -f modules_list ]; then
        modules=$(cat modules_list)
        for module in $modules; do
            error_file="./modules/$module/.error"

            if [ -f "$error_file" ]; then
                current_error_value=$(cat "$error_file")
            else
                current_error_value=0
            fi

            # Vérifier si la valeur de l'erreur a changé par rapport à la précédente
            previous_error_value=${previous_error_values[$module]:-0}

            if [[ $current_error_value -ne $previous_error_value ]]; then
                # Calculer la différence pour ajuster le total des erreurs
                error_difference=$((current_error_value - previous_error_value))
                total_errors=$((total_errors + error_difference))
                
                # Mettre à jour l'état des erreurs précédentes pour ce module
                previous_error_values["$module"]=$current_error_value

                # Mettre à jour le fichier error_status
                update_error_status "$total_errors"

                echo "Vous avez fait une erreur dans le module $module. Total des erreurs : $total_errors sur $max_errors possible !" 

                # Si le nombre total d'erreurs dépasse le maximum, la partie est perdue
                if [[ $total_errors -ge $max_errors ]]; then
                    echo "Vous avez atteint le nombre maximum d'erreurs. Partie perdue."
                    echo "Dommage, il vous restait encore $(cat $time_file) pour désamorcer la bombe."
                    stop_the_bomb
                    exit 1
                fi
            fi
        done
    fi
}




# Vérifier si la bombe est désamorcée
check_bomb_disarmed() {
    all_modules_ok=true
    while IFS= read -r module_name; do
        module_ok="./modules/$module_name/.module_OK"
        if [ ! -f "$module_ok" ]; then
            all_modules_ok=false
            break
        fi
    done < "$mini_games_list"

    echo "$all_modules_ok"
}

# Appel initial pour créer le fichier error_status avec "0/3"
update_error_status $total_errors


# Boucle pour vérifier le statut toutes les secondes
while true; do
    if [ ! -f ".countdown_in_progress" ] && [ ! -f ".countdown_expired" ]; then
        # echo "La bombe n'a pas encore été lancée."
        exit 1
        break
    fi

    # Parcourir chaque module et vérifier le fichier .error
    check_errors_in_modules


    # Vérifier si le compte à rebours a expiré
    if [ -f ".countdown_expired" ]; then
        echo "Le compte à rebours est terminé, mais la bombe n'a pas été désamorcée." &
        rm -f mini_games_list 

        stop_the_bomb
    fi

    # Vérifier si tous les modules sont désamorcés
    if [ "$(check_bomb_disarmed)" = "true" ]; then
        # Lire le temps restant
        if [ -f "$time_file" ]; then
            time_remaining=$(cat "$time_file")
        else
            time_remaining="Temps non disponible"
        fi
        echo "Bravo, vous avez désamorcé la bombe avec $time_remaining restant et $total_errors erreurs !" &
        echo "PAS BOOM, BRAVO !" > .stop_counter
        # Supprimer les fichiers temporaires précédents
        rm -f mini_games_list

        stop_the_bomb

    fi

    # Afficher le temps restant
    if [ -f "$time_file" ]; then
        time_remaining=$(cat "$time_file")
    fi

    # Attendre une seconde avant la prochaine vérification
    sleep 1
done
