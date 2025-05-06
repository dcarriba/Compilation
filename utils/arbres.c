#include "arbres.h"

/*
 * Crée un arbre avec sa racine
 */
tree *create_tree(node *racine) {
    tree *t = (tree *)malloc(sizeof(tree));
    if (!t) {
        fprintf(stderr, COLOR_RED "[Error] Allocation mémoire échouée pour tree dans create_tree()\n" COLOR_RESET);
        exit(EXIT_FAILURE);
    }
    t->racine = racine;
    return t;
}

/* 
 * Détruit l'arbre et libère son espace mémoire
 */
void destroy_tree(tree *t) {
    if (t) {
        destroy_node(t->racine);
        free(t);
    }
}

/*
 * Crée et renvoie une nouvelle liste d'arbre vide
 */
tree_list *new_empty_tree_list() {
    tree_list *tl = (tree_list *)malloc(sizeof(tree_list));
    if (!tl) {
        fprintf(stderr, COLOR_RED "[Error] Allocation mémoire échouée pour tree_list dans new_empty_tree_list() \n" COLOR_RESET);
        exit(EXIT_FAILURE);
    }
    tl->item = NULL;
    tl->suivant = NULL;
    return tl;
}

/*
 * Ajoute l'arbre au début de la liste 
 */
tree_list *add_tree_to_list(tree_list *tl, tree *t) {
    tree_list *new_tl = (tree_list *)malloc(sizeof(tree_list));
    if (!new_tl) {
        fprintf(stderr, COLOR_RED "[Error] Allocation mémoire échouée pour tree_list dans add_tree_to_list()\n" COLOR_RESET);
        exit(EXIT_FAILURE);
    }
    new_tl->item = t;
    new_tl->suivant = tl;
    return new_tl;
}

/* 
 * Détruit la liste des arbres et libère l'espace mémoire utilisée
 */
void destroy_tree_list(tree_list *tl) {
    tree_list *current = tl;
    while (current != NULL) {
        tree_list *tmp = current;
        destroy_tree(tmp->item);
        current = tmp->suivant;
        free(tmp);
    }
}
