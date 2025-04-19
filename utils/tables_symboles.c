#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tables_symboles.h"

static table_t *pile = NULL; /*  pile  */
static int pos = 0;

void push_table() { /* ajout d'une table de symboles */
    table_t *t = (table_t *)malloc(sizeof(table_t));
    t->symboles = NULL;
    t->suivant = pile;
    pile = t;
}

void pop_table() { /*  supprimer la derniere table de symboles de la pile et vider la mem */
    if (pile) {
        table_t *tmp = pile;
        pile = pile->suivant;
        detruire_table(tmp);
    }
}

table_t* top_table() { /* sommet de la pile / derniere tables de symboles */
    return pile;
}

symbole_t* ajouter(table_t *table, char *nom, int aritee, int nbDimensions, int *tailles, type_t type, int is_function) {
    symbole_t *s = malloc(sizeof(symbole_t));
    s->nom = strdup(nom);
    s->aritee = aritee;
    s->nbDimensions = nbDimensions;
    s->is_function = is_function;
    s->type = type;
    s->tailles = NULL;

    if (nbDimensions > 0 && tailles != NULL) {
        s->tailles = malloc(nbDimensions * sizeof(int));
        for (int i = 0; i < nbDimensions; i++) {
            s->tailles[i] = tailles[i];
        }
    }

    s->suivant = table->symboles;
    table->symboles = s;
    return s;
}


void declarer(char *nom, int aritee, int nbDimensions,int *tailles, type_t type,int is_function) {
    if (pile == NULL) {
        fprintf(stderr, "Erreur : pile de symboles vide !\n");
        exit(EXIT_FAILURE);
    }

    if (rechercher(pile, nom)) {
        fprintf(stderr, "Erreur : redéclaration de la variable %s\n", nom);
        exit(EXIT_FAILURE);
    }

    ajouter(pile, nom, aritee, nbDimensions, *tailles,type,is_function);
}

void verifier_declaration(char *nom) {
    if (!rechercher_dans_pile(nom)) {
        fprintf(stderr, "Erreur : %s n’a pas été déclarée !\n", nom);
        exit(EXIT_FAILURE);
    }
}
void verifier_dimensions(char *nom, int nbDemandees) {
    symbole_t *s = rechercher_dans_pile(nom);
    if (!s) {
        fprintf(stderr, "Erreur : %s n’a pas été déclarée !\n", nom);
        exit(EXIT_FAILURE);
    }

    if (s->nbDimensions != nbDemandees) {
        fprintf(stderr, "Erreur : Mauvais nombre de dimensions pour %s. Attendu : %d, fourni : %d\n",
                nom, s->nbDimensions, nbDemandees);
    }
}
void verifier_tailles(char *nom, int nbDemandees, int *taillesDemandees) {
    symbole_t *s = rechercher_dans_pile(nom);
    if (!s) {
        fprintf(stderr, "Erreur : %s n’a pas été déclarée !\n", nom);
        exit(EXIT_FAILURE);
    }

    if (s->nbDimensions != nbDemandees) {
        fprintf(stderr, "Erreur : Mauvais nombre de dimensions pour %s\n", nom);
        exit(EXIT_FAILURE);
    }

    for (int i = 0; i < nbDemandees; i++) {
        if (s->tailles[i] != taillesDemandees[i]) {
            fprintf(stderr, "Erreur : Dimension %d incorrecte pour %s. Attendu : %d, fourni : %d\n",
                    i + 1, nom, s->tailles[i], taillesDemandees[i]);
        }
    }
}





symbole_t* rechercher(table_t *table, char *nom) {  /*  rechercher un symbole dans la table */
    for (symbole_t *s = table->symboles; s != NULL; s = s->suivant) {
        if (strcmp(s->nom, nom) == 0)
            return s;
    }
    return NULL;
}
symbole_t* rechercher_dans_pile(char *nom) {
    for (table_t *t = pile; t != NULL; t = t->suivant) {
        symbole_t *s = rechercher(t, nom);
        if (s) return s;
    }
    return NULL;
}


void supprimer(table_t *table, char *nom) { /*  supprimer un symbole dans la table et vide la mem alloué */
    symbole_t **pp = &table->symboles;
    while (*pp) {
        if (strcmp((*pp)->nom, nom) == 0) {
            symbole_t *tmp = *pp;
            *pp = tmp->suivant;
            if (tmp->tailles != NULL) {
                free(tmp->tailles);
            }
            free(tmp->nom);
            free(tmp);
            return;
        }
        pp = &(*pp)->suivant;
    }
}

void detruire_table(table_t *table) {  /* supprimer une table de symbole et vide la mem alloué */
    symbole_t *s = table->symboles;
    while (s) {
        symbole_t *tmp = s;
        s = s->suivant;
        free(tmp->nom);
        if (tmp->tailles) free(tmp->tailles);
        free(tmp);
    }
    free(table);
}

int taille_type(type_t type) {  /* taille des differents types */
    switch (type) {
        case INT: return 4;
        case STRING: return 8;
        default: return 0;
    }
}

void afficher_pile() {
    int profondeur = 0;
    for (table_t *t = pile; t != NULL; t = t->suivant) {
        printf("Table %d :\n", profondeur++);
        for (symbole_t *s = t->symboles; s != NULL; s = s->suivant) {
            printf("\tNom: %s | Aritee: %d | Dim: %d\n", s->nom, s->aritee, s->nbDimensions);
        }
    }
}

