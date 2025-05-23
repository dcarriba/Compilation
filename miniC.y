%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "utils/couleurs_terminal.h"
#include "utils/tables_symboles.h"
#include "utils/noeuds.h"
#include "utils/arbres.h"
#include "utils/extras.h"
#include "utils/dot.h"

extern FILE *yyin;
extern int yylineno;
int yylex();
int yyerror();
int yylex_destroy();

int error = 0;

/* Fichier .c en entrée */
FILE* fichier = NULL;

/* Arbre abstrait du programme .c en entrée */
tree_list *arbre_abstrait = NULL;

/* Pile avec les tables de symboles des variables */
table_t *pile_tables_variables = NULL;
/* Pile avec les tables de symboles des fonctions */
table_t *pile_tables_fonctions = NULL;

/* Variables globales utile pour gérer des erreurs sémantiques*/
int n_param = 0;
int is_void = 0;
int is_int = 0;
int has_return = 0;

int nb_dim = 0;
int *tailles;

void warning(char *s){
    fprintf(stdout, COLOR_MAGENTA "[Warning] %s - ligne %d\n" COLOR_RESET, s, yylineno);
}

int yyerror(char *s){
    fprintf(stderr, COLOR_RED "[Error] %s - ligne %d\n" COLOR_RESET, s, yylineno);
    error++;
    return 0;
}

%}

%union {
    char *str;
    char *var;
    int ival;
    node *noeud;
    node_list *liste_noeuds;
    tree *arbre;
    tree_list *liste_arbres;
}

%type<liste_arbres> programme liste_fonctions
%type<arbre> fonction
%type<liste_noeuds> liste_instructions l_instructions liste_expressions l_expr liste_parms l_parms tableau liste_switch_case
%type<noeud> appel instruction iteration selection condition bloc affectation variable expression saut parm switch_case
%type<str> type binary_comp
%type<var> declarateur declarationfonction case_constante

%token<var> IDENTIFICATEUR
%token<ival> CONSTANTE
%token VOID INT
%token FOR WHILE IF ELSE SWITCH CASE DEFAULT
%token BREAK RETURN
%token PLUS MOINS MUL DIV LSHIFT RSHIFT BAND BOR LAND LOR LT GT 
%token GEQ LEQ EQ NEQ 
%token NOT EXTERN

%left PLUS MOINS
%left MUL DIV
%left LSHIFT RSHIFT
%left BOR
%left BAND
%left LOR
%left LAND
%nonassoc THEN
%nonassoc ELSE
%nonassoc MOINSUNAIRE
%start programme

%destructor {
    if (error && $$) free($$);
} <var>

%destructor {
    if (error && $$) destroy_node($$);
} <noeud>

%destructor {
    if (error && $$) destroy_node_list($$);
} <liste_noeuds>

%destructor {
    if (error && $$) destroy_tree($$);
} <arbre>

%destructor { 
    if (error && $$) {
        destroy_tree_list($$);
        arbre_abstrait = NULL; 
    }
} <liste_arbres>

%%
push : 
        { 
            push_table(&pile_tables_variables);
        }
;

pop :
        { 
            pop_table(&pile_tables_variables); 
        }
;

pushf : 
        { 
            push_table(&pile_tables_fonctions);
        }
;

popf :
        { 
            pop_table(&pile_tables_fonctions); 
        }
;

programme:
        pushf push liste_declarations liste_fonctions pop popf
        {
            arbre_abstrait = $4;
            $$ = $4;
        }
;

liste_declarations:
        liste_declarations declaration
        {

        }
    |   
        { 

        }
;

liste_fonctions:
        liste_fonctions fonction
        {
            tree_list *tl = add_tree_to_list($1, $2);
            $$ = tl;
        }
    |   fonction
        {
            tree_list *tl = add_tree_to_list(new_empty_tree_list(), $1);
            $$ = tl;
        }
;

declaration:
        type liste_declarateurs ';'  
        {
            if(strcmp($1, "void") == 0) {
                yyerror("Une variable ne peux pas être déclarée avec le type void");
            }
        }
;

liste_declarateurs:
        liste_declarateurs ',' declarateur
        {
            symbole_t *s = rechercher(pile_tables_variables, $3);
            if (s != NULL) {
                char *err = concat(3, "La variable ", $3, " a déjà été déclarée dans le même bloc");
                yyerror(err);
                free(err);
            }
            
            declarer(pile_tables_variables, $3, nb_dim, tailles, INT_T);
            free(tailles);
            tailles = NULL;
            nb_dim = 0;
            free($3);
        }
    |   declarateur
        {
            symbole_t *s = rechercher(pile_tables_variables, $1);
            if (s != NULL) {
                char *err = concat(3, "La variable ", $1, " a déjà été déclarée dans le même bloc");
                yyerror(err);
                free(err);
            }

            declarer(pile_tables_variables, $1, nb_dim, tailles, INT_T);
            free(tailles);
            tailles = NULL;
            nb_dim = 0;
            free($1);
        }
;


declarateur:
        IDENTIFICATEUR
        {
            $$ = $1;
        }
    |   declarateur '[' CONSTANTE ']'
        {
            nb_dim++;
            tailles = realloc(tailles, nb_dim * sizeof(int));
            if (!tailles) {
                yyerror("Erreur de réallocation de mémoire pour les tailles du tableau");
            }
            tailles[nb_dim - 1] = $3;
            $$ = $1;
        }
;

declarationfonction : 
        type IDENTIFICATEUR '(' push liste_parms ')'
        {
            symbole_t *s = rechercher(pile_tables_fonctions, $2);
            if (s != NULL) {
                char *err = concat(3, "La fonction ", $2, " a déjà été déclarée");
                yyerror(err);
                free(err);
            }

            if (strcmp($1, "int") == 0) {
                declarer(pile_tables_fonctions, $2, length_of_node_list($5), NULL, INT_T);
                is_void = 0;
                is_int = 1; 
            } else if (strcmp($1, "void") == 0) {
                declarer(pile_tables_fonctions, $2, length_of_node_list($5), NULL, VOID_T);
                is_void = 1;
                is_int = 0; 
            }

            int len = strlen($2) + strlen(", ") + strlen($1) + 1;
            char *label = malloc(len);
            snprintf(label, len, "%s, %s", $2, $1);

            free($2);
            destroy_node_list($5);

            $$ = label;
        }
;

fonction:
        declarationfonction '{' liste_declarations liste_instructions pop'}' 
        {
            if (is_void == 0 && is_int == 1 && has_return == 0) {
                warning("Absence de return pour une fonction de type int");
            } 

            has_return = 0;

            node *bloc= create_node("BLOC", "ellipse", "black", "solid", $4);

            node *fonction = create_node($1, "invtrapezium", "blue", "solid", create_node_list(1, bloc));
            free($1);

            tree *t = create_tree(fonction);
            $$ = t;
        }
    |   EXTERN type IDENTIFICATEUR '(' liste_parms ')' ';'
        {
            symbole_t *s = rechercher(pile_tables_fonctions, $3);
            if (s != NULL) {
                char *err = concat(3, "La fonction ", $3, " a déjà été déclarée");
                yyerror(err);
                free(err);
            }

            if (strcmp($2, "int") == 0) {
                declarer(pile_tables_fonctions, $3, length_of_node_list($5), NULL, INT_T);
            } else if (strcmp($2, "void") == 0) {
                declarer(pile_tables_fonctions, $3, length_of_node_list($5), NULL, VOID_T);
            }

            free($3);
            destroy_node_list($5);
            
            $$ = NULL;
        }
;

type:
        VOID 
        {
            $$ = "void";
            
        }
    |   INT 
        {       
            $$ = "int";
        }
;

liste_parms:
        l_parms
        {
            $$ = $1;
        }
    |
        {
            $$ = NULL;
        }
;

l_parms :
        l_parms ',' parm
        {
            $$ = add_node_to_list($1, $3);
        }
    |   parm
        {
            $$ = create_node_list(1, $1);
        }
;

parm:
        INT IDENTIFICATEUR
        {   
            declarer(pile_tables_variables, $2, nb_dim, tailles, INT_T);
            n_param++;
            node *n = create_node($2, "ellipse", "black", "solid", NULL);
            free($2);
            $$ = n;
        }
;

liste_instructions :
        l_instructions
        {
            $$ = $1;
        }
    |
        {
            $$ = NULL;
        }
;

l_instructions :
        l_instructions instruction
        {
            $$ = add_node_to_list($1, $2);
        }
    |   instruction
        {
            $$ = create_node_list(1, $1);
        }

instruction:
        iteration
        {
            $$ = $1;
        }
    |   selection
        {
            $$ = $1;
        }
    |   saut
        {
            $$ = $1;
        }
    |   affectation ';'
        {
            $$ = $1;
        }
    |   bloc
        {
            $$ = $1;
        }
    |   appel
        {
            $$ = $1;
        }
;

iteration:
        FOR '(' affectation ';' condition ';' affectation ')' instruction
        {
            node_list *fils = create_node_list(4, $3, $5, $7, $9);
            node *n = create_node("FOR", "ellipse", "black", "solid", fils);
            $$ = n;
        }
    |   WHILE '(' condition ')' instruction
        {
            node_list *fils = create_node_list(2, $3, $5);
            node *n = create_node("WHILE", "ellipse", "black", "solid", fils);
            $$ = n;
        }
;

selection:
        IF '(' condition ')' instruction %prec THEN
        {
            node_list *fils = create_node_list(2, $3, $5);
            node *n = create_node("IF", "diamond", "black", "solid", fils);
            $$ = n;
        }
    |   IF '(' condition ')' instruction ELSE instruction
        {
            node_list *fils = create_node_list(3, $3, $5, $7);
            node *n = create_node("IF", "diamond", "black", "solid", fils);
            $$ = n;
        }
    |   SWITCH '(' expression ')' '{' push liste_switch_case pop '}'
        {
            node_list *fils = new_empty_node_list();
            fils->item = $3;
            fils->suivant = $7;
            node *n = create_node("SWITCH", "ellipse", "black", "solid", fils);
            $$ = n;
        }
;

liste_switch_case:
        switch_case
        {
            node_list *nl = create_node_list(1, $1);
            $$ = nl;
        }
    |   liste_switch_case switch_case
        {
            node_list *nl = add_node_to_list($1, $2);
            $$ = nl;
        }
;

switch_case:
        case_constante ':' liste_instructions
        {
            node *n = create_node($1, "ellipse", "black", "solid", $3);
            free($1);
            $$ = n;
        }
    |   default ':' liste_instructions
        {
            node *n = create_node("case default", "ellipse", "black", "solid", $3);
            $$ = n;
        }
;

case_constante:
        CASE CONSTANTE
        {   
            char *cons = itoa($2);

            symbole_t *s = rechercher(pile_tables_variables, cons);
            if(s != NULL){
                char *err = concat(3, "La case ", cons, " est déjà présente dans ce switch");
                yyerror(err);
                free(err);
            }
            
            declarer(pile_tables_variables, cons, 0, tailles, INT_T);
            free(cons);

            char *case_num = itoa($2);
            int len = strlen("case ") + strlen(case_num) + 1;
            char *label = malloc(len);
            snprintf(label, len, "case %s", case_num);
            free(case_num);
            
            $$ = label;
        }
;

default:
        DEFAULT
        {   
            symbole_t *s = rechercher(pile_tables_variables, "default");
            if(s != NULL){
                yyerror("Plusieurs default présent dans le même switch");
            }
            declarer(pile_tables_variables, "default", 0, tailles, INT_T);
        }
;

saut:
        BREAK ';' 
        {
            node *n = create_node("BREAK", "box", "black", "solid", NULL);
            $$ = n;
        }
    |   RETURN ';' 
        {
            has_return = 0;

            node *n = create_node("RETURN", "trapezium", "blue", "solid", NULL);
            $$ = n;
        }
    |   RETURN expression ';' 
        {
            has_return = 1;

            if (is_void == 1 && is_int == 0 && has_return == 1) {
                warning("Présence d'un return avec une expression de type int dans une fonction de type void");
            }

            node_list *fils = create_node_list(1, $2);
            node *n = create_node("RETURN", "trapezium", "blue", "solid", fils);
            $$ = n;
        }
;

affectation:
        variable '=' expression 
        {   
            symbole_t *s = rechercher_dans_pile(pile_tables_variables, extraire_nom_base($1));
            if (!s) {
                char *war = concat(3, "Variable ", extraire_nom_base($1), " non déclarée");
                warning(war);
                free(war);
            } else {
                int nb_dim_util = get_nb_dimensions_utilisees($1);
                if (nb_dim_util > s->aritee) {
                    char *nb_dim_util_str = itoa(nb_dim_util);
                    char *s_aritee_str = itoa(s->aritee);
                    char *err = concat(6, "Variable ", extraire_nom_base($1), " a une dimension de ", s_aritee_str, " et non ", nb_dim_util_str);
                    free(nb_dim_util_str);
                    free(s_aritee_str);
                    yyerror(err);
                    free(err);
                } else if (nb_dim_util <= s->aritee && nb_dim_util !=0) {
                    for (int i = 0; i < nb_dim_util; i++) {
                        int indice = get_indice_dimension($1, i);
                        if (indice >= s->taillesTab[i] || indice < 0) {
                            char *incice_str = itoa(indice);
                            char *s_taillesTab_str = itoa(s->taillesTab[i]);
                            char *i_plus_1_str = itoa(i+1);
                            char *war;
                            if (indice < 0) {
                                war = concat(5, "Accés à un indice négatif d'un tableau de taille ", s_taillesTab_str, " (dimension ", i_plus_1_str," du tableau)");
                            } else {
                                war = concat(7, "Accés à l'indice ", incice_str, " d'un tableau de taille ", s_taillesTab_str, " (dimension ", i_plus_1_str," du tableau)");
                            }
                            free(incice_str);
                            free(s_taillesTab_str);
                            free(i_plus_1_str);
                            warning(war);
                            free(war);
                        }
                    }
                }
            }
        
            node_list *fils = create_node_list(2, $1, $3);
            node *n = create_node(":=", "ellipse", "black", "solid", fils);
            $$ = n;
        }
;

bloc:
        '{' push liste_declarations liste_instructions pop '}'
        {
            $$ = create_node("BLOC", "ellipse", "black", "solid", $4);
        }
;

appel:
        IDENTIFICATEUR '(' liste_expressions ')' ';'
        {   
            symbole_t *a = rechercher_dans_pile(pile_tables_fonctions, $1);
            if (a == NULL){
                char *war = concat(3, "Fonction ", $1, " non déclarée");
                warning(war);
                free(war);
            }
            if (a->aritee != length_of_node_list($3)) {
                char *aritee = itoa(a->aritee);
                char *len = itoa(length_of_node_list($3));
                char *war = concat(6, "Fonction ", $1, " appelée avec ", len, " paramètres au lieu de ", aritee);
                warning(war);
                free(len);
                free(aritee);
                free(war);
            }
            node *n = create_node($1, "septagon", "black", "solid", $3);
            free($1);
            $$ = n;
        }
;

variable:
        IDENTIFICATEUR
        {
            node *n = create_node($1, "ellipse", "black", "solid", NULL);
            free($1);
            $$ = n;
        }
    |   tableau 
        {
            node *n = create_node("TAB", "ellipse", "black", "solid", $1);
            $$ = n;
        }
;

tableau:
        IDENTIFICATEUR '[' expression ']'
        {
            node *n = create_node($1, "ellipse", "black", "solid", NULL);
            free($1);
            node_list *nl = create_node_list(2, n, $3);
            $$ = nl;
        }
    |   tableau '[' expression ']'
        {
            node_list *nl = add_node_to_list($1, $3);
            $$ = nl;
        }
;

