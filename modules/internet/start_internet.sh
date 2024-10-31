#!/bin/bash

# Vérifier si .can_go existe avant de commencer
if [ ! -f ".can_go" ]; then
    echo "La bombe n'a pas été lancée !"
    exit 1
fi

# Vérifie si chafa est installé
if ! command -v chafa &> /dev/null; then
    echo "Tous les modules ne sont pas installés ! Veuillez vous référez au manuel"
    exit 1
fi

# Remise a zero du jeu
./remise_zero.sh

# Vérifier si le fichier .start_time existe déjà
if [[ ! -f .start_time ]]; then
    start_time=$(date +%s)
    echo $start_time > .start_time
fi


# Décode le fichier GIF pour obtenir le mot
gif_file_base64=$(ls *.gif)
gif_sans_extension=$(basename "$gif_file_base64" .gif)
gif_file=$(echo "$gif_sans_extension" | base64 --decode)
mot=$(echo "$gif_file" | grep -o -E '\w+')

# Fonction pour encoder en base64 le contenu d'un fichier et l'ajouter à .encoded
encode_and_store() {
    local content="$1"
    echo "$content" | base64 >> .encoded
}

# Exécution de l'action en fonction du mot
if [ "$mot" == "vitre" ]; then
    address=$(ping -c 1 telecom.insa-lyon.fr | grep -oP '(\d+\.\d+\.\d+)\.\d+' | head -n 1)
    address="${address%.*}"
    encode_and_store "$address"

elif [ "$mot" == "ville" ]; then
    wget -q https://tinyurl.com/3xhwvhf2
    size=$(stat -c %s 3xhwvhf2)
    rm 3xhwvhf2
    encode_and_store "$size"

elif [ "$mot" == "chose" ]; then
    ping -c 3 x.com > .result
    domain_name="x.com"
    packets_transmitted=$(grep -oP '\d+(?= packets transmitted)' .result)
    encode_and_store "$domain_name"
    encode_and_store "$packets_transmitted"
    rm .result

elif [ "$mot" == "signe" ]; then
    wget -q https://tinyurl.com/3xhwvhf2
    filetype=$(file -b 3xhwvhf2)
    rm 3xhwvhf2
    encode_and_store "$filetype"

elif [ "$mot" == "linge" ]; then
    wget -q https://tinyurl.com/bdcu59dc
    size=$(du -h bdcu59dc | awk '{print $1}' | sed 's/K//')
    rm bdcu59dc
    encode_and_store "$size"

elif [ "$mot" == "ligne" ]; then
    wget -q https://tinyurl.com/496yn2pj
    filetype=$(file -b 496yn2pj)
    rm 496yn2pj
    encode_and_store "$filetype"

elif [ "$mot" == "champ" ]; then
    ping -c 5 google.fr > .result
    domain_name="google.fr"
    packets_transmitted=$(grep -oP '\d+(?= packets transmitted)' .result)
    encode_and_store "$domain_name"
    encode_and_store "$packets_transmitted"
    rm .result

elif [ "$mot" == "litre" ]; then
    address=$(ping -c 1 cpe.fr | grep -oP '(\d+\.\d+\.\d+)\.\d+' | head -n 1)
    # Ne conserver que les trois premiers octets
    address="${address%.*}"
    encode_and_store "$address"

elif [ "$mot" == "chaud" ]; then
    interface_count=$(ip link show | grep -c '^[0-9]')
    encode_and_store "$interface_count"

elif [ "$mot" == "bille" ]; then
    wget -q https://tinyurl.com/4czaz2jz
    size=$(du -h 4czaz2jz | awk '{print $1}' | sed 's/K//')
    rm 4czaz2jz
    encode_and_store "$size"

elif [ "$mot" == "balle" ]; then
    mtu=$(ip link show lo | grep -oP 'mtu \d+' | awk '{print $2}')
    encode_and_store "$mtu"

else
    echo "Mot non reconnu. Aucune action n'a été effectuée."
fi
