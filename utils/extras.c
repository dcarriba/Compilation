#include "extras.h"

/*
 * Convertit un int en char*
 */
char *itoa(int value) {
    char *buffer = malloc(12); // Espace pour un int 32 bits signé (-2147483648 à 2147483647)
    if (buffer != NULL) {
        sprintf(buffer, "%d", value);  // Convertit int en chaîne
    }
    return buffer;
}

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