expression:
        '(' expression ')' 
        {
            $$ = $2;
        }
    |   expression PLUS expression
        {
            node_list *fils = create_node_list(2, $1, $3);
            node *n = create_node("+", "ellipse", "black", "solid", fils);
            $$ = n;
        }
    |   expression MOINS expression
        {
            node_list *fils = create_node_list(2, $1, $3);
            node *n = create_node("-", "ellipse", "black", "solid", fils);
            $$ = n;
        }
    |   expression MUL expression
        {
            node_list *fils = create_node_list(2, $1, $3);
            node *n = create_node("*", "ellipse", "black", "solid", fils);
            $$ = n;
        }
    |   expression DIV expression
        {
            if (strcmp($3->label, "0") == 0) {
                yyerror("Division par 0");
            }
            node_list *fils = create_node_list(2, $1, $3);
            node *n = create_node("/", "ellipse", "black", "solid", fils);
            $$ = n;
        }
    |   expression LSHIFT expression
        {
            node_list *fils = create_node_list(2, $1, $3);
            node *n = create_node("<<", "ellipse", "black", "solid", fils);
            $$ = n;
        }
    |   expression RSHIFT expression
        {
            node_list *fils = create_node_list(2, $1, $3);
            node *n = create_node(">>", "ellipse", "black", "solid", fils);
            $$ = n;
        }
    |   expression BAND expression
        {
            node_list *fils = create_node_list(2, $1, $3);
            node *n = create_node("&", "ellipse", "black", "solid", fils);
            $$ = n;
        }
    |   expression BOR expression
        {
            node_list *fils = create_node_list(2, $1, $3);
            node *n = create_node("|", "ellipse", "black", "solid", fils);
            $$ = n;
        }
    |   MOINS expression %prec MOINSUNAIRE
        {
            node_list *fils = create_node_list(1, $2);
            node *n = create_node("-", "ellipse", "black", "solid", fils);
            $$ = n;
        }
    |   CONSTANTE 
        {
            char *c = itoa($1);
            node *n = create_node(c, "ellipse", "black", "solid", NULL);
            free(c);
            $$ = n;
        }
    |   variable 
        {   
            symbole_t *s = rechercher_dans_pile(pile_tables_variables, extraire_nom_base($1));
            if (!s) {
                char *war = concat(3, "Variable ", extraire_nom_base($1), " non déclarée");
                warning(war);
                free(war);
            } else {
                int nb_dim_util = get_nb_dimensions_utilisees($1);
                if (nb_dim_util > s->aritee) {
                    char *nb_dim_util_str = itoa(nb_dim_util);
                    char *s_aritee_str = itoa(s->aritee);
                    char *err = concat(6, "Variable ", extraire_nom_base($1), " a une dimension de ", s_aritee_str, " et non ", nb_dim_util_str);
                    free(nb_dim_util_str);
                    free(s_aritee_str);
                    yyerror(err);
                    free(err);
                } else if (nb_dim_util <= s->aritee && nb_dim_util !=0) {
                    for (int i = 0; i < nb_dim_util; i++) {
                        int indice = get_indice_dimension($1, i);
                        if (indice >= s->taillesTab[i]|| indice < 0) {
                            char *incice_str = itoa(indice);
                            char *s_taillesTab_str = itoa(s->taillesTab[i]);
                            char *i_plus_1_str = itoa(i+1);
                            char *war;
                            if (indice < 0) {
                                war = concat(5, "Accés à un indice négatif d'un tableau de taille ", s_taillesTab_str, " (dimension ", i_plus_1_str," du tableau)");
                            } else {
                                war = concat(7, "Accés à l'indice ", incice_str, " d'un tableau de taille ", s_taillesTab_str, " (dimension ", i_plus_1_str," du tableau)");
                            }
                            free(incice_str);
                            free(s_taillesTab_str);
                            free(i_plus_1_str);
                            warning(war);
                            free(war);
                        }
                    }
                }
            }
            $$ = $1;
        }
    |   IDENTIFICATEUR '(' liste_expressions ')' 
        {   
            symbole_t *a = rechercher_dans_pile(pile_tables_fonctions, $1);
            if (a == NULL) {
                char *war = concat(3, "Fonction ", $1, " non déclarée");
                warning(war);
                free(war);
            } else {
                if (a->type != INT_T) {
                    char *war = concat(3, "Fonction ", $1, " appelée dans une expresion n'est pas de type int");
                    warning(war);
                    free(war);
                }
                if (a->aritee != length_of_node_list($3)) {
                    char *aritee = itoa(a->aritee);
                    char *len = itoa(length_of_node_list($3));
                    char *war = concat(6, "Fonction ", $1, " appelée avec ", len, " paramètres au lieu de ", aritee);
                    warning(war);
                    free(len);
                    free(aritee);
                    free(war);
                }
            }

            node *n = create_node($1, "septagon", "black", "solid", $3);
            free($1);
            $$ = n;
        }
