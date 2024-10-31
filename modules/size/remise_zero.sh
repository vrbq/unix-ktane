#!/bin/bash

# Supprimer les fichiers et dossiers générés par le jeu
    cleanup() {
        # Répertoire racine où les fichiers et dossiers ont été générés
        root_dir="." # Remplacez par le répertoire exact si différent
        # echo "Nettoyage des fichiers et répertoires générés..."

        # # Recherche et suppression des fichiers générés (fichiers .txt et les répertoires dir_*)
        find "$root_dir" -type f -name "file_*.txt" -exec rm -f {} \; > /dev/null 2>&1
        find "$root_dir" -type d -name "dir_*" -exec rm -rf {} \; > /dev/null 2>&1

        # Suppression des fichiers "question" et ".encoded"
        rm -f "$root_dir/question" "$root_dir/.encoded" > /dev/null 2>&1

        # echo "Nettoyage terminé."
    }

# Vérifier si l'option --hard a été fournie
if [[ "$1" == "--afterResolution" ]]; then
    echo "Nettoyage des fichiers et répertoires générés après la résolution"
    cleanup
else

    # Pour tous les modules
    rm -f .final_time      # Supprimer le fichier d'erreurs s'il existe
    rm -f .module_OK   # Supprimer le fichier de succès s'il existe
    
    # Appeler la fonction de nettoyage
    cleanup

    # Vérifier si l'option --hard a été fournie
    if [[ "$1" == "--hard" ]]; then
        rm -f .start_time
        rm -f .serial
        rm -f .error      # Supprimer le fichier d'erreurs s'il existe
    fi

fi