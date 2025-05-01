#!/bin/bash

# Compilation de l'analyseur syntaxique
echo "Compilation de l'analyseur syntaxique..."
yacc -d -o y.tab.c analyse_syntax.y
lex -o lex.yy.c analyse_syntax.l
gcc  lex.yy.c y.tab.c -o analyse_syntax
rm -f lex.yy.c y.tab.c y.tab.h

# Vérifier si la compilation a réussi
if [ ! -f analyse_syntax ]; then
    echo "Erreur: Compilation échouée."
    exit 1
fi

echo "Compilation réussie!"

# Appliquer l'analyseur syntaxique au fichier exempleminiC.c
echo "Analyse de: ../exempleminiC.c"
./analyse_syntax < "../exempleminiC.c"

# Vérifier si Tests existe
if [ ! -d "../Tests" ]; then
    echo "Erreur: Le dossier '../Tests' n'existe pas."
    exit 1
fi

# Appliquer l'analyseur syntaxique aux fichiers .c dans Tests
echo "Analyse des fichiers .c dans le dossier '../Tests'..."
for file in ../Tests/*.c; do
    if [ -f "$file" ]; then
        echo "Analyse de: $file"
        ./analyse_syntax < "$file"
    fi
done

echo "Analyse terminée."
