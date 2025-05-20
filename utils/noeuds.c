#include "noeuds.h"

/*
 * Variable globale utilisé pour le nom unique (identifiant) des noeuds
 */
static int node_number = 0;

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

    char *name = malloc(length);
    if (!name) {
        fprintf(stderr, COLOR_RED "[Error] Allocation mémoire échouée pour char *name dans unique_node_name()\n" COLOR_RESET);
        exit(EXIT_FAILURE);
    }
    
    snprintf(name, length, "node_%d", node_number++);
    return name;
}

/*
 * Crée et renvoie un nouveau noeud
 */
node *create_node(char *label, char *shape, char *color, char *style, node_list *fils){
    node *n = malloc(sizeof(node));
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
    node_list *nl = malloc(sizeof(node_list));
    if (!nl) {
        fprintf(stderr, COLOR_RED "[Error] Allocation mémoire échouée pour node_list dans new_empty_node_list()\n" COLOR_RESET);
        exit(EXIT_FAILURE);
    }
    nl->item = NULL;
    nl->suivant = NULL;
    return nl;
}

/*
 * Renvoie la longueur (le nombre d'éléments) d'une node_list
 */
int length_of_node_list(node_list *nl) {
    int length = 0;
    node_list *current = nl;
    while (current != NULL) {
        length++;
        current = current->suivant;
    }
    return length;
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
    node_list *new_nl = malloc(sizeof(node_list));
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

/*
 * Fonction utilisé par print_node pour afficher les fils et petits-fils récursivement
 */
void print_node_recursive(node *n, int indent_level) {
    if (!n) return;

    // Indentation visuelle
    for (int i = 0; i < indent_level; i++) {
        printf("  ");
    }

    // Affichage du noeud courant
    printf(COLOR_YELLOW "Node Name: %s\n" COLOR_RESET, n->nom);
    for (int i = 0; i < indent_level; i++) printf("  ");
    printf("  Label : %s\n", n->label);
    for (int i = 0; i < indent_level; i++) printf("  ");
    printf("  Shape : %s\n", n->shape);
    for (int i = 0; i < indent_level; i++) printf("  ");
    printf("  Color : %s\n", n->color);
    for (int i = 0; i < indent_level; i++) printf("  ");
    printf("  Style : %s\n", n->style);

    // Appel récursif sur les fils
    if (n->fils) {
        node_list *fils = n->fils;
        while (fils) {
            print_node_recursive(fils->item, indent_level + 1);
            fils = fils->suivant;
        }
    }
}

/*
 * Pour afficher un noeud ainsi que tout ses fils et petits-fils etc. dans le terminal
 */
void print_node(node *n) {
    print_node_recursive(n, 0);
}



char *extraire_nom_base(node *var) {
    if (!var) return NULL;
    if (strcmp(var->label, "TAB") == 0 && var->fils && var->fils->item) {
        return var->fils->item->label; 
    }
    return var->label;  
}

int get_nb_dimensions_utilisees(node *var) {
    if (!var || strcmp(var->label, "TAB") != 0) return 0;
    int count = 0;
    node_list *cur = var->fils;
    if (cur) cur = cur->suivant;  
    while (cur) {
        count++;
        cur = cur->suivant;
    }
    return count;
}

int get_indice_dimension(node *var, int dim) {
    if (!var || strcmp(var->label, "TAB") != 0) return -1;
    node_list *cur = var->fils;
    if (!cur) return -1;

    cur = cur->suivant; 
    for (int i = 0; i < dim && cur; i++) {
        cur = cur->suivant;
    }

    if (!cur || !cur->item || !cur->item->label) return -1;
    return atoi(cur->item->label);  
}

