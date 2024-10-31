#!/bin/bash



# Récupération de la durée en minutes depuis l'argument
if [ -z "$1" ]; then
    echo "Erreur : durée en minutes non spécifiée."
    exit 1
fi

# Conversion de la durée en secondes
initial_time=$(($1 * 60))  

# Nom du fichier d'actualisation du temps
time_file="time"

# Inclure le fichier contenant la fonction log_message
source log_utils.sh

log_message "countdown.sh started for $initial_time seconds"

# Boucle du compte à rebours
while [ $initial_time -gt 0 ]; do

    # Vérifier si le fichier .stop_counter existe
    if [ -f .stop_counter ]; then
        log_message "Countdown stopped manually."
        rm -f .stop_counter
        rm -f ./.countdown_in_progress  # Marquer que le compte à rebours est terminé
        exit 0  # Quitter proprement le script
    fi

    # Calculer les minutes et secondes restantes
    minutes=$((initial_time / 60))
    seconds=$((initial_time % 60))

    # Afficher le temps restant
    formatted_time=$(printf "%02d:%02d" $minutes $seconds)
    echo "$formatted_time" > $time_file

    # Attendre une seconde
    sleep 1

    # Réduire le temps d'une seconde
    initial_time=$((initial_time - 1))
done

# Quand le temps est écoulé, écrire "BOOM"
log_message "Countdown is over"
rm -f ./.countdown_in_progress
echo "BOOM" > ./.countdown_expired
echo "BOOM" > $time_file
