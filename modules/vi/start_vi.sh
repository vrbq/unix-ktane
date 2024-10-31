#!/bin/bash

# Vérifier si .can_go existe avant de commencer
if [ ! -f ".can_go" ]; then
    echo "La bombe n'a pas été lancée !"
    exit 1
fi

serial=$(cat .serial)
    
# Vérifier que le serial n'est pas vide
if [ -z "$serial" ]; then
    echo "Erreur : le fichier .serial est vide."
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

# Générer un fichier texte de citations numérotées
generate_citations() {
citations=(
    "\"Le plus grand risque est de ne prendre aucun risque. Dans un monde qui change rapidement, la seule stratégie garantie de rater est de ne pas prendre de risques.\" - Mark Zuckerberg"
    "\"La vie est un défi, relève-le !\" - Mère Teresa"
    "\"Ce qui ne me tue pas me rend plus fort.\" - Friedrich Nietzsche"
    "\"Le succès n'est pas la clé du bonheur. Le bonheur est la clé du succès. Si vous aimez ce que vous faites, vous réussirez.\" - Albert Schweitzer"
    "\"La seule façon de faire du bon travail est d'aimer ce que vous faites.\" - Steve Jobs"
    "\"Nous ne voyons pas les choses comme elles sont, nous les voyons comme nous sommes.\" - Anaïs Nin"
    "\"La simplicité est la sophistication suprême.\" - Léonard de Vinci"
    "\"Tout ce dont vous avez besoin est déjà en vous, vous devez juste le réaliser.\" - Eckhart Tolle"
    "\"La meilleure façon de prédire l'avenir est de l'inventer.\" - Alan Kay"
    "\"Il n'y a pas d'échec, seulement des retours d'expérience.\" - Robert Allen"
    "\"La vie est un mystère qu'il faut vivre, et non un problème à résoudre.\" - Gandhi"
    "\"Ne soyez pas poussé par vos problèmes, mais guidé par vos rêves.\" - Ralph Waldo Emerson"
    "\"Le bonheur n'est pas quelque chose de prêt à l'emploi. Il vient de vos propres actions.\" - Dalaï Lama"
    "\"Le voyage de mille miles commence par un pas.\" - Lao Tseu"
    "\"Tout ce que nous sommes est le résultat de ce que nous avons pensé.\" - Bouddha"
    "\"Il est impossible de vivre sans échouer à quelque chose, à moins que vous ne viviez si prudemment que vous n'auriez pas vécu du tout, auquel cas vous avez échoué par défaut.\" - J.K. Rowling"
    "\"Vous ne trouvez pas le bonheur, vous le créez.\" - Camilla Eyring Kimball"
    "\"Il ne s'agit pas de savoir si vous êtes capable, il s'agit de savoir si vous êtes prêt.\" - Eric Thomas"
    "\"La seule manière de faire un excellent travail est d'aimer ce que vous faites.\" - Steve Jobs"
    "\"Le meilleur moyen de prédire l'avenir est de l'inventer.\" - Peter Drucker"
    "\"Il n'y a pas de réussite sans échec.\" - L. Ron Hubbard"
    "\"Les opportunités ne se présentent pas, elles se créent.\" - Chris Grosser"
    "\"Le succès est la somme de petits efforts répétés jour après jour.\" - Robert Collier"
    "\"Ne regardez pas l'horloge ; faites ce qu'elle fait. Continuez à avancer.\" - Sam Levenson"
    "\"Vous êtes jamais trop vieux pour vous fixer un nouvel objectif ou rêver un nouveau rêve.\" - C.S. Lewis"
    "\"Ce qui compte, ce n'est pas ce que vous regardez, mais ce que vous voyez.\" - Henry David Thoreau"
    "\"Ne laissez pas le bruit des opinions des autres étouffer votre propre voix.\" - Steve Jobs"
    "\"Le passé ne peut être changé. L'avenir est encore entre vos mains.\" - Anonyme"
    "\"Soyez le changement que vous voulez voir dans le monde.\" - Gandhi"
    "\"La chose la plus difficile est la décision d'agir, le reste n'est que ténacité.\" - Amelia Earhart"
    "\"La seule véritable erreur est celle dont nous ne tirons aucun enseignement.\" - John Powell"
    "\"Visez la lune. Même si vous la ratez, vous atterrirez parmi les étoiles.\" - Les Brown"
    "\"Faites ce que vous pouvez, avec ce que vous avez, où vous êtes.\" - Theodore Roosevelt"
    "\"Les défis sont ce qui rend la vie intéressante, et les surmonter est ce qui lui donne du sens.\" - Joshua J. Marine"
    "\"L'avenir appartient à ceux qui croient à la beauté de leurs rêves.\" - Eleanor Roosevelt"
)

    # Choisir un nombre de citations entre 6 et 20
    nb_citations=$((RANDOM % 16 + 6))

    # Sélectionner les citations aléatoirement et les écrire dans le fichier
    for i in $(seq 1 $nb_citations); do
        citation=${citations[$RANDOM % ${#citations[@]}]}
        echo "$i. $citation" >> citations
    done
}

# Déterminer le nom de l'animal en fonction du numéro de série
# Déterminer le nom de l'animal en fonction du numéro de série
determine_animal_name() {
    serial=$(cat .serial)
    
    # Vérifier que le serial n'est pas vide
    if [ -z "$serial" ]; then
        echo "Erreur : le fichier .serial est vide."
        exit 1
    fi
    
    consonnes=$(echo "$serial" | grep -o '[BCDFGHJKLMNPQRSTVWXYZ]' | wc -l)
    
    # Vérifier que le dernier caractère est un chiffre
    dernier_chiffre=${serial: -1}
    if ! [[ "$dernier_chiffre" =~ ^[0-9]$ ]]; then
        echo "Erreur : le dernier caractère du serial n'est pas un chiffre."
        exit 1
    fi
    
    if [[ $consonnes -eq 0 && $((dernier_chiffre % 2)) -eq 0 ]]; then
        animal="lion"
    elif [[ $consonnes -eq 1 && $((dernier_chiffre % 2)) -eq 0 ]]; then
        animal="elephant"
    elif [[ $consonnes -eq 2 && $((dernier_chiffre % 2)) -eq 0 ]]; then
        animal="koala"
    elif [[ $consonnes -eq 0 && $((dernier_chiffre % 2)) -ne 0 ]]; then
        animal="panda"
    elif [[ $consonnes -eq 1 && $((dernier_chiffre % 2)) -ne 0 ]]; then
        animal="kangourou"
    else
        animal="crocodile"
    fi
    
    echo "$animal"
}


# Déterminer le répertoire en fonction des voyelles
determine_directory_name() {
    serial=$(cat .serial)
    voyelles=$(echo "$serial" | grep -o '[aeiouyAEIOUY]' | wc -l | tr -d ' ')

    # Vérifier si voyelles est bien un nombre
    if ! echo "$voyelles" | grep -qE '^[0-9]+$'; then
        echo "Erreur : le nombre de voyelles n'est pas valide."
        exit 1
    fi

    if [ "$voyelles" -eq 0 ]; then
        directory="burger"
    elif [ "$voyelles" -eq 1 ]; then
        directory="orange"
    else
        directory="pizza"
    fi

    echo "$directory"
}

# Générer le fichier de citations
generate_citations

# Déterminer l'animal et le répertoire
filename=$(determine_animal_name)
directory=$(determine_directory_name)

echo -e "$filename\n$directory" | base64 > .encoded

# # Créer le fichier de citation et le répertoire
# mkdir -p "$directory"
# mv citations.txt "$directory/$animal.txt"

# Générer les instructions cachées
modifications=()

# Définir le fichier de citations
citation_file="citations"

# Créer un fichier pour enregistrer les modifications
modifications_file=".encoded_3_temp"

# Fichier temporaire pour garder les indices des lignes choisies
CHOSEN_FILE=".encoded_4"

# Supprimer le fichier des indices choisis s'il existe
if [ -f "$CHOSEN_FILE" ]; then
    rm "$CHOSEN_FILE"
fi

# Créer un nouveau fichier vide pour les indices choisis
touch "$CHOSEN_FILE"

# Fichier contenant le dernier numéro de série
SERIAL_FILE=".serial"

# Compter le nombre de citations
num_citations=$(wc -l < "$citation_file")

# Vérifiez si le fichier de citations est vide
if [[ $num_citations -eq 0 ]]; then
    echo "Erreur : le fichier de citations est vide."
    exit 1
fi

# Fichier contenant le dernier numéro de série
SERIAL_FILE=".serial"
# Fichier temporaire pour garder les indices des lignes choisies
CHOSEN_FILE=".encoded_4"

# Supprimer le fichier des indices choisis s'il existe
if [ -f "$CHOSEN_FILE" ]; then
    rm "$CHOSEN_FILE"
fi

# Créer un nouveau fichier vide pour les indices choisis
touch "$CHOSEN_FILE"

# Lire le dernier numéro de série
if [ -f "$SERIAL_FILE" ]; then
    SERIAL=$(cat .serial)
    LAST_SERIAL=${SERIAL: -1}
    
    # Extraire uniquement les chiffres de la dernière ligne
    LAST_SERIAL=$(echo "$LAST_SERIAL" | grep -o '[0-9]*' | tail -n 1)  # Prendre le dernier nombre
else
    echo "Le fichier .serial n'existe pas."
    LAST_SERIAL=0  # Si le fichier n'existe pas, on suppose 0
fi

# Vérifier si LAST_SERIAL est un entier
if ! [[ "$LAST_SERIAL" =~ ^[0-9]+$ ]]; then
    echo "Le dernier numéro de série n'est pas un entier. Utilisation de 0 par défaut."
    LAST_SERIAL=0
fi

# Tableau pour garder les indices des lignes choisies
chosen_indices=()


# Fonction pour obtenir une citation aléatoire
get_random_citation() {
    # Compter le nombre de lignes dans le fichier
    total_lines=$(wc -l < "$citation_file")

    # Lire les indices choisis depuis le fichier
    chosen_indices=($(cat "$CHOSEN_FILE"))

    # Vérifier s'il reste des lignes à choisir
    if [ "${#chosen_indices[@]}" -ge "$total_lines" ]; then
        echo "Toutes les citations ont été choisies."
        return 1
    fi

    while true; do
        # Générer un nombre aléatoire entre 1 et total_lines
        random_index=$((RANDOM % total_lines + 1))

        # Vérifier si cette ligne a déjà été choisie ou si elle est égale au dernier numéro de série
        if [[ ! " ${chosen_indices[@]} " =~ " ${random_index} " ]] && [[ "$random_index" -ne "$LAST_SERIAL" ]]; then
            chosen_indices+=("$random_index")  # Ajouter à la liste des indices choisis
            echo "$random_index"  # Retourner le numéro de la ligne

            # Sauvegarder les indices choisis dans le fichier
            printf "%s\n" "${chosen_indices[@]}" > "$CHOSEN_FILE"

            return 0
        fi
    done
}

touch modifications


# Obtenir les lignes uniques pour les modifications
line_remove=$(get_random_citation)
printf "Ligne à supprimer : $line_remove\n" > "$modifications_file"
#Execution script .choix.sh pour connaître l'indice
annee_line_remove=$(./.choix.sh .encoded_0 $line_remove)
echo "Supprimer la ligne qui correspond à l'$annee_line_remove." > modifications

line_rename=$(get_random_citation)
printf "Ligne à renommer : $line_rename par le dernier chiffre du serial : $LAST_SERIAL\n" >> "$modifications_file"
#Execution script .choix.sh pour connaître l'indice
annee_line_rename=$(./.choix.sh .encoded_0 $line_rename)
echo "Renommer la ligne qui correspond à l'$annee_line_rename par le dernier chiffre du serial." >> modifications

line_remove_quotes=$(get_random_citation)
printf "Ligne pour supprimer les guillemets : $line_remove_quotes\n" >> "$modifications_file"
#Execution script .choix.sh pour connaître l'indice
annee_line_remove_quotes=$(./.choix.sh .encoded_0 $line_remove_quotes)
echo "Supprimer les guillemets de la ligne qui correspond à l'$annee_line_remove_quotes." >> modifications

line_remove_author=$(get_random_citation)
printf "Ligne pour supprimer le nom d'auteur : $line_remove_author\n"  >> "$modifications_file"
#Execution script .choix.sh pour connaître l'indice
annee_line_remove_author=$(./.choix.sh .encoded_0 $line_remove_author)
echo "Supprimer le nom de l'auteur de la citation sur ligne qui correspond à l'$annee_line_remove_author." >> modifications

base64 $modifications_file > .encoded_3
rm $modifications_file

# Supprimer le fichier des indices choisis après utilisation
rm "$CHOSEN_FILE"

# Copier le fichier de citations
temp_file="temp_citation.txt"
cp "$citation_file" "$temp_file"


# 1. Renommer le numéro de la ligne par le dernier chiffre du serial
line_content=$(sed -n "${line_rename}p" "$temp_file") # Récupérer le contenu de la ligne
# Remplacer le numéro actuel par le dernier chiffre du serial
updated_line_content=$(echo "$line_content" | sed -E "s/^[0-9]+\./$LAST_SERIAL./")

# Remplacer la ligne d'origine par la ligne modifiée
sed -i "${line_rename}s/.*/$updated_line_content/" "$temp_file"

# 2. Supprimer les guillemets de la ligne
sed -i "${line_remove_quotes}s/\"//g" "$temp_file"

# 3. Supprimer le nom d'auteur de la ligne
sed -i "/^${line_remove_author}\. /s/ - .*/ - /" "$temp_file"

# Appliquer les modifications sur le fichier copié
# 4. Supprimer la ligne
sed -i "${line_remove}d" "$temp_file"



# Encoder le fichier modifié et le sauvegarder
encoded_file=".encoded_2"
base64 "$temp_file" > "$encoded_file"

# Nettoyage : Supprimer le fichier temporaire
rm "$temp_file"

# echo "Modifications appliquées et encodées dans le fichier $encoded_file."

echo "Le mini-jeu a bien été lancé !"