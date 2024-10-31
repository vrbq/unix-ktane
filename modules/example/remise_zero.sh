#!/bin/bash

# Pour tous les modules
rm -f .final_time      # Supprimer le fichier d'erreurs s'il existe
rm -f .module_OK   # Supprimer le fichier de succès s'il existe

# Supprimer tous les fichiers propre au module

# Vérifier si l'option --hard a été fournie
if [[ "$1" == "--hard" ]]; then
    rm -f .start_time 
    rm -f .error      # Supprimer le fichier d'erreurs s'il existe
fi