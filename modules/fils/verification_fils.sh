#!/bin/bash

#Vérifier que la bombe a bien été lancée
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

# Vérifier si le fichier temporaire existe
if [[ ! -f .encoded_1 || ! -f .encoded_2 ]]; then
    echo "Veuillez d'abord lancé le module fils !"
    exit 1
fi

# Décoder et lire le fichier à supprimer
fichier_a_verifier=$(base64 --decode .encoded_1)

# Décoder et lire les fichiers initiaux
fichiers_origine=($(base64 --decode .encoded_2))

# Gestion des erreurs
error_file=".error"

if [[ -z "$fichier_a_supprimer" ]]; then
    # Condition non bonne, incrémenter le compteur d'erreurs
    if [ -f "$error_file" ]; then
        error_count=$(cat "$error_file")
        ((error_count++))
    else
        error_count=1
    fi
    echo "$error_count" > "$error_file"
fi

# Vérifier si le fichier a été supprimé
if [[ ! -e "$fichier_a_verifier" ]]; then
    # Initialiser un drapeau pour vérifier si d'autres fichiers sont encore présents
    tous_les_autres_fichiers_intacts=true

    # Vérifier que tous les autres fichiers sont intacts
    for fichier in "${fichiers_origine[@]}"; do
        # echo "Vérification du fichier : $fichier"
        if [[ "$fichier" != "$fichier_a_verifier" && ! -e "$fichier" ]]; then
            tous_les_autres_fichiers_intacts=false
            # echo "Le fichier $fichier a été modifié ou supprimé."
            # echo "La variable tous_les_autres_fichiers_intacts est maintenant à false."
            break
        fi
    done

    if $tous_les_autres_fichiers_intacts; then
        echo "Bravo ! Vous avez supprimé le bon fichier ($fichier_a_verifier) !"
        echo "Module désamorcé" > ./.module_OK  # Crée un fichier de flag pour arrêter le compteur
        verifier_temps_ecoule
        # [ -f "$error_file" ] && rm -f "$error_file"
    else
        echo "FAILED ! Vous avez supprimé d'autres fichiers que celui requis : $fichier_a_verifier."
        echo "Relancez un nouveau module fils."
        echo "Sur le module Fils, vous avez fait $(cat "$error_file") erreur(s)."
    fi
else
    echo "FAILED ! Le fichier requis n'a pas été supprimé : $fichier_a_verifier."
    echo "Relancez un nouveau module fils."
    echo "Sur le module Fils, vous avez fait $(cat "$error_file") erreur(s)."
fi

# Optionnel : supprimer les fichiers temporaires après vérification
rm -f .encoded_1 .encoded_2
rm -f *.txt