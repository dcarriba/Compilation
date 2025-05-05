#include "arbres.h"
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int numNode = 1;

/* 
 * Concatene des chaines de characteres
 */
char *concat(int nbArgs, ...) {
    int i;
    va_list args;
    va_start(args, nbArgs);

    size_t total_length = 0;
    for (i = 0; i < nbArgs; i++) {
        const char *s = va_arg(args, const char *);
        if (s != NULL) total_length += strlen(s);
    }
    va_end(args);

    char *result = (char *)malloc(total_length + 1);
    if (!result) {
        fprintf(stderr, "Erreur : allocation mémoire échouée dans concat()\n");
        return NULL;
    }

    result[0] = '\0'; /* init string vide */

    va_start(args, nbArgs);
    for (i = 0; i < nbArgs; i++) {
        const char *s = va_arg(args, const char *);
        if (s != NULL) strcat(result, s);
    }
    va_end(args);

    return result;
}

/*
 * Genere un nom unique
 */
char *nodeName() {
    char buffer[32];
    snprintf(buffer, sizeof(buffer), "node_%d", numNode++);
    return strdup(buffer);  
}

/*
 * Applique le style nécésaire au noeud
 */
char *nodeCreat(char *nom, char *label, int numero) {
    const char *shape;
    const char *color;
    const char *style = "solid";

    switch (numero) {
        case 1: shape = "invtrapezium"; color = "blue";  break;
        case 2: shape = "trapezium";    color = "blue";  break;
        case 3: shape = "diamond";      color = "black"; break;
        case 4: shape = "box";          color = "black"; break;
        case 5: shape = "septagon";     color = "black"; break;
        default:shape = "ellipse";      color = "black"; break;
    }

    return concat(
        10,
        nom, 
        "[shape=", shape,
        " label=\"", label,
        "\" style=", style,
        " color=", color,
        "]\n"
    );
}
