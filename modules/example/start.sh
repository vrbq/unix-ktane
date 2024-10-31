#!/bin/bash

# Vérifier si .can_go existe avant de commencer
if [ ! -f ".can_go" ]; then
    echo "La bombe n'a pas été lancée !"
    exit 1
fi

serial=$(cat .serial)
# Vérifier que le serial n'est pas vide
if [ -z "$serial" ]; then
    echo "Erreur : le fichier .serial est vide."
    exit 1
fi


# Remise a zero du jeu
./remise_zero.sh

# Enregistrer l'heure de début (en secondes depuis l'époque Unix)
start_time=$(date +%s)

# Vérifier si le fichier .start_time existe déjà
if [[ ! -f .start_time ]]; then
    start_time=$(date +%s)
    echo $start_time > .start_time
fi
