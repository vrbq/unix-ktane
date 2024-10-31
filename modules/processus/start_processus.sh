#!/bin/bash

# Vérifier si .can_go existe avant de commencer
if [ ! -f ".can_go" ]; then
    echo "La bombe n'a pas été lancée !"
    exit 1
fi

# Remise a zero du jeu
./remise_zero.sh

# Créer les fichiers nécessaires pour les scripts
echo "sleep 3600" > .tintin_tibet.sh
chmod +x .tintin_tibet.sh  # Rendre le script exécutable
echo "sleep 3600" > .tintin_or_noir.sh
chmod +x .tintin_or_noir.sh  # Rendre le script exécutable
echo "sleep 3600" > .tintin_objectif_lune.sh
chmod +x .tintin_objectif_lune.sh  # Rendre le script exécutable
echo "sleep 3600" > .tintin_picaros.sh
chmod +x .tintin_picaros.sh  # Rendre le script exécutable
echo "sleep 3600" > .tintin_etudie_en_TC.sh
chmod +x .tintin_etudie_en_TC.sh # Rendre le script exécutable


# Enregistrer l'heure de début (en secondes depuis l'époque Unix)
start_time=$(date +%s)

# Vérifier si le fichier .start_time existe déjà
if [[ ! -f .start_time ]]; then
    start_time=$(date +%s)
    echo $start_time > .start_time
fi

# Étape 1 : Choisir un nombre aléatoire entre 1 et 5
random_number=$(( RANDOM % 5 + 1 ))
echo "$random_number" | base64 > .encoded

# Lancer le script .liste_personnage.sh en arrière-plan pour afficher les personnages
./.liste_personnage.sh "$random_number" &

# Actions spécifiques en fonction du nombre choisi
if [ "$random_number" -eq 1 ]; then
    sudo -u root ./.tintin_or_noir.sh &
    sleep 1
    pid=$(pgrep -f "sh ./.tintin_or_noir.sh")
    echo "$pid" | base64 > .encoded_2  # Sauvegarder le PID de manière encodée pour vérification

elif [ "$random_number" -eq 2 ]; then
    sudo -u root ./.tintin_tibet.sh &

elif [ "$random_number" -eq 3 ]; then
    # Créer l’utilisateur "herge" s'il n'existe pas déjà
    sudo useradd -m herge 2>/dev/null
    # Lancer le script .tintin_objectif_lune.sh en tant qu'utilisateur "castafiore" en arrière-plan
    sudo -u herge ./.tintin_objectif_lune.sh &
    echo "herge" | base64 > .encoded_2  # Sauvegarder l'utilisateur de manière encodée

elif [ "$random_number" -eq 4 ]; then
    sudo -u root ./.tintin_picaros.sh &

elif [ "$random_number" -eq 5 ]; then
    sudo -u root ./.tintin_etudie_en_TC.sh &
    sleep 1
    pid=$(pgrep -f "sh ./.tintin_etudie_en_TC.sh")

    # Vérifier si le PID a été trouvé
    if [ -z "$pid" ]; then
        echo "Erreur : le processus 'tintin_etudie_en_TC.sh' n'est pas en cours d'exécution."
    else
        # Vérifier que le PID est un nombre valide
        if ! [[ "$pid" =~ ^[0-9]+$ ]]; then
            echo "Erreur : PID trouvé n'est pas valide."
        else
            # Récupérer l'utilisation CPU du processus spécifique
            cpu_usage=$(ps -p "$pid" -o %cpu --no-headers)

            # Vérifier si la récupération a réussi
            if [ -z "$cpu_usage" ]; then
                echo "Erreur : impossible de récupérer l'utilisation CPU pour le PID $pid."
            else
                # Afficher l'utilisation CPU
                echo "$cpu_usage" | base64 > .encoded_2
            fi
        fi
    fi


fi

