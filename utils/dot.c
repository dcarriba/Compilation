#include "dot.h"

/*
 * Fonction utilisé par convert_to_dot pour créer le dot d'un noeud et de ses fils
 */
void convert_to_dot_recursive(node *n, FILE *out) {
    if (!n) return;

    /* On crée le noeud en dot */
    fprintf(out, "    %s [label=\"%s\", shape=%s, color=%s, style=%s];\n", n->nom, n->label, n->shape, n->color, n->style);

    /* On parcours les fils du noeud pour les créer ainsi que pour créer les arcs */
    node_list *fils = n->fils;
    while (fils) {
        if (fils->item) {
            fprintf(out, "    %s -> %s;\n", n->nom, fils->item->nom);
            convert_to_dot_recursive(fils->item, out);
        }
        fils = fils->suivant;
    }
}

/*
 * Convertit les arbres abstrait en langage dot
 *
 * Crée le fichier .dot
 */
void convert_to_dot(tree_list *tl, char *dot_file_name) {
    if (!tl) {
        fprintf(stderr, COLOR_YELLOW "[Info] Aucune donnée à convertir en dot.\n" COLOR_RESET);
        return;
    }

    size_t len = strlen(dot_file_name) + 5;
    char *filename = (char *)malloc(len);
    if (!filename) {
        fprintf(stderr, COLOR_RED "[Error] Allocation mémoire échouée pour le nom du fichier dot.\n" COLOR_RESET);
        return;
    }
    snprintf(filename, len, "%s.dot", dot_file_name);

    FILE *out = fopen(filename, "w");
    if (!out) {
        fprintf(stderr, COLOR_RED "[Error] Impossible de créer le fichier %s\n" COLOR_RESET, filename);
        free(filename);
        return;
    }

    /* En enlève les caractères spéciaux comme / . ou - car le nom du digraph ne peut pas les contenir*/
    char *cleaned_name = strdup(dot_file_name);
    if (!cleaned_name) {
        fprintf(stderr, COLOR_RED "[Error] Échec d'allocation mémoire pour cleaned_name.\n" COLOR_RESET);
        exit(EXIT_FAILURE);
    }
    for (char *p = cleaned_name; *p; ++p) {
        if (*p == '/' || *p == '.' || *p == '-') {
            *p = '_';
        }
    }
    fprintf(out, "digraph %s {\n", cleaned_name);
    free(cleaned_name);

    int index = 1;
    tree_list *current = tl;
    while (current) {
        if (current->item && current->item->racine) {
            convert_to_dot_recursive(current->item->racine, out);
        }
        current = current->suivant;
        index++;
    }

    fprintf(out, "}\n");
    fclose(out);

    printf(COLOR_GREEN "Fichier DOT généré avec succés : %s\n" COLOR_RESET, filename);
    free(filename);
}
