#include "arbresPile.h"
#include <stdlib.h>
#include <string.h>

static char *strdup_safe(const char *s) {
    if (!s) return NULL;
    char *copy = malloc(strlen(s) + 1);
    if (copy) strcpy(copy, s);
    return copy;
}


void nodeEmpiler(nodePile *pile, const char *nom, const char *label, int numero, const char *suivant) {
    if (!pile) {
        fprintf(stderr, "Erreur : Pile non initialisée\n");
        exit(EXIT_FAILURE);
    }

    Node *nouveau = malloc(sizeof(Node));
    if (!nouveau) {
        fprintf(stderr, "Erreur : Allocation mémoire échouée\n");
        exit(EXIT_FAILURE);
    }

    nouveau->nom = strdup_safe(nom);
    nouveau->label = strdup_safe(label);
    nouveau->numero = numero;
    nouveau->suivant = strdup_safe(suivant);
    nouveau->parent = pile->premier;
    pile->premier = nouveau;
}

Node nodeDepiler(nodePile *pile) {
    if (!pile || !pile->premier) {
        fprintf(stderr, "Erreur : Depilement d'une pile vide\n");
        exit(EXIT_FAILURE);
    }

    Node *aDepiler = pile->premier;
    Node copie = *aDepiler;
    pile->premier = aDepiler->parent;
    free(aDepiler); 
    return copie;
}

void nodeAfficherPile(const nodePile *pile) {
    printf("\n--- Pile des noeuds ---\n");
    if (!pile) {
        fprintf(stderr, "Erreur : Pile non initialisée\n");
        exit(EXIT_FAILURE);
    }

    Node *courant = pile->premier;
    while (courant) {
        printf("Nom: %s | Label: %s | Numéro: %d | Suivant: %s\n",
               courant->nom, courant->label, courant->numero,
               courant->suivant ? courant->suivant : "NULL");
        courant = courant->parent;
    }
}

void mettreLienEntreParentEtNom(nodePile *pile, const char *nom, const char *parent) {
    if (!pile) {
        fprintf(stderr, "Erreur : Pile vide\n");
        exit(EXIT_FAILURE);
    }

    Node *courant = pile->premier;
    while (courant) {
        if (strcmp(courant->nom, nom) == 0 && (!courant->suivant || strcmp(courant->suivant, "") == 0)) {
            free(courant->suivant);
            courant->suivant = strdup_safe(parent);
            break;
        }
        courant = courant->parent;
    }
}




void exprEmpiler(exprPile *pile, const char *nom) {
    if (!pile) {
        fprintf(stderr, "Erreur : Pile non initialisée\n");
        exit(EXIT_FAILURE);
    }

    Expr *nouveau = malloc(sizeof(Expr));
    if (!nouveau) {
        fprintf(stderr, "Erreur : Allocation mémoire échouée (Expr)\n");
        exit(EXIT_FAILURE);
    }

    nouveau->nom = strdup_safe(nom);
    nouveau->parent = pile->premier;
    pile->premier = nouveau;
}

Expr exprDepiler(exprPile *pile) {
    if (!pile || !pile->premier) {
        fprintf(stderr, "Erreur : Depilement pile expr vide\n");
        exit(EXIT_FAILURE);
    }

    Expr *aDepiler = pile->premier;
    Expr copie = *aDepiler;
    pile->premier = aDepiler->parent;
    free(aDepiler); 
    return copie;
}

void exprMettreLienEntreParentEtNom(nodePile *pile, exprPile *pile2, const char *parent) {
    if (!pile2) {
        fprintf(stderr, "Erreur : Pile d'expression non initialisée\n");
        exit(EXIT_FAILURE);
    }

    while (pile2->premier) {
        Expr e = exprDepiler(pile2);
        mettreLienEntreParentEtNom(pile, e.nom, parent);
        free(e.nom);
    }
}
