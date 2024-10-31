#!/bin/bash

if [[ "$1" == "--afterResolution" ]]; then
    rm *.gif
    rm -f *.csv *.hdf *.obj *.svg .encoded requete.txt
else
# Pour tous les modules
    rm -f .final_time      # Supprimer le fichier d'erreurs s'il existe
    rm -f .module_OK   # Supprimer le fichier de succès s'il existe

    # Vérifier si l'option --hard a été fournie
    if [[ "$1" == "--hard" ]]; then
        rm -f .start_time 
        rm -f .serial
        rm -f .error      # Supprimer le fichier d'erreurs s'il existe
        rm -f *.gif
    fi

    # Supprimer tous les fichiers de couleur existants
    # Vérifie si chafa est installé
    if dpkg -l | grep -q chafa; then
        # Désinstaller la librairie chafa
        sudo apt remove --purge -y chafa > /dev/null 2>&1
    fi

    # Supprimer les fichiers spécifiques et .encoded
    rm -f *.csv *.hdf *.obj *.svg .encoded requete.txt

fi