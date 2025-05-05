#ifndef ARBRESPILE_H
#define ARBRESPILE_H

#include <stdio.h>


typedef struct Node {
    char *nom;
    char *label;
    int numero;
    char *suivant;
    struct Node *parent;
} Node;

typedef struct {
    Node *premier;
} nodePile;


typedef struct Expr {
    char *nom;
    struct Expr *parent;
} Expr;

typedef struct {
    Expr *premier;
    Expr *parent;
} exprPile;


void nodeEmpiler(nodePile *pile, const char *nom, const char *label, int numero, const char *suivant);
Node nodeDepiler(nodePile *pile);
void nodeAfficherPile(const nodePile *pile);
void lienEntreParentEtNom(nodePile *pile, const char *nom, const char *parent);

void exprEmpiler(exprPile *pile, const char *nom);
Expr exprDepiler(exprPile *pile);
void exprLienEntreParentEtNom(nodePile *pile, exprPile *pile2, const char *parent);

#endif
