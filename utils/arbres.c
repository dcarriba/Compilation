#include "arbres.h"

/*
 * Crée un arbre avec sa racine
 */
tree *create_tree(node *racine) {
    tree *t = malloc(sizeof(tree));
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
    tree_list *tl = malloc(sizeof(tree_list));
    if (!tl) {
        fprintf(stderr, COLOR_RED "[Error] Allocation mémoire échouée pour tree_list dans new_empty_tree_list() \n" COLOR_RESET);
        exit(EXIT_FAILURE);
    }
    tl->item = NULL;
    tl->suivant = NULL;
    return tl;
}

/*
 * Ajoute l'arbre à la fin de la liste 
 */
tree_list *add_tree_to_list(tree_list *tl, tree *t) {
    tree_list *new_tl = malloc(sizeof(tree_list));
    if (!new_tl) {
        fprintf(stderr, COLOR_RED "[Error] Allocation mémoire échouée pour tree_list dans add_tree_to_list()\n" COLOR_RESET);
        exit(EXIT_FAILURE);
    }
    new_tl->item = t;
    new_tl->suivant = NULL;

    if (tl == NULL) {
        return new_tl;
    }

    tree_list *current = tl;
    while (current->suivant != NULL) {
        current = current->suivant;
    }
    current->suivant = new_tl;

    return tl;
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

/*
 * Pour afficher une tree_list dans le terminal
 */
void print_tree_list(tree_list *tl) {
    if (!tl) {
        printf(COLOR_YELLOW "[Info] La liste des arbres est vide.\n" COLOR_RESET);
        return;
    }

    int index = 1;
    tree_list *current = tl;

    while (current) {
        printf(COLOR_CYAN "Arbre #%d\n" COLOR_RESET, index);
        if (current->item && current->item->racine) {
            print_node(current->item->racine);
        } else {
            printf("  (arbre vide ou racine NULL)\n");
        }
        printf("\n");
        current = current->suivant;
        index++;
    }
}
