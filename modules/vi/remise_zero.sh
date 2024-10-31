#!/bin/bash

# Pour tous les modules
rm -f .final_time      # Supprimer le fichier d'erreurs s'il existe
rm -f .module_OK   # Supprimer le fichier de succès s'il existe

# Supprimer le fichier de citations, les instructions cachées, et le sous-répertoire
rm -f citations 
rm -f .encoded .encoded_2 .encoded_3 .encoded_3.b64 .encoded_4 .encoded_5
rm -f modifications
rm -rf burger orange pizza

# Vérifier si l'option --hard a été fournie
if [[ "$1" == "--hard" ]]; then
    rm -f .start_time
    rm -f .serial
    rm -f .error      # Supprimer le fichier d'erreurs s'il existe
fi