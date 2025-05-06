#include "noeuds.h"

/*
 * Variable globale utilisé pour le nom unique (identifiant) des noeuds
 */
int node_number = 0;

/*
 * Fonction sûre de strdup()
 */
static char *strdup_safe(const char *s) {
    if (!s) return NULL;
    char *copy = malloc(strlen(s) + 1);
    if (copy) strcpy(copy, s);
    return copy;
}

/*
 * Génère et renvoie un nom unique pour pouvoir identifier chaque noeud  
 */
char *unique_node_name() {
    int tmp = node_number;
    int node_number_digits = 0;
    if (tmp == 0) node_number_digits = 1;
    while (tmp != 0){
        tmp /= 10;
        node_number_digits++;
    }

    int length = strlen("node_") + node_number_digits + 1;

    char *name = (char *)malloc(length);
    if (!name) {
        fprintf(stderr, COLOR_RED "[Error] Allocation mémoire échouée pour char *name dans unique_node_name()\n" COLOR_RESET);
        exit(EXIT_FAILURE);
    }

    snprintf(name, length, "node_%d", node_number_digits++);
    return name;
}

/*
 * Crée et renvoie un nouveau noeud
 */
node *create_node(char *label, char *shape, char *color, char *style, node_list *fils){
    node *n = (node *)malloc(sizeof(node));
    n->nom = unique_node_name();
    n->label = strdup_safe(label);
    n->shape = strdup_safe(shape);
    n->color = strdup_safe(color);
    n->style = strdup_safe(style);
    n->fils = fils;
    return n;
}

/*
 * Détruit le neoud et libère son espace mémoire
 */
void destroy_node(node *n){
    if (n) {
        if (n->nom) free(n->nom);
        if (n->label) free(n->label);
        if (n->shape) free(n->shape);
        if (n->color) free(n->color);
        if (n->style) free(n->style);
        if (n->fils) destroy_node_list(n->fils);
        free(n);
    }
}

/*
 * Crée un nouvelle liste de noeuds vide
 */
node_list *new_empty_node_list() {
    node_list *nl = (node_list *)malloc(sizeof(node_list));
    if (!nl) {
        fprintf(stderr, COLOR_RED "[Error] Allocation mémoire échouée pour node_list dans new_empty_node_list()\n" COLOR_RESET);
        exit(EXIT_FAILURE);
    }
    nl->item = NULL;
    nl->suivant = NULL;
    return nl;
}

/*
 * Crée une nouvelle liste de noeuds constitué de tous les neouds en paramètres
 */
node_list *create_node_list(int nb_nodes, ...) {
    int i;
    va_list args;
    va_start(args, nb_nodes);

    node_list *first = NULL;
    node_list *current = NULL;

    for (i = 0; i < nb_nodes; i++) {
        node *n = va_arg(args, node *);
        
        if (n != NULL) {
            node_list *new_nl = new_empty_node_list();

            new_nl->item = n;

            if (first == NULL) {
                first = new_nl;
            } else {
                current->suivant = new_nl; 
            }
            current = new_nl;
        }
    }

    va_end(args);
    return first;
}

/*
 * Ajoute le noeud à la fin de la liste 
 */
node_list *add_node_to_list(node_list *nl, node *n) {
    node_list *new_nl = (node_list *)malloc(sizeof(node_list));
    if (!new_nl) {
        fprintf(stderr, COLOR_RED "[Error] Allocation mémoire échouée pour node_list dans add_node_to_list()\n" COLOR_RESET);
        exit(EXIT_FAILURE);
    }
    new_nl->item = n;
    new_nl->suivant = NULL;

    if (nl == NULL) {
        return new_nl;
    }

    node_list *current = nl;
    while (current->suivant != NULL) {
        current = current->suivant;
    }
    current->suivant = new_nl;
    return nl;
}

/*
 * Détruit la liste des noeuds et libère l'espace mémoire
 */
void destroy_node_list(node_list *nl){
    node_list *current = nl;
    while (current != NULL) {
        node_list *tmp = current;
        destroy_node(tmp->item);
        current = tmp->suivant;
        free(tmp);
    }
}
