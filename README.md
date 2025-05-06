# Projet Compilation

Projet pour l'UE Compilation du S6 de la Licence Informatique de l'Université Côte d'Azur

## Auteurs

Bence Di Placido

Daniel Carriba Nosrati

## Instructions pour compiler et exécuter

### Dépendances

`gcc`, `flex` (lex) et `bison` (yacc) sont requis. Pour les installer utilisez les commandes suivantes :

```bash
sudo apt-get install flex                       
sudo apt-get install bison
sudo apt-get install gcc
```

### Compiler

```bash
make
```

### Exécuter

```bash
./compilateur <fichier>
```

### Compiler et exécuter sur tous les fichiers tests (exempleminiC.c et Tests/*.c)

```bash
make run
```

### Supprimer l'exécutable

```bash
make clean
```

### Compiler et exécuter avec `valgrind` sur tous les fichiers tests (exempleminiC.c et Tests/*.c)

```bash
make valgrind-run
```

Dépendance : `valgrind` est requis. Pour l'installer utiliser la commande suivante :

```bash
sudo apt-get install valgrind
```

### Compiler pour pouvoir débugger avec `gdb`

```bash
make gdb
```

ensuite utiliser `gdb` :

```bash
gdb compilateur
```

Pour plus d'informations comment installer et utiliser la commande `gdb` [cliquez ici](https://www.gdbtutorial.com/) 
