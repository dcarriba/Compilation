#ifndef DOT_H
#define DOT_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "couleurs_terminal.h"
#include "noeuds.h"
#include "arbres.h"

void convert_to_dot_recursive(node *n, FILE *out);

void convert_to_dot(tree_list *tl, char *dot_file_name);

#endif
