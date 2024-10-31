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

# Tableau de couleurs
couleurs=("rouge" "jaune" "noir" "bleu" "vert" "blanc")

# 1. Choisir aléatoirement entre 3 et 4 fichiers
nombre_de_fichiers=$((RANDOM % 2 + 3))  # Génère 3 ou 4 fichiers

# 2. Initialiser le tableau pour stocker les fichiers générés
fichiers=()

# 3. Générer des fichiers aléatoires selon le nombre choisi
for i in $(seq 1 $nombre_de_fichiers); do
    couleur=${couleurs[RANDOM % ${#couleurs[@]}]}  # Couleur aléatoire

    # Assigner des probabilités pour les 3 fichiers
    if [[ $nombre_de_fichiers -eq 3 ]]; then
        if [[ $i -eq 1 ]]; then
            # Premier fil (60% bleu, 30% rouge, 10% autre)
            random_num=$((RANDOM % 100))
            if [[ $random_num -lt 60 ]]; then
                couleur="bleu"
            elif [[ $random_num -lt 90 ]]; then
                couleur="rouge"
            fi
        elif [[ $i -eq 2 ]]; then
            # Deuxième fil (50% rouge, 40% bleu, 10% autre)
            random_num=$((RANDOM % 100))
            if [[ $random_num -lt 50 ]]; then
                couleur="rouge"
            elif [[ $random_num -lt 90 ]]; then
                couleur="bleu"
            fi
        elif [[ $i -eq 3 ]]; then
            # Dernier fil (40% blanc, 20% rouge, 20% bleu, 20% autre)
            random_num=$((RANDOM % 100))
            if [[ $random_num -lt 40 ]]; then
                couleur="blanc"
            elif [[ $random_num -lt 60 ]]; then
                couleur="rouge"
            elif [[ $random_num -lt 80 ]]; then
                couleur="bleu"
            fi
        fi
    elif [[ $nombre_de_fichiers -eq 4 ]]; then
        if [[ $i -eq 1 ]]; then
                # Premier fil (plus de chance d'avoir du rouge)
                random_num=$((RANDOM % 100))
                if [[ $random_num -lt 60 ]]; then
                    couleur="rouge"
                fi
        elif [[ $i -eq 2 ]]; then
                # Deuxième fil (chances égales pour toutes les couleurs)
                couleur=${couleurs[RANDOM % ${#couleurs[@]}]}
                if [[ $random_num -lt 30 ]]; then
                    couleur="bleu"
                fi
        elif [[ $i -eq 3 ]]; then
                # Troisième fil (40% rouge, 20% bleu, 20% jaune, 20% autre)
                random_num=$((RANDOM % 100))
                if [[ $random_num -lt 40 ]]; then
                couleur="rouge"
                elif [[ $random_num -lt 60 ]]; then
                    couleur="bleu"
                elif [[ $random_num -lt 80 ]]; then
                    couleur="jaune"
                fi
        elif [[ $i -eq 4 ]]; then
                # Quatrième fil (plus de chance d'avoir du jaune)
                random_num=$((RANDOM % 100))
                if [[ $random_num -lt 60 ]]; then
                    couleur="jaune"
                fi
        fi
    fi

    nom_fichier="${i}_${couleur}.txt"
    touch "$nom_fichier"
    fichiers+=("$nom_fichier")
done


# Règles pour les conditions de victoire
# 4. Lecture du numéro de série
if [ -f ".serial" ]; then
    serial=$(cat .serial)
    dernier_chiffre_serial=${serial: -1}  # Récupérer le dernier chiffre
else
    echo "Erreur : fichier .serial introuvable."
    exit 1
fi

# Initialiser variables pour analyser la condition de victoire
condition_a_verifier=""
fichier_a_supprimer=""

# 5. Vérification pour 3 fichiers
if [[ $nombre_de_fichiers -eq 3 ]]; then
    has_red=false
    for fichier in "${fichiers[@]}"; do
        if [[ "$fichier" =~ "_rouge.txt" ]]; then
            has_red=true
            break
        fi
    done

    if [[ ! "$has_red" ]]; then
        # S'il n'y a pas de fil rouge
        condition_a_verifier="Il n'y a pas de fil rouge. Vous devez supprimer le deuxième fichier."
        fichier_a_supprimer="${fichiers[1]}"
    else
        # Compter les fils bleus
        count_bleu=0
        for fichier in "${fichiers[@]}"; do
            if [[ "$fichier" =~ "_bleu.txt" ]]; then
                ((count_bleu++))
            fi
        done

        if [[ $count_bleu -gt 1 ]]; then
            # Plus d'un fil bleu
            condition_a_verifier="Plus d'un fil bleu. Vous devez supprimer le dernier fichier bleu."
            for ((j=${#fichiers[@]}-1; j>=0; j--)); do
                if [[ "${fichiers[j]}" =~ "_bleu.txt" ]]; then
                    fichier_a_supprimer="${fichiers[j]}"
                    break
                fi
            done
        elif [[ "${fichiers[-1]}" =~ "_blanc.txt" ]]; then
            # Dernier fichier est blanc
            condition_a_verifier="Le dernier fil est blanc. Vous devez supprimer le dernier fichier."
            fichier_a_supprimer="${fichiers[-1]}"
        else
            # Par défaut, supprimer le premier fichier
            condition_a_verifier="Aucune autre condition remplie. Vous devez supprimer le premier fichier."
            fichier_a_supprimer="${fichiers[0]}"
        fi
    fi
fi

# 6. Vérification pour 4 fichiers
if [[ $nombre_de_fichiers -eq 4 ]]; then
    # Compter les fils rouges
    count_red=0
    count_bleu=0
    count_jaune=0
    for fichier in "${fichiers[@]}"; do
        if [[ "$fichier" =~ "_rouge.txt" ]]; then
            ((count_red++))
        elif [[ "$fichier" =~ "_bleu.txt" ]]; then
            ((count_bleu++))
        elif [[ "$fichier" =~ "_jaune.txt" ]]; then
            ((count_jaune++))
        fi
    done

    # Condition 1 : + d'un fil rouge et dernier chiffre impair
    if [[ $count_red -gt 1 && $((dernier_chiffre_serial % 2)) -ne 0 ]]; then
        condition_a_verifier="Il y a plus d'un fil rouge et le dernier chiffre du serial est impair. Couper le dernier fil rouge."
        for ((j=${#fichiers[@]}-1; j>=0; j--)); do
            if [[ "${fichiers[j]}" =~ "_rouge.txt" ]]; then
                fichier_a_supprimer="${fichiers[j]}"
                break
            fi
        done

    # Condition 2 : dernier fil jaune et aucun fil rouge
    elif [[ "${fichiers[-1]}" =~ "_jaune.txt" && $count_red -eq 0 ]]; then
        condition_a_verifier="Le dernier fil est jaune et il n'y a pas de fil rouge. Vous devez supprimer le premier fichier."
        fichier_a_supprimer="${fichiers[0]}"

    # Condition 3 : exactement un fil bleu
    elif [[ $count_bleu -eq 1 ]]; then
        condition_a_verifier="Il y a exactement un fil bleu. Vous devez couper le premier fichier."
        fichier_a_supprimer="${fichiers[0]}"

    # Condition 4 : plus d'un fil jaune
    elif [[ $count_jaune -gt 1 ]]; then
        condition_a_verifier="Il y a plus d'un fil jaune. Vous devez couper le dernier fichier."
        fichier_a_supprimer="${fichiers[-1]}"

    # Condition 5 : couper le deuxième fichier
    else
        condition_a_verifier="Aucune autre condition remplie. Vous devez couper le deuxième fichier."
        fichier_a_supprimer="${fichiers[1]}"
    fi
fi


# 7. Afficher et encoder le fichier à supprimer
if [[ -n "$fichier_a_supprimer" ]]; then
    # echo "$condition_a_verifier (Fichier à supprimer : $fichier_a_supprimer)"
    
    # Encoder et écrire dans .encoded_1
    echo "$fichier_a_supprimer" | base64 > .encoded_1

    # Encoder et écrire dans .encoded_2
    printf "%s\n" "${fichiers[@]}" | base64 > .encoded_2
else
    echo "Aucun fichier à supprimer n'a été déterminé."
fi
