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
    echo "Sur le module Size, vous avez fait $(cat "$error_file") erreur(s)."
}

# # Vérifier si le fichier temporaire existe
# if [[ ! -f .encoded_1 || ! -f .encoded_2 ]]; then
#     echo "Veuillez d'abord lancé le module fils !"
#     exit 1


# if $tous_les_autres_fichiers_intacts; then
#         verifier_temps_ecoule
#         # [ -f "$error_file" ] && rm -f "$error_file"
# else
#         echo "FAILED !"
# fi