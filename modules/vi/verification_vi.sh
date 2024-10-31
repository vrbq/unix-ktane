#!/bin/bash

# Chemin vers le fichier "encoded" contenant le chemin du fichier joueur
encoded_path=".encoded"

# Chemin vers le fichier encodé en base64 contenant le contenu attendu
encoded_file=".encoded_2"

# Fichier de comptabilisation des erreurs
error_file=".error"

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
        echo "Le module vi a été résolu en $minutes minutes et $seconds secondes."

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

# Initialiser le compteur d'erreurs s'il n'existe pas
if [ ! -f "$error_file" ]; then
    echo 0 > "$error_file"
fi

# Fonction pour incrémenter le compteur d'erreurs
increment_error() {
    current_errors=$(cat "$error_file")
    new_errors=$((current_errors + 1))
    echo "$new_errors" > "$error_file"
    echo "Sur le module Vi, vous avez fait $(cat "$error_file") erreur(s)."
}

# Décoder le fichier "encoded" pour obtenir le chemin
decoded_path=$(base64 -d "$encoded_path")

# Lire le répertoire et le fichier depuis le contenu décodé
directory=$(echo "$decoded_path" | sed -n '2p')
filename=$(echo "$decoded_path" | sed -n '1p')

# Chemin complet du fichier joueur
joueur_file="${directory}/${filename}"

# Vérifier que le fichier joueur existe
if [ ! -f "$joueur_file" ]; then
    echo "Le fichier $filename n'existe pas dans le répertoire $directory."
    increment_error
    exit 1
fi

# Vérifier que le fichier est bien dans le bon répertoire
if [ "$(dirname "$joueur_file")" != "$directory" ]; then
    echo "Le fichier $filename n'est pas dans le répertoire correct."
    increment_error
    exit 1
fi

# Décoder le fichier .encoded_2 pour obtenir le contenu attendu
decoded_content=$(base64 -d "$encoded_file")
expected_file=".expected_content"

# Créer un fichier temporaire pour le contenu du joueur
echo "$decoded_content" > "$expected_file"

# Compter les différences
differences_count=0

# Lire les fichiers ligne par ligne
exec 3<"$expected_file"
exec 4<"$joueur_file"

while true; do
    # Lire une ligne de chaque fichier
    IFS= read -r -u 3 expected_line
    IFS= read -r -u 4 joueur_line

    # Si les deux fichiers sont à la fin, sortir de la boucle
    if [[ -z "$expected_line" && -z "$joueur_line" ]]; then
        break
    fi

    # Vérifier si les lignes sont différentes
    if [[ "$expected_line" != "$joueur_line" ]]; then
        # echo "Différence trouvée :"
        # echo "Attendu : $expected_line"
        # echo "Joueur : $joueur_line"
        ((differences_count++))
    fi
done

# Fermer les descripteurs de fichier
exec 3<&-
exec 4<&-

# Afficher le nombre total de différences
# echo "Nombre total de différences : $differences_count"

# Vérifier le nombre d'erreurs
current_errors=$(cat "$error_file")

if [[ $differences_count -ge 2 ]]; then
    increment_error
    echo "Le contenu du fichier modifié ne correspond pas aux modifications souhaitées."
    # echo "Nombre de différences : $differences_count"
    exit 1
else
    # echo "Le fichier modifié est considéré comme correct malgré les différences."
    echo "Le fichier modifié est correct ! Félicitations !"
    echo "Module désamorcé" > ./.module_OK  # Crée un fichier de flag pour arrêter le compteur
    verifier_temps_ecoule
fi

# Nettoyer le fichier temporaire
rm "$expected_file"
exit 0