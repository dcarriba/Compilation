#ifndef TABLES_SYMBOLES_H
#define TABLES_SYMBOLES_H

typedef enum {INT_T, VOID_T} type_t;

typedef struct _symbole_t {
    char *nom;
    int aritee;
    int nbDimensions;
    int *tailles;
    int is_function;
    type_t type;
    struct _symbole_t *suivant;
} symbole_t;

typedef struct _table_t {
    symbole_t *symboles;
    struct _table_t *suivant;
} table_t;

/* Fonctions pour la gestion des tables/symboles */

symbole_t* ajouter(table_t *table, char *nom, int aritee, int nbDimensions, int *tailles, type_t type, int is_function);
void declarer(char *nom, int aritee, int nbDimensions,int *tailles, type_t type,int is_function);
void verifier_declaration(char *nom);
void verifier_dimensions(char *nom, int nbDemandees);
void verifier_tailles(char *nom, int nbDemandees, int *taillesDemandees);
symbole_t* rechercher(table_t *table, char *nom);
void supprimer(table_t *table, char *nom);
int taille_type(type_t type);

/* Fonctions pour gérer la pile des tables de symboles */

symbole_t* rechercher_dans_pile(char *nom);
void push_table();
void pop_table();
table_t* top_table();
void detruire_table(table_t *table);
void afficher_pile();
void liberer_pile();

#endif
