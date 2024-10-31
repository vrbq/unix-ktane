#!/bin/bash

# Vérifier si .can_go existe avant de commencer
if [ ! -f ".can_go" ]; then
    echo "La bombe n'a pas été lancée !"
    exit 1
fi

# Fonction pour vérifier le temps écoulé
function verifier_temps_ecoule() {
    # Lire l'heure de début enregistrée
    if [[ -f .start_time ]]; then
        start_time=$(cat .start_time)
        end_time=$(date +%s)
        elapsed_time=$((end_time - start_time))
        
        # Convertir le temps écoulé en minutes et secondes
        minutes=$((elapsed_time / 60))
        seconds=$((elapsed_time % 60))

        # Afficher le temps écoulé
        echo "Le mini-jeu a été résolu en $minutes minutes et $seconds secondes."

        # Enregistrer le temps total dans le fichier .final_time
        echo "$minutes minutes et $seconds secondes" > .final_time
        
        # Supprimer le fichier de l'heure de début pour éviter les conflits
        rm .start_time
        
        # Rajouter le temps dans le .module_OK
        echo "$minutes minutes et $seconds secondes" >> .module_OK
    else
        echo "L'heure de début n'a pas été enregistrée."
    fi
}

# Gestion des erreurs
error_file=".error"

# Initialiser le compteur d'erreurs s'il n'existe pas
if [ ! -f "$error_file" ]; then
    echo 0 > "$error_file"
fi

# Fonction pour incrémenter le compteur d'erreurs
increment_error() {
    current_errors=$(cat "$error_file")
    new_errors=$((current_errors + 1))
    echo "$new_errors" > "$error_file"
    echo "Sur le module Processus, vous avez fait $(cat "$error_file") erreur(s)."
}

validation_module() {
    verifier_temps_ecoule
    echo "Module désamorcé" > ./.module_OK  # Crée un fichier de flag pour arrêter le compteur
    ./remise_zero.sh --afterResolution
}

# Vérifier si le fichier temporaire existe
if [[ ! -f .encoded ]]; then
    echo "Veuillez d'abord lancé le module !"
    exit 1
fi

# Décoder le numéro de l'album choisi
album_number=$(base64 --decode < .encoded)

# Vérifications en fonction de l'album
if [ "$album_number" -eq 1 ]; then
    # Vérifier le PID du processus "Tintin au pays de l'or noir"
    echo "Quel est le PID trouvé ?"
    read user_pid
    stored_pid=$(base64 --decode < .encoded_2)
    if [ "$user_pid" == "$stored_pid" ]; then
        echo "Bravo ! Le PID rentré est correct"
        validation_module
    else
        echo "Erreur, le PID rentré est incorrect"
        increment_error
    fi

elif [ "$album_number" -eq 2 ]; then
    # Vérifier que le processus "Tintin au Tibet" est bien tué
    if ! pgrep -f ".tintin_tibet.sh" >/dev/null; then
        echo "Bravo ! Le processus est tué."
        validation_module
    else
        echo "Erreur : Le processus est encore actif."
        increment_error
    fi

elif [ "$album_number" -eq 3 ]; then
    # Vérifier l'utilisateur pour "Tintin Objectif Lune"
    echo "Quel nom d'utilisateur avez-vous trouvé ?"
    read user_answer
    stored_user=$(base64 --decode < .encoded_2)
    if [ "$user_answer" == "$stored_user" ]; then
        echo "Bravo ! Utilisateur correct."
        validation_module
    else
        echo "Erreur : Utilisateur incorrect."
        increment_error
    fi

elif [ "$album_number" -eq 4 ]; then
        # Récupérer le PID du processus
    pid=$(pgrep -f "sh ./.tintin_picaros.sh")

    # Vérifier si le processus est stoppé
    if [ -n "$pid" ]; then
        # Récupérer le statut du processus
        process_status=$(ps -o stat= -p "$pid")

        # Vérifier si le statut commence par 'T' (stoppé)
        if [[ "$process_status" == T* ]]; then
            echo "Bravo ! Le processus est stoppé."
            validation_module
        else
            echo "Erreur : Le processus n'est pas stoppé."
            increment_error
        fi
    else
        echo "Erreur : Aucun processus trouvé. Vous avez peut-être tué le processus au lieu de le stopper."
        echo "Veuillez relancer le module."
        increment_error
    fi

elif [ "$album_number" -eq 5 ]; then
    echo "Quelle est l'utilisation CPU du processus ?"
    read user_cpu

    cpu_usage_float=$(base64 --decode < .encoded_2)
    user_cpu_float=$(echo "$user_cpu" | awk '{print $1}')

    if (( $(echo "$user_cpu_float < 0" | bc -l) )); then
        echo "La valeur rentrée n'est pas correcte"
        increment_error
    else
        # Vérifier si l'utilisation CPU de l'utilisateur est dans la plage acceptable
        if (( $(echo "$user_cpu_float >= $cpu_usage_float - 1" | bc -l) )) && (( $(echo "$user_cpu_float <= $cpu_usage_float + 1" | bc -l) )); then
            echo "Bravo ! La valeur est correcte !"
            validation_module
        else
            echo "La valeur rentrée n'est pas correcte"
            increment_error
        fi
    fi

fi