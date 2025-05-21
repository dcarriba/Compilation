#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tables_symboles.h"

/*
 * Pousse une nouvelle table sur la pile
 */
void push_table(table_t **pile) {
    table_t *t = malloc(sizeof(table_t));
    t->symbole = NULL;
    t->suivant = *pile;
    *pile = t;
}

/*
 * Retire la table au sommet de la pile et libère sa mémoire
 */
void pop_table(table_t **pile) {
    if (*pile) {
        table_t *tmp = *pile;
        *pile = tmp->suivant;
        detruire_table(tmp);
    }
}

/*
 * Renvoie la table au sommet de la pile
 */
table_t* top_table(table_t *pile) {
    return pile;
}

/*
 * Ajoute un symbole à une table donnée
 */
symbole_t* ajouter(table_t *table, char *nom, int aritee, int *taillesTab, type_t type) {
    symbole_t *s = malloc(sizeof(symbole_t));
    s->nom = strdup(nom);
    s->aritee = aritee;
    s->type = type;
    s->taillesTab = NULL;

    if (aritee > 0 && taillesTab != NULL) {
        s->taillesTab = malloc(aritee * sizeof(int));
        for (int i = 0; i < aritee; i++) {
            s->taillesTab[i] = taillesTab[i];
        }
    }

    s->suivant = table->symbole;
    table->symbole = s;
    return s;
}

/*
 * Déclare un symbole dans la table au sommet de la pile
 */
void declarer(table_t *pile, char *nom, int aritee, int *taillesTab, type_t type) {
    if (pile == NULL) {
        fprintf(stderr, "Erreur : pile de symboles vide !\n");
        exit(EXIT_FAILURE);
    }

    if (!rechercher(top_table(pile), nom)) {
        ajouter(top_table(pile), nom, aritee, taillesTab, type);
    }
}

/*
 * Vérifie si un symbole a été déclaré
 */
void verifier_declaration(table_t *pile, char *nom) {
    if (!rechercher_dans_pile(pile, nom)) {
        fprintf(stderr, "Erreur : %s n'a pas été déclarée !\n", nom);
        exit(EXIT_FAILURE);
    }
}

/*
 * Vérifie si le nombre de dimensions est correct
 */
void verifier_dimensions(table_t *pile, char *nom, int nbDemandees) {
    symbole_t *s = rechercher_dans_pile(pile, nom);
    if (!s) {
        fprintf(stderr, "Erreur : %s n'a pas été déclarée !\n", nom);
        exit(EXIT_FAILURE);
    }

    if (s->aritee != nbDemandees) {
        fprintf(stderr, "Erreur : Mauvais nombre de dimensions pour %s. Attendu : %d, fourni : %d\n",
                nom, s->aritee, nbDemandees);
        exit(EXIT_FAILURE);
    }
}

/*
 * Vérifie si les tailles de dimensions sont correctes
 */
void verifier_tailles(table_t *pile, char *nom, int nbDemandees, int *taillesDemandees) {
    symbole_t *s = rechercher_dans_pile(pile, nom);
    if (!s) {
        fprintf(stderr, "Erreur : %s n'a pas été déclarée !\n", nom);
        exit(EXIT_FAILURE);
    }

    if (s->aritee != nbDemandees) {
        fprintf(stderr, "Erreur : Mauvais nombre de dimensions pour %s\n", nom);
        exit(EXIT_FAILURE);
    }

    for (int i = 0; i < nbDemandees; i++) {
        if (s->taillesTab[i] != taillesDemandees[i]) {
            fprintf(stderr, "Erreur : Dimension %d incorrecte pour %s. Attendu : %d, fourni : %d\n",
                    i + 1, nom, s->taillesTab[i], taillesDemandees[i]);
            exit(EXIT_FAILURE);
        }
    }
}

/*
 * Modifie l'aritee d'un symbole
 */
void modifier_aritee(table_t *pile, char *nom, int nouvelleAritee) {
    symbole_t *s = rechercher_dans_pile(pile, nom);
    s->aritee = nouvelleAritee;
}

/*
 * Modifie les tailles de dimensions
 */
void modifier_tailles(table_t *pile, char *nom, int *newTailles) {
    symbole_t *s = rechercher_dans_pile(pile, nom);
    if (s->taillesTab) free(s->taillesTab);
    s->taillesTab = newTailles;
}

/*
 * Recherche un symbole dans une table
 */
symbole_t* rechercher(table_t *table, char *nom) {
    for (symbole_t *s = table->symbole; s != NULL; s = s->suivant) {
        if (strcmp(s->nom, nom) == 0)
            return s;
    }
    return NULL;
}

/*
 * Recherche un symbole dans toute la pile
 */
symbole_t* rechercher_dans_pile(table_t *pile, char *nom) {
    for (table_t *t = pile; t != NULL; t = t->suivant) {
        symbole_t *s = rechercher(t, nom);
        if (s) return s;
    }
    return NULL;
}

/*
 * Supprime un symbole d'une table
 */
void supprimer(table_t *table, char *nom) {
    symbole_t **pp = &table->symbole;
    while (*pp) {
        if (strcmp((*pp)->nom, nom) == 0) {
            symbole_t *tmp = *pp;
            *pp = tmp->suivant;
            if (tmp->taillesTab) free(tmp->taillesTab);
            free(tmp->nom);
            free(tmp);
            return;
        }
        pp = &(*pp)->suivant;
    }
}

/*
 * Libère toute une table
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
 * Taille d'un type
 */
int taille_type(type_t type) {
    switch (type) {
        case INT_T: return 4;
        default: return 0;
    }
}

/*
 * Affiche le contenu de la pile (debug)
 */
void afficher_pile(table_t *pile) {
    int profondeur = 0;
    for (table_t *t = pile; t != NULL; t = t->suivant) {
        printf("Table %d :\n", profondeur++);
        for (symbole_t *s = t->symbole; s != NULL; s = s->suivant) {
            printf("\tNom: %s | Aritée: %d\n", s->nom, s->aritee);
        }
    }
}

/*
 * Libère la pile complète
 */
void liberer_pile(table_t **pile) {
    while (*pile != NULL) {
        pop_table(pile);
    }
}