;

liste_expressions:
        l_expr
        {
            $$ = $1;
        }
    |
        {
            $$ = NULL;
        }
;

l_expr:
        l_expr ',' expression
        {
            $$ = add_node_to_list($1, $3);
        }
    |   expression
        {
            $$ = create_node_list(1, $1);
        }
;

condition:
        NOT '(' condition ')'
        {
            node_list *fils = create_node_list(1, $3);
            node *n = create_node("NOT", "ellipse", "black", "solid", fils);
            $$ = n;   
        }
    |   condition LAND condition
        {
            node_list *fils = create_node_list(2, $1, $3);
            node *n = create_node("&&", "ellipse", "black", "solid", fils);
            $$ = n;
        }
    |   condition LOR condition
        {
            node_list *fils = create_node_list(2, $1, $3);
            node *n = create_node("||", "ellipse", "black", "solid", fils);
            $$ = n;
        }
    |   '(' condition ')'
        {
            $$ = $2;   
        }
    |   expression binary_comp expression
        {
            node_list *fils = create_node_list(2, $1, $3);
            node *n = create_node($2, "ellipse", "black", "solid", fils);
            $$ = n;
        }
;

binary_comp:
        LT
        {
            $$ = "<";
        }
    |   GT
        {
            $$ = ">";
        }
    |   GEQ
        {
            $$ = ">=";
        }
    |   LEQ
        {
            $$ = "<=";
        }
    |   EQ
        {
            $$ = "==";
        }
    |   NEQ
        {
            $$ = "!=";
        }
;

%%

void fin_programme() {
    liberer_pile(&pile_tables_variables);
    liberer_pile(&pile_tables_fonctions);
    yylex_destroy();
    if (fichier) fclose(fichier);
    if (arbre_abstrait) destroy_tree_list(arbre_abstrait);
    if (tailles) free(tailles);
}

int main(int argc, char* argv[]) {
    if (atexit(fin_programme) != 0) {
        fprintf(stderr, COLOR_RED "[Error] Erreur de l'enregistrement de la fonction fin_programme() avec atexit()\n" COLOR_RESET);
        return 4;
    }

    char* nom_fichier;

    if (argc == 1) {
        yyin = stdin;
    } else if (argc == 2) {
        nom_fichier = argv[1];
        if ((fichier = fopen(nom_fichier,"r")) == NULL) { 
            fprintf(stderr, COLOR_RED "[Error] Erreur de lecture du ficher : %s\n" COLOR_RESET, nom_fichier);
            return 2;
        }
        yyin = fichier;
    } else {
        fprintf(stderr, COLOR_RED "[Error] Veuillez ne pas donner plus d'un fichier en argument.\n" COLOR_RESET);
        return 3;
    }

    if (yyparse() != 0 || error) {
        fprintf(stderr, COLOR_RED "Erreur lors de l'analyse lexicale, syntaxique ou sémantique. Aucune génération de fichier DOT.\n" COLOR_RESET);
        return 1;
    }

    printf(COLOR_GREEN "Analyse lexicale, syntaxique et sémantique valide! Construction de l'arbre abstrait sans erreurs.\n" COLOR_RESET);
    
    /* on enlève ".c" à la fin du nom du fichier pour le nom du fichier dot*/
    char *nom_fichier_dot = strdup(nom_fichier);
    char *point = strrchr(nom_fichier_dot, '.');
    if (point) *point = '\0';

    convert_to_dot(arbre_abstrait, nom_fichier_dot);
    free(nom_fichier_dot);

    return 0;
}
