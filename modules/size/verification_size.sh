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

# Vérifier si le fichier temporaire existe
if [[ ! -f .encoded ]]; then
    echo "Veuillez d'abord lancé le module !"
    exit 1
fi

# Vérifie la réponse du joueur
verify_answer() {
    # Décoder le fichier .encoded pour obtenir le numéro de base
    numero_base=$(base64 --decode < .encoded)

    # Lire le contenu du fichier .serial
    serial_content=$(< .serial)

    # Initialiser la somme des valeurs des lettres
    sum=0

    # Parcourir chaque caractère du serial
    for (( i=0; i<${#serial_content}; i++ )); do
        char_undecoded=${serial_content:$i:1}
        char=$(echo -n "$char_undecoded" | base64)

        # Ajouter la valeur correspondante si c'est une lettre
        if [[ "$char" == "QQ==" ]]; then
            sum=$((sum + 12))
        elif [[ "$char" == "UQ==" ]]; then
            sum=$((sum + 14))
        elif [[ "$char" == "Ug==" ]]; then
            sum=$((sum + 0))
        elif [[ "$char" == "Uw==" ]]; then
            sum=$((sum - 20))
        elif [[ "$char" == "VA==" ]]; then
            sum=$((sum + 10))
        elif [[ "$char" == "VQ==" ]]; then
            sum=$((sum + 18))
        elif [[ "$char" == "Vg==" ]]; then
            sum=$((sum - 5))
        elif [[ "$char" == "Vw==" ]]; then
            sum=$((sum + 9))
        elif [[ "$char" == "WA==" ]]; then
            sum=$((sum + 26))
        elif [[ "$char" == "WQ==" ]]; then
            sum=$((sum + 11))
        elif [[ "$char" == "Wg==" ]]; then
            sum=$((sum - 12))
        elif [[ "$char" == "RQ==" ]]; then
            sum=$((sum - 10))
        elif [[ "$char" == "Rg==" ]]; then
            sum=$((sum + 8))
        elif [[ "$char" == "Rw==" ]]; then
            sum=$((sum - 1))
        elif [[ "$char" == "SA==" ]]; then
            sum=$((sum + 30))
        elif [[ "$char" == "SQ==" ]]; then
            sum=$((sum + 6))
        elif [[ "$char" == "Sg==" ]]; then
            sum=$((sum + 15))
        elif [[ "$char" == "Sw==" ]]; then
            sum=$((sum - 15))
        elif [[ "$char" == "TA==" ]]; then
            sum=$((sum + 22))
        elif [[ "$char" == "Qg==" ]]; then
            sum=$((sum - 3))
        elif [[ "$char" == "Qw==" ]]; then
            sum=$((sum + 25))
        elif [[ "$char" == "RA==" ]]; then
            sum=$((sum + 17))
        elif [[ "$char" == "TQ==" ]]; then
            sum=$((sum - 8))
        elif [[ "$char" == "Tg==" ]]; then
            sum=$((sum + 4))
        elif [[ "$char" == "Tw==" ]]; then
            sum=$((sum + 27))
        elif [[ "$char" == "UA==" ]]; then
            sum=$((sum - 22))
        fi
    done

    # Calculer le numéro attendu
    expected_number=$((numero_base + sum))

    # Demander au joueur de saisir le numéro
    read -p "Quel est le numéro ? " player_answer

    # Comparer la réponse du joueur avec le numéro attendu
    if [[ "$player_answer" -eq "$expected_number" ]]; then
        echo "Bravo ! Vous avez trouvé le bon numéro."
        echo "Module désamorcé" > ./.module_OK  # Crée un fichier de flag pour arrêter le compteur
        verifier_temps_ecoule
        # Remise a zero du jeu
        ./remise_zero.sh --afterResolution
    else
        echo "Désolé, ce n'est pas le bon numéro."
        increment_error
    fi
}

# Appelle la fonction de vérification
verify_answer