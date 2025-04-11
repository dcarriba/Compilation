#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tables_symboles.h"

static table_t *pile = NULL; // pile 
static int pos = 0;

void push_table() { //ajout d'une table de symboles
    table_t *t = (table_t *)malloc(sizeof(table_t));
    t->symboles = NULL;
    t->suivant = pile;
    pile = t;
}

void pop_table() { // supprimer la derniere table de symboles de la pile et vider la mem
    if (pile) {
        table_t *tmp = pile;
        pile = pile->suivant;
        detruire_table(tmp);
    }
}

table_t* top_table() { //sommet de la pile / derniere tables de symboles
    return pile;
}

symbole_t* ajouter(table_t *table, char *nom) { //ajouter un symbole a la table
    symbole_t *s = (symbole_t *)malloc(sizeof(symbole_t));
    s->nom = strdup(nom);
    s->suivant = table->symboles;
    table->symboles = s;
    return s;
}

symbole_t* rechercher(table_t *table, char *nom) {  // rechercher un symbole dans la table
    for (symbole_t *s = table->symboles; s != NULL; s = s->suivant) {
        if (strcmp(s->nom, nom) == 0)
            return s;
    }
    return NULL;
}

void supprimer(table_t *table, char *nom) { // supprimer un symbole dans la table et vide la mem alloué
    symbole_t **pp = &table->symboles;
    while (*pp) {
        if (strcmp((*pp)->nom, nom) == 0) {
            symbole_t *tmp = *pp;
            *pp = tmp->suivant;
            free(tmp->nom);
            free(tmp);
            return;
        }
        pp = &(*pp)->suivant;
    }
}

void detruire_table(table_t *table) {  //supprimer une table de symbole et vide la mem alloué
    symbole_t *s = table->symboles;
    while (s) {
        symbole_t *tmp = s;
        s = s->suivant;
        free(tmp->nom);
        free(tmp);
    }
    free(table);
}

int taille_type(type_t type) {  //taille des differents types
    switch (type) {
        case INT: return 4;
        case STRING: return 8;
        default: return 0;
    }
}
