#ifndef NOEUD_H
#define NOEUD_H

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>

typedef struct _node {
    char *nom;
    char *label;
    char *color;
    int shapeNumber;
    struct _node *parent;
    struct _node_list *fils;
} node;

typedef struct _node_list {
    node *item;
    struct _node_list *suivants;
} node_list;

node *create_node(char *label, char *color, int shapeNumber, node *parent, node_list *fils);
void destroy_node(node *n);

node_list *new_empty_node_list();
node_list *create_node_list(int nbNodes, ...);
void detroy_node_list(node_list *nl);

#endif
