# Supprimer les fichiers temporaires précédents

rm -f mini_games_list
rm -f verifications
rm -f .log
rm -f .stop_counter
rm -f .countdown_expired
rm -f .countdown_in_progress
rm -f error_status
rm -f time
rm -f serial
rm -f category
rm -f log
rm -f .check_status_pid

stop_the_bomb() {

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
            # echo "Le fichier .check_status_pid est introuvable, recherche du processus check_bomb_status..."

            # Utiliser ps aux pour trouver le processus countdown.sh
            check_status_pid=$(ps aux | grep '[c]heck_bomb_status.sh' | awk '{print $2}')
            countdown_pid=$(ps aux | grep '[c]ountdown.sh' | awk '{print $2}')

            if [ -n "$check_status_pid" ]; then
                # echo "Arrêt du processus check_bomb_status trouvé (PID: $check_status_pid)"
                kill $check_status_pid
                kill  $countdown_pid	
            fi
        fi

        exit 0
        break
}

original_dir="$(pwd)"

# Supprimer les fichiers de tous les modules
if [ -f modules_list ]; then
    # Parcourir chaque ligne du fichier
    while IFS= read -r module || [[ -n "$module" ]]; do
        # Vérifier si la ligne n'est pas vide
        if [[ -n "$module" ]]; then
            # Faire quelque chose avec chaque module
            # echo "Remise a zero : $module"
            
            module_ok_file="./modules/$module/.module_OK"
            can_go_file="./modules/$module/.can_go"
            error_file="./modules/$module/.error"
            remise_zero="./modules/$module/remise_zero.sh"
            serial="./modules/$module/.serial"
            start_time="./modules/$module/.start_time"
            
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
            if [ -f "$serial" ]; then
                # Lancer la remise a zero
                rm "$serial"
            fi
            if [ -f "$start_time" ]; then
                # Lancer la remise a zero
                rm "$start_time"
            fi
            if [ -f "$remise_zero" ]; then
                # Lancer la remise a zero
                # ./"$remise_zero"
                cd "./modules/$module"
                ./remise_zero.sh --hard
                # Revenir au répertoire d'origine
                cd "$original_dir" || exit
            fi
        fi
    done < modules_list
else
    echo "Le fichier modules_list n'existe pas."
fi

stop_the_bomb


