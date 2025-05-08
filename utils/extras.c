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

char *extraire_nom_base(const char *label) {
    const char *crochet = strchr(label, '[');
    size_t len = (crochet != NULL) ? (size_t)(crochet - label) : strlen(label);

    char *base = malloc(len + 1);
    if (!base) {
        fprintf(stderr, "Erreur : échec d'allocation dans extraire_nom_base\n");
        return NULL;
    }

    strncpy(base, label, len);
    base[len] = '\0';
    return base;
}

int get_nb_dimensions_utilisees(const char *label) {
    int count = 0;
    while ((label = strchr(label, '[')) != NULL) {
        count++;
        label++;
    }
    return count;
}

int get_indice_dimension(const char *label, int i) {
    int current_dim = 0;
    const char *ptr = label;

    while ((ptr = strchr(ptr, '[')) != NULL) {
        ptr++; 
        if (current_dim == i) {
            const char *end = strchr(ptr, ']');
            if (!end) {
                fprintf(stderr, "Erreur : crochet fermant manquant dans get_indice_dimension\n");
                return -1;
            }

            char buffer[32];
            size_t len = end - ptr;
            if (len >= sizeof(buffer)) {
                fprintf(stderr, "Erreur : indice trop long dans get_indice_dimension\n");
                return -1;
            }

            strncpy(buffer, ptr, len);
            buffer[len] = '\0';
            return atoi(buffer);
        }
        current_dim++;
        ptr++; 
    }

    fprintf(stderr, "Erreur : dimension %d non trouvée dans get_indice_dimension\n", i);
    return -1;
}

