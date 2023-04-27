#!/bin/bash

# Fonction pour afficher l'aide
usage() {
    echo "Usage: $0 [-r] [-l <log_file>] <common_path> <source_directory> <destination_directory>"
    echo "Options:"
    echo "  -r  Efface et recrée l'arborescence de destination"
    echo "  -l  Enregistre les commandes unitaires dans un fichier de log"
}

# Vérifier les arguments
if [ $# -lt 3 ] || [ $# -gt 6 ]; then
    usage
    exit 1
fi

recreate=0
log_file=""
mode="real"

while getopts "rl:" option; do
    case "${option}" in
        r)
            recreate=1
            ;;
        l)
            log_file="${OPTARG}"
            mode="log"
            rm -f $log_file
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))

common_path="$1"
src_dir="$common_path/$2"
dst_dir="$common_path/$3"

# Vérifier l'existence des répertoires
if [ ! -d "$common_path" ]; then
    echo "Erreur: le répertoire source $common_path n'existe pas."
    exit 2
fi

if [ ! -d "$src_dir" ]; then
    echo "Erreur: le répertoire source $src_dir n'existe pas."
    exit 2
fi

if [ ! -d "$dst_dir" ]; then
    echo "Erreur: le répertoire de destination $dst_dir n'existe pas."
    exit 3
fi

# Effacer et recréer l'arborescence de destination si nécessaire
if [ $recreate -eq 1 ]; then
    echo "Effacement de l'arborescence de destination..."
    rm -rf "$dst_dir"
fi

#header of log file
if [ "$mode" == "log" ]; then
    echo "cp \"$file\" \"$dst_path\"" >> "$log_file" # Enregistrer la commande dans le fichier
fi

# Copier et convertir les fichiers
for file in $(find "$src_dir" -type f \( -iname "*.v" -o -iname "*.sv" -o -iname "*.svh" \)); do
    relative_path="${file#$src_dir/}"
    dst_path="${dst_dir}/${relative_path}"
    if [[ "${file##*.}" == "v" ]]; then
        if [ ! -d "$(dirname "$dst_path")" ]; then
          mkdir -p "$(dirname "$dst_path")" # Créer le dossier s'il n'existe pas
        fi
        if [ "$mode" == "log" ]; then
            echo "cp \".${file/$common_path/}\" \".${dst_path/$common_path/}\"" >> "$log_file"
        else
            cp "$file" "$dst_path"
        fi
    elif [ "${file##*.}" == "sv" ] || [ "${file##*.}" == "svh" ]; then
        if [ "$mode" == "log" ]; then
            echo "cp \".${file/$common_path/}\" \".${dst_path/$common_path/}\"" >> "$log_file"
        fi
        dst_path="${dst_path/%.sv/.v}"
        if [ ! -d "$(dirname "$dst_path")" ]; then
          mkdir -p "$(dirname "$dst_path")" # Créer le dossier s'il n'existe pas
        fi
        if [ "$mode" == "log" ]; then
            echo "sv2v -w adjacent \".${file/$common_path/}\"" >> "$log_file"
            echo "" >> "$log_file"
        else
            sv2v -w "$dst_path" "$file"
        fi
    fi
done

echo "Duplication et conversion terminées."



