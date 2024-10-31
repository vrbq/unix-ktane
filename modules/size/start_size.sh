#!/bin/bash

# Vérifier si .can_go existe avant de commencer
if [ ! -f ".can_go" ]; then
    echo "La bombe n'a pas été lancée !"
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

######## DEBUT DU JEU ########

# Génère un nombre aléatoire de fichiers entre 20 et 60
generate_random_file_count() {
    echo $((RANDOM % 41 + 20))
}

# Crée les répertoires avec une profondeur maximale de 3 et maximum 5 dossiers par niveau
create_random_dirs() {
    local max_depth=3
    local max_dirs_per_level=5
    local path="."
    local depth=$((RANDOM % max_depth + 1))

    for ((i=0; i<depth; i++)); do
        # Limite à 5 dossiers par niveau
        dir_name="dir_$((RANDOM % max_dirs_per_level))"
        path="$path/$dir_name"
        mkdir -p "$path"
    done

    echo "$path"
}

# Génère les fichiers avec des tailles uniques et les place dans les répertoires créés
generate_files() {
    local num_files=$(generate_random_file_count)
    local -a sizes
    local -a file_paths

    for ((i=0; i<num_files; i++)); do
        # Génère une taille unique entre 10 et 1000 octets
        while :; do
            size=$((RANDOM % 991 + 10))
            if [[ ! " ${sizes[*]} " =~ " ${size} " ]]; then
                sizes+=("$size")
                break
            fi
        done

        # Crée un nom de fichier unique
        file_name="file_$((RANDOM % 1000)).txt"

        # Détermine un répertoire aléatoire pour le fichier, permettant plusieurs fichiers par dossier
        dir_path=$(create_random_dirs)
        file_path="$dir_path/$file_name"

        # Génère le fichier avec la taille spécifiée
        head -c "$size" </dev/urandom > "$file_path"
        file_paths+=("$file_path")
    done

    # Retourne les tableaux de tailles et de chemins de fichiers
    # echo "${sizes[@]}"
    # echo "${file_paths[@]}"
}

generate_files

get_random_unique_txt_file() {
    # Déclaration d'un tableau pour stocker les tailles de fichiers
    declare -A sizes

    # Parcourir tous les fichiers .txt pour remplir le tableau des tailles
    while IFS= read -r file; do
        size=$(stat -c%s "$file")
        sizes["$size"]="$file"
    done < <(find . -type f -name "*.txt")

    # Trouver une taille unique
    unique_size=""
    for size in "${!sizes[@]}"; do
        if [[ $(find . -type f -name "*.txt" -exec stat -c%s {} \; | grep -c "^$size$") -eq 1 ]]; then
            unique_size="$size"
            break
        fi
    done

    # Vérifier si une taille unique a été trouvée
    if [[ -n $unique_size ]]; then
        # Récupérer le fichier associé à la taille unique
        file="${sizes[$unique_size]}"
        # Extraire uniquement le nom du fichier
        local filename=$(basename "$file")
        
        # Extraire le numéro présent dans le nom du fichier
        local number=$(echo "$filename" | grep -oE '[0-9]+')

        # echo "Nom du fichier : $filename"
        # echo "Taille : $unique_size"
        # echo "Numéro extrait : $number"

        # Sortir les résultats dans des variables
        FILENAME="$filename"
        FILESIZE="$unique_size"
        FILENUMBER="$number"
    else
        echo "Aucun fichier .txt avec une taille unique trouvé."
    fi
}

# Crée les fichiers et enregistre les informations dans un fichier "question" et ".encoded"
setup_game() {

    # Appel de la fonction
    get_random_unique_txt_file


    # Écrit la question dans le fichier
    echo "Quel est le chiffre présent dans le nom du fichier faisant  $FILESIZE octets ?" > question

    # Encode le nom du fichier en base64 et le stocke dans ".encoded"
    echo -n "$FILENUMBER" | base64 > .encoded
}

# Appelle la fonction pour initialiser le jeu
setup_game
echo "Les fichiers ont été générés. Consultez le fichier 'question' pour la question à répondre."
