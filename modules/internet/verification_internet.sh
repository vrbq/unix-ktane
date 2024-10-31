#!/bin/bash

#Vérifier que la bombe a bien été lancée
# # Vérifier si .can_go existe avant de commencer
# if [ ! -f ".can_go" ]; then
#     echo "La bombe n'a pas été lancée !"
#     exit 1
# fi

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
    echo "Sur le module Internet, vous avez fait $(cat "$error_file") erreur(s)."
}

# Vérifier si le fichier temporaire existe
if [[ ! -f .encoded  ]]; then
    echo "Veuillez d'abord lancé le module !"
    exit 1
fi

# Décode le fichier GIF pour obtenir le mot
gif_file_base64=$(ls *.gif)
gif_sans_extension=$(basename "$gif_file_base64" .gif)
gif_file=$(echo "$gif_sans_extension" | base64 --decode)
mot=$(echo "$gif_file" | grep -o -E '\w+')


if [[ "$mot" == "chose" || "$mot" == "champ" ]]; then
    resultat_joueur=$(cat requete.txt)
    expected_domain=$(head -n 1 .encoded | base64 --decode)
    expected_packets=$(head -n 2 .encoded | tail -n 1 | base64 --decode)

    # Vérifier si le nom de domaine est correct
    if echo "$resultat_joueur" | grep -q "ping statistics ---"; then
        if echo "$resultat_joueur" | grep -q "$expected_domain"; then
            domain_check=true
        else
            domain_check=false
        fi
    else
        domain_check=false
    fi

    # Vérifier si le nombre de paquets transmis est correct
    packets_transmitted=$(echo "$resultat_joueur" | grep -oP '\d+(?= packets transmitted)')

    if [ "$packets_transmitted" -eq "$expected_packets" ]; then
        packets_check=true
    else
        packets_check=false
    fi

    # Résumé de la vérification
    if [ "$domain_check" = true ] && [ "$packets_check" = true ]; then
        echo "Bravo, vous avez désamorcé le module Internet !"
        verifier_temps_ecoule
        echo "Module désamorcé" > ./.module_OK  # Crée un fichier de flag pour arrêter le compteur
        ./remise_zero.sh --afterResolution
    else
        echo "Le résultat enregistré ne correspond pas à l'attendu. Le fichier requete.txt est supprimé."
        increment_error
        rm requete.txt
    fi
else
    # Pose la question et attend la réponse
    read -p "Quelle est ta réponse ? " reponse

    # Décoder le fichier .encoded pour comparer
    encoded_response=$(base64 --decode < .encoded)

    # Vérifie si la réponse est correcte
    if [[ "$reponse" == *"$encoded_response"* ]]; then
        echo "Bravo, vous avez désamorcé le module Internet !"
        verifier_temps_ecoule
        echo "Module désamorcé" > ./.module_OK  # Crée un fichier de flag pour arrêter le compteur
        ./remise_zero.sh --afterResolution
    else
        echo "Mauvaise réponse."
        increment_error
    fi
fi




# if $tous_les_autres_fichiers_intacts; then
#         verifier_temps_ecoule
#         # [ -f "$error_file" ] && rm -f "$error_file"
# else
#         echo "FAILED !"
# fi