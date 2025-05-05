#include "noeud.h"

/*
 * Variable globale utilisé pour l'identifiant unique des noeuds
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
        fprintf(stderr, "Memory allocation failed for node name\n");
        exit(EXIT_FAILURE);
    }

    snprintf(name, length, "node_%d", node_number_digits++);
    return name;
}

/*
 * Crée et renvoie un nouveau noeud
 */
node *create_node(char *label, char *color, int shapeNumber, node *parent, node_list *fils){
    node *n = (node *)malloc(sizeof(node));
    n->nom = unique_node_name();
    n->label = strdup_safe(label);
    n->color = strdup_safe(color);
    n->shapeNumber = shapeNumber;
    n->parent = parent;
    n->fils = fils;
    return n;
}

/*
 * Détruit le neoud et libère son espace mémoire
 */
void destroy_node(node *n){
    free(n->nom);
    free(n->label);
    free(n->color);
    free(n);
}

/*
 * Crée un nouvelle liste de noeuds vide
 */
node_list *new_empty_node_list() {
    node_list *nl = (node_list *)malloc(sizeof(node_list));
    if (!nl) {
        fprintf(stderr, "Erreur : allocation mémoire échouée pour node_list\n");
        exit(EXIT_FAILURE);
    }
    nl->item = NULL;
    nl->suivants = NULL;
    return nl;
}

/*
 * Crée une nouvelle liste de noeuds constitué de tous les neouds en paramètres
 */
node_list *create_node_list(int nbNodes, ...) {
    int i;
    va_list args;
    va_start(args, nbNodes);

    node_list *premier = NULL;
    node_list *current = NULL;

    for (i = 0; i < nbNodes; i++) {
        node *n = va_arg(args, node *);
        
        if (n != NULL) {
            node_list *new_nl = new_empty_node_list();

            new_nl->item = n;

            if (premier == NULL) {
                premier = new_nl;
            } else {
                current->suivants = new_nl; 
            }
            current = new_nl;
        }
    }

    va_end(args);
    return premier;
}

/*
 * Détruit la liste des noeuds et libère l'espace mémoire
 */
void detroy_node_list(node_list *nl){
    node_list *current = nl;
    while (current != NULL) {
        node_list *tmp = current;
        current = current->suivants;
        free(tmp);
    }
}
