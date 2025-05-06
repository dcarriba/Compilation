#ifndef NOEUD_H
#define NOEUD_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include "couleurs_terminal.h"

typedef struct _node {
    char *nom;
    char *label;
    char *shape;
    char *color;
    char *style;
    struct _node_list *fils;
} node;

typedef struct _node_list {
    node *item;
    struct _node_list *suivant;
} node_list;

node *create_node(char *label, char *shape, char *color, char *style, node_list *fils);
void destroy_node(node *n);

node_list *new_empty_node_list();
node_list *create_node_list(int nb_nodes, ...);
node_list *add_node_to_list(node_list *nl, node *n);
void destroy_node_list(node_list *nl);

#endif
