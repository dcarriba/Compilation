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

Le compilateur va générer `<fichier>.dot` si le fichier à été compilé sans erreurs.

### Compiler et exécuter sur tous les fichiers tests

Compile et exécute `./compilateur` sur tous les fichiers tests (exempleminiC.c et Tests/*.c).

Génère l'image `.png` de chaque fichier `.dot` généré. 

```bash
make run
```

Dépendance : la commande `dot` est requise. Pour l'installer utilisez la commande suivante :

```bash
sudo apt-get install graphviz
```

### Nettoyer

Supprime l'exécutable ainsi que les fichiers `.dot` et `.png` généré auparavant.

```bash
make clean
```

### Compiler et exécuter avec `valgrind` sur tous les fichiers tests

Compile et exécute `valgrind ./compilateur` sur tous les fichiers tests (exempleminiC.c et Tests/*.c).

Génère l'image `.png` de chaque fichier `.dot` généré.

```bash
make valgrind-run
```

Dépendance : `valgrind` et `dot` sont requis. Pour les installer utilisez les commandes suivantes :

```bash
sudo apt-get install valgrind
sudo apt-get install graphviz
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
