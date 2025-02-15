#!/bin/bash

# Compilation de l'analyseur lexical
echo "Compilation de l'analyseur lexical..."
flex ANSI-C.l
gcc -o analyseur_lexic lex.yy.c -lfl

# Vérifier si la compilation a réussi
if [ ! -f analyseur_lexic ]; then
    echo "Erreur: Compilation échouée."
    exit 1
fi

# Vérifier si le dossier Tests existe
if [ ! -d "Tests" ]; then
    echo "Erreur: Le dossier 'Tests' n'existe pas."
    exit 1
fi

# Appliquer l'analyseur lexical à tous les fichiers du dossier Tests
echo "Analyse des fichiers dans le dossier 'Tests'..."
for file in Tests/*; do
    if [ -f "$file" ]; then
        echo "Analyse de: $file"
        ./analyseur_lexic < "$file"
    fi
done

echo "Analyse terminée."
