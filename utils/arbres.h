#ifndef ARBRE_H
#define ARBRE_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "couleurs_terminal.h"
#include "noeuds.h"

typedef struct _tree {
    node *racine; 
} tree;

typedef struct _tree_list {
    tree *item;
    struct _tree_list *suivant;
} tree_list;

tree *create_tree(node *racine);
void destroy_tree(tree *t);

tree_list *new_empty_tree_list();
tree_list *add_tree_to_list(tree_list *tl, tree *t);
void destroy_tree_list(tree_list *tl);

void print_tree_list(tree_list *tl);

#endif 
