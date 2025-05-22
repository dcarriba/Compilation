#ifndef TABLES_SYMBOLES_H
#define TABLES_SYMBOLES_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef enum {INT_T, VOID_T} type_t;

typedef struct _symbole_t {
    char *nom;
    int valeur;
    int aritee;             
    int *taillesTab;        
    type_t type;
    struct _symbole_t *suivant;
} symbole_t;

typedef struct _table_t {
    symbole_t *symbole;
    struct _table_t *suivant;
} table_t;

/* Fonctions pour la gestion des symboles dans une table */
symbole_t* ajouter(table_t *table, char *nom, int aritee, int *taillesTab, type_t type);
symbole_t* rechercher(table_t *table, char *nom);
void supprimer(table_t *table, char *nom);
void detruire_table(table_t *table);
int taille_type(type_t type);

/* Fonctions de déclaration et de vérification */
void declarer(table_t *pile, char *nom, int aritee, int *taillesTab, type_t type);
void verifier_declaration(table_t *pile, char *nom);
void verifier_dimensions(table_t *pile, char *nom, int nbDemandees);
void verifier_tailles(table_t *pile, char *nom, int nbDemandees, int *taillesDemandees);
void modifier_aritee(table_t *pile, char *nom, int nouvelleAritee);
void modifier_tailles(table_t *pile, char *nom, int *newTailles);

/* Fonctions pour la gestion de la pile */
void push_table(table_t **pile);
void pop_table(table_t **pile);
table_t* top_table(table_t *pile);
symbole_t* rechercher_dans_pile(table_t *pile, char *nom);
void afficher_pile(table_t *pile);
void liberer_pile(table_t **pile);

#endif
