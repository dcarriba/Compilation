#ifndef TABLES_SYMBOLES_H
#define TABLES_SYMBOLES_H

typedef enum {INT_T, VOID_T} type_t;

typedef struct _symbole_t {
    char *nom;
    int valeur;
    int nbDimensionsTab;
    int *taillesTab;
    int estFonction;
    int nbParametresF;
    type_t type;
    struct _symbole_t *suivant;
} symbole_t;

typedef struct _table_t {
    symbole_t *symbole;
    struct _table_t *suivant;
} table_t;

/* Fonctions pour la gestion des tables/symboles */

symbole_t* ajouter(table_t *table, char *nom, int nbParametresF, int nbDimensionsTab, int *taillesTab, type_t type, int estFonction);
void declarer(char *nom, int nbParametresF, int nbDimensionsTab,int *taillesTab, type_t type,int estFonction);
void verifier_declaration(char *nom);
void verifier_dimensions(char *nom, int nbDemandees);
void verifier_tailles(char *nom, int nbDemandees, int *taillesDemandees);

void modifier_dimensions(char *nom,int nbDimensionsTab);
void modifier_tailles(char *nom, int *newTailles);

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
