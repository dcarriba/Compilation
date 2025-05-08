#ifndef EXTRAS_H
#define EXTRAS_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

char *itoa(int value);
char *concat(int nbArgs, ...);
char *extraire_nom_base(const char *label);
int get_nb_dimensions_utilisees(const char *label);
int get_indice_dimension(const char *label, int i);

#endif
