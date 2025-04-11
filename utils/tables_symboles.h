#ifndef TABLES_SYMBOLES_H
#define TABLES_SYMBOLES_H

typedef enum { INT, STRING } type_t;

typedef struct symbole { /* symbole */
    char *nom;
    type_t type;
    int taille;
    int position;
    struct symbole *suivant;
} symbole_t;

typedef struct table { 
    symbole_t *symboles;
    struct table *suivant;
} table_t;

/* Fonctions pour la gestion des tables / symboles */
symbole_t* ajouter(table_t *table, char *nom);
symbole_t* rechercher(table_t *table, char *nom);
void supprimer(table_t *table, char *nom);
int taille_type(type_t type);

/* Fonctions pour gérer la pile des tables de symboles */
void push_table();
void pop_table();
table_t* top_table();
void detruire_table(table_t *table);

#endif
