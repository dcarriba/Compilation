# Projet Compilation #

Compilateur d'un langage miniC.

Projet pour l'UE Compilation du Semestre 6 de la Licence Informatique de l'Université Côte d'Azur.


- Auteurs : 

Bence Di Placido

Daniel Carriba Nosrati


- Instructions pour compiler et exécuter :


- Dépendances :

gcc, flex (lex) et bison (yacc) sont requis. Pour les installer utilisez les commandes suivantes :

sudo apt-get install flex                       
sudo apt-get install bison
sudo apt-get install gcc


- Compiler :

make


- Exécuter :

./compilateur <fichier>.c

Le compilateur va générer <fichier>.dot si le fichier à été compilé sans erreurs.


- Compiler et exécuter sur tous les fichiers tests :

make run

Compile et exécute ./compilateur sur tous les fichiers tests (exempleminiC.c et Tests/*.c).
Génère le .pdf de chaque fichier .dot généré. 

Dépendance : dot est requis. Pour l'installer utilisez la commande suivante :
sudo apt-get install graphviz


- Nettoyer :

make clean

Supprime l'exécutable ainsi que les fichiers .dot et .pdf généré auparavant.


- Compiler et exécuter avec valgrind sur tous les fichiers tests :

make valgrind-run

Compile et exécute valgrind ./compilateur sur tous les fichiers tests (exempleminiC.c et Tests/*.c).
Génère le .pdf de chaque fichier .dot généré.

Dépendance : valgrind et dot sont requis. Pour les installer utilisez les commandes suivantes :
sudo apt-get install valgrind
sudo apt-get install graphviz


- Compiler et exécuter sur des fichiers tests produisant des erreurs

make run-error

Compile et exécute ./compilateur sur des fichiers tests supplémentaires produisant des erreurs (TestsError/*.c).
Les fichiers seront compilés avec des erreurs, et par conséquent aucun fichier .dot ne sera généré.


- Compiler et exécuter avec valgrind sur des fichiers tests produisant des erreurs

make valgrind-run-error

Compile et exécute valgrind ./compilateur sur des fichiers tests supplémentaires produisant des erreurs (TestsError/*.c).
Les fichiers seront compilés avec des erreurs, et par conséquent aucun fichier .dot ne sera généré.


- Compiler et exécuter sur des fichiers tests produisant des warnings

make run-warning

Compile et exécute ./compilateur sur des fichiers tests supplémentaires produisant des warnings (TestsWarning/*.c).
Génère le .pdf de chaque fichier .dot généré.

Dépendances : valgrind et dot sont requis. Pour les installer utilisez les commandes suivantes :
sudo apt-get install valgrind
sudo apt-get install graphviz


- Compiler et exécuter avec valgrind sur des fichiers tests produisant des warnings

make valgrind-run-warning

Compile et exécute valgrind ./compilateur sur des fichiers tests supplémentaires produisant des warnings (TestsWarning/*.c).
Génère le .pdf de chaque fichier .dot généré.

Dépendances : valgrind et dot sont requis. Pour les installer utilisez les commandes suivantes :
sudo apt-get install valgrind
sudo apt-get install graphviz


- Compiler pour pouvoir débugger :

make debug

Compile avec l'option -g de gcc pour pouvoir débugger.
