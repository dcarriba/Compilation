#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tables_symboles.h"

static table_t *pile = NULL; /* pile */
static int pos = 0;

/* 
 * Ajout d'une table de symbole 
 */
void push_table() {
    table_t *t = (table_t *)malloc(sizeof(table_t));
    t->symbole = NULL;
    t->suivant = pile;
    pile = t;
}

/* 
 * Pour supprimer la derniere table de symbole de la pile et vider la mem
 */
void pop_table() {
    if (pile) {
        table_t *tmp = pile;
        pile = pile->suivant;
        detruire_table(tmp);
    }
}

/* 
 * Récupère le sommet de la pile, ie. la derniere table de symbole
 */
table_t* top_table() { 
    return pile;
}

/*
 * Pour créer et ajouter un nouveau symbole un table de symbole 
 */
symbole_t* ajouter(table_t *table, char *nom, int nbParametresF, int nbDimensionsTab, int *taillesTab, type_t type, int estFonction) {
    symbole_t *s = malloc(sizeof(symbole_t));
    s->nom = strdup(nom);
    s->nbParametresF = nbParametresF;
    s->nbDimensionsTab = nbDimensionsTab;
    s->estFonction = estFonction;
    s->type = type;
    s->taillesTab = NULL;

    if (nbDimensionsTab > 0 && taillesTab != NULL) {
        s->taillesTab = malloc(nbDimensionsTab * sizeof(int));
        for (int i = 0; i < nbDimensionsTab; i++) {
            s->taillesTab[i] = taillesTab[i];
        }
    }

    s->suivant = table->symbole;
    table->symbole = s;
    return s;
}

void declarer(char *nom, int nbParametresF, int nbDimensionsTab, int *taillesTab, type_t type, int estFonction) {
    if (pile == NULL) {
        fprintf(stderr, "Erreur : pile de symboles vide !\n");
        exit(EXIT_FAILURE);
    }

    if (rechercher(top_table(), nom)) {
        fprintf(stderr, "Erreur : redéclaration de la variable %s\n", nom);
        exit(EXIT_FAILURE);
    }

    ajouter(top_table(), nom, nbParametresF, nbDimensionsTab, taillesTab, type, estFonction);
}

void verifier_declaration(char *nom) {
    if (!rechercher_dans_pile(nom)) {
        fprintf(stderr, "Erreur : %s n'a pas été déclarée !\n", nom);
        exit(EXIT_FAILURE);
    }
}

void verifier_dimensions(char *nom, int nbDemandees) {
    symbole_t *s = rechercher_dans_pile(nom);
    if (!s) {
        fprintf(stderr, "Erreur : %s n'a pas été déclarée !\n", nom);
        exit(EXIT_FAILURE);
    }

    if (s->nbDimensionsTab != nbDemandees) {
        fprintf(stderr, "Erreur : Mauvais nombre de dimensions pour %s. Attendu : %d, fourni : %d\n",
                nom, s->nbDimensionsTab, nbDemandees);
    }
}

void verifier_tailles(char *nom, int nbDemandees, int *taillesDemandees) {
    symbole_t *s = rechercher_dans_pile(nom);
    if (!s) {
        fprintf(stderr, "Erreur : %s n’a pas été déclarée !\n", nom);
        exit(EXIT_FAILURE);
    }

    if (s->nbDimensionsTab != nbDemandees) {
        fprintf(stderr, "Erreur : Mauvais nombre de dimensions pour %s\n", nom);
        exit(EXIT_FAILURE);
    }

    for (int i = 0; i < nbDemandees; i++) {
        if (s->taillesTab[i] != taillesDemandees[i]) {
            fprintf(stderr, "Erreur : Dimension %d incorrecte pour %s. Attendu : %d, fourni : %d\n",
                    i + 1, nom, s->taillesTab[i], taillesDemandees[i]);
        }
    }
}

/*
 * Rechercher un symbole dans la table
 */
symbole_t* rechercher(table_t *table, char *nom) {
    for (symbole_t *s = table->symbole; s != NULL; s = s->suivant) {
        if (strcmp(s->nom, nom) == 0)
            return s;
    }
    return NULL;
}

/*
 * Rechercher un symbole dans toutes les tables sur la pile
 */
symbole_t* rechercher_dans_pile(char *nom) {
    for (table_t *t = pile; t != NULL; t = t->suivant) {
        symbole_t *s = rechercher(t, nom);
        if (s) return s;
    }
    return NULL;
}

/* 
 * Supprimer un symbole dans la table et vide la mem alloué
 */
void supprimer(table_t *table, char *nom) {
    symbole_t **pp = &table->symbole;
    while (*pp) {
        if (strcmp((*pp)->nom, nom) == 0) {
            symbole_t *tmp = *pp;
            *pp = tmp->suivant;
            if (tmp->taillesTab != NULL) {
                free(tmp->taillesTab);
            }
            free(tmp->nom);
            free(tmp);
            return;
        }
        pp = &(*pp)->suivant;
    }
}

/*
 * Supprimer une table de symbole et vide la mem alloué
 */
void detruire_table(table_t *table) {
    symbole_t *s = table->symbole;
    while (s) {
        symbole_t *tmp = s;
        s = s->suivant;
        free(tmp->nom);
        if (tmp->taillesTab) free(tmp->taillesTab);
        free(tmp);
    }
    free(table);
}

/* 
 * Renvoie la taille des differents types
 */
int taille_type(type_t type) {
    switch (type) {
        case INT_T: return 4;
        default: return 0;
    }
}

void afficher_pile() {
    int profondeur = 0;
    for (table_t *t = pile; t != NULL; t = t->suivant) {
        printf("Table %d :\n", profondeur++);
        for (symbole_t *s = t->symbole; s != NULL; s = s->suivant) {
            printf("\tNom: %s | Aritee: %d | Dim: %d\n", s->nom, s->nbParametresF, s->nbDimensionsTab);
        }
    }
}

/*
 * libère la mémoire utilisé par la pile
 */
void liberer_pile(){
    while (pile != NULL) {
        pop_table();
    }
}
