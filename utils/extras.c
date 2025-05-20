#include "extras.h"

/*
 * Convertit un int en char*
 */
char *itoa(int value) {
    int length = snprintf(NULL, 0, "%d", value);
    if (length < 0) return NULL;

    char *buffer = malloc(length + 1);
    if (buffer == NULL) return NULL;

    snprintf(buffer, length + 1, "%d", value);

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

    char *result = malloc(total_length + 1);
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



