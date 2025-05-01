#!/bin/bash

# Compilation de l'analyseur lexical
echo "Compilation de l'analyseur lexical..."
lex -o analyse_lexic.yy.c analyse_lexic.l 
gcc -o analyse_lexic analyse_lexic.yy.c
rm -f analyse_lexic.yy.c

# Vérifier si la compilation a réussi
if [ ! -f analyse_lexic ]; then
    echo "Erreur: Compilation échouée."
    exit 1
fi

echo "Compilation réussie!"

# Appliquer l'analyseur lexical au fichier exempleminiC.c
echo "Analyse de: ../exempleminiC.c"
./analyse_lexic < "../exempleminiC.c"

# Vérifier si Tests existe
if [ ! -d "../Tests" ]; then
    echo "Erreur: Le dossier '../Tests' n'existe pas."
    exit 1
fi

# Appliquer l'analyseur lexical aux fichiers .c dans Tests
echo "Analyse des fichiers .c dans le dossier '../Tests'..."
for file in ../Tests/*.c; do
    if [ -f "$file" ]; then
        echo "Analyse de: $file"
        ./analyse_lexic < "$file"
    fi
done

echo "Analyse terminée."
