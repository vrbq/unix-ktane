#!/bin/bash


# Fonction pour afficher l'aide
function afficher_aide() {
    echo "Utilisation : $0 [options]"
    echo "Options :"
    echo "  --test-module  Exécute le module de test."
    echo "  --help         Affiche cette aide."
}

function choix_difficulte() {
   
    # Demande de la difficulté
    echo "Choisissez une difficulté :"
    echo "1. Novice (1h)"
    echo "2. Facile (40min)"
    echo "3. Normal (30min)"
    echo "4. Dur (20min)"
    echo "5. Expert (10min)"
    read -p "Entrez le numéro correspondant à la difficulté : " difficulty

    # Définition de la durée en minutes en fonction de la difficulté
    case $difficulty in
        1) duration=60 ;;   # 1h
        2) duration=40 ;;   # 40 min
        3) duration=30 ;;   # 30 min
        4) duration=20 ;;   # 20 min
        5) duration=10 ;;   # 10 min
        *) echo "Difficulté invalide." ; exit 1 ;;
    esac

}

choix_difficulte

function choix_nombre_module() {
    
    # Lecture du fichier de modules et comptage du nombre de lignes
    modules_list_file="modules_list"
    mapfile -t modules < "$modules_list_file"
    total_modules=${#modules[@]}

    # Affichage des options pour le nombre de modules
   echo "Combien de modules voulez-vous intégrer ?"
    for i in $(seq 1 $((total_modules - 1))); do
        echo "$i"
    done
    echo "$total_modules (tous les modules)"

    # Demande du choix à l'utilisateur
    read -p "Entrez le nombre de modules : " module_choice

    # Validation du choix
    if [[ $module_choice -lt 1 || $module_choice -gt $total_modules ]]; then
        echo "Choix invalide. Veuillez entrer un nombre entre 1 et $total_modules."
        exit 1
    fi

    # Sélection des modules choisis au hasard
    selected_modules=($(shuf -e "${modules[@]}" -n "$module_choice"))
    echo "Modules sélectionnés : ${selected_modules[*]}"

    # Stockage des modules dans la variable mini_games
    mini_games=("${selected_modules[@]}")

}


# Vérifier les arguments
if [[ "$1" == "--help" ]]; then
    afficher_aide
    exit 0
elif [[ "$1" == "--test-module" ]]; then
    echo "Exécution du module de test..."

    # Charger les noms dans un tableau, en utilisant les retours à la ligne comme séparateurs
    mapfile -t mini_game_names < modules_list  # Remplace les retours à la ligne par des espaces
    
   # Fonction pour afficher la liste des noms
    function afficher_noms {
        echo "Choisissez un nom parmi la liste suivante :"
        for i in "${!mini_game_names[@]}"; do
            echo "$((i + 1)). ${mini_game_names[i]}"
        done
    }

    # Demande de choix
    while true; do
        afficher_noms
        read -p "Entrez le numéro du nom choisi : " choix
        index=$((choix - 1))

        # Vérifier si le choix est valide
        if [[ $index -ge 0 && $index -lt ${#mini_game_names[@]} ]]; then
            nom="${mini_game_names[index]}"
            echo "Vous avez choisi : $nom"
            mini_games=($nom) 
            break  # Sortir de la boucle
        else
            echo "Sélection invalide. Veuillez choisir un numéro de la liste."
        fi
    done

    # Placez ici le code pour exécuter le module de test
    # par exemple, appeler une fonction ou un autre script
else
    # Liste des mini-jeux à résoudre
    # mini_games=("fils" "vi" "size")
    choix_nombre_module
fi

echo "Mini-jeux sélectionnés : ${mini_games[*]}"


#Remise a zero du jeu
./remise_zero.sh

# Lancer le script de génération de serial
./generate_seed.sh


# Sauvegarder la liste dans un fichier caché
for game in "${mini_games[@]}"; do
    # Afficher le nom du mini-jeu en cours
    echo "Lancement du mini-jeu : $game"
    # Écrire le nom du mini-jeu dans le fichier
    echo "$game" >> mini_games_list
done

echo "Liste des mini-jeux sauvegardée dans mini_games_list : $(cat mini_games_list)"


# Vérifier si le fichier modules_list existe
if [ -f mini_games_list ]; then
    # Parcourir chaque ligne du fichier
    while IFS= read -r module || [[ -n "$module" ]]; do
        echo "Module : $module"
        # Si le module est le module "internet"
        if [[ "$module" == "internet" ]]; then
            # Copier un gif dans le répertoire du module
            src="./utils/morse"
            dest="./modules/internet"
            gif=$(find "$src" -name "*.gif" | shuf -n 1)
            cp "$gif" "$dest"
        fi

        # Vérifier si la ligne n'est pas vide
        if [[ -n "$module" ]]; then
        # Extraire uniquement les lettres (caractères alphabétiques)
        filtered_module=$(echo "$module" | tr -d -c '[:alpha:]')
            # Vérifier si le répertoire du module existe
            if [ -d "./modules/$filtered_module" ]; then
                # Créer le fichier .can_go dans le répertoire du module
                touch "./modules/$filtered_module/.can_go"
                cp -r serial "./modules/$filtered_module/.serial"
                # echo "Fichier .can_go créé dans le module : $module_name"
            fi
        fi
    done < mini_games_list
else
    echo "Le fichier modules_list n'existe pas."
fi

# Créer un nouveau fichier log vide
touch .log

pkill -9 -f "countdown"

# Lancer le script de compte à rebours en arrière-plan
if [ -f countdown.sh ]; then
    rm -f ./.countdown_expired
    ./countdown.sh $duration &
    echo "in progress" > ./.countdown_in_progress
else
    echo "Le script countdown.sh n'existe pas."
fi

# Lancer le check du status de la bombe
./check_bomb_status.sh &

# Boucle tant que le processus check_bomb_status.sh n'est pas trouvé
check_status_pid=$(ps aux | grep '[c]heck_bomb_status.sh' | awk '{print $2}')
attempt_count=0
max_attempts=3

while [ -z "$check_status_pid" ] && [ $attempt_count -lt $max_attempts ]; do
    # Utiliser ps aux pour trouver le processus check_bomb_status.sh
    check_status_pid=$(ps aux | grep '[c]heck_bomb_status.sh' | awk '{print $2}')

    if [ -z "$check_status_pid" ]; then
        # Relancer le processus si non trouvé
        ./check_bomb_status.sh &
        sleep 1  # Attendre une seconde avant de réessayer
        ((attempt_count++))  # Incrémenter le compteur de tentatives
    fi
done

# Si le processus est trouvé, sauvegarder le PID
if [ -z "$check_status_pid" ]; then
     echo "Impossible de lancer correctement la bombe"
else
    echo "$check_status_pid" > .check_status_pid
fi

# Afficher le temps restant
if [ -f .countdown_in_progress ]; then
    echo "La bombe est lancée, le compte à rebours tourne !"
    if [ -f time ]; then
        echo "Il vous $(cat time) pour désamorcer la bombe."
    fi
else
    echo "La bombe n'est pas lancée !"
fi