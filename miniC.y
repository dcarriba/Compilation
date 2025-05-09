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

/* Arbre Syntaxique Abstrait du programme */
tree_list *arbre_abstrait = NULL;

table_t *pile_tables = NULL;
table_t *pile_tablesFonc = NULL;

int n_erreur = 0;
int n_warning = 0;
int n_param = 0;
int is_void = 0;
int is_int = 0;
int is_switch = 0;
int has_return = 0;

int nb_dim = 0;
int *tailles;
int nb_aritee = 0;

void warningError(char *s){
    fprintf(stdout, COLOR_MAGENTA "[Warning] %s à la ligne %d\n" COLOR_RESET, s, yylineno);
    n_warning++;
}

int yyerror(char *s){
    fprintf(stderr, COLOR_RED "[Error] %s à la ligne %d\n" COLOR_RESET, s, yylineno);
    n_erreur++;
    return 1;
}

%}

%union {
    char *var;
    node *noeud;
    node_list *liste_noeuds;
    tree *arbre;
    tree_list *liste_arbres;
}


%type<liste_arbres> programme liste_fonctions
%type<arbre> fonction
%type<liste_noeuds> liste_instructions l_instructions liste_expressions l_expr liste_parms l_parms tableau liste_switch_case
%type<noeud> appel instruction iteration selection condition bloc affectation variable expression saut parm switch_case
%type<var> type binary_op binary_rel binary_comp liste_declarateurs declaration liste_declarations declarateur 


%token<var> IDENTIFICATEUR
%token<var> CONSTANTE
%token<var> VOID INT
%token FOR WHILE IF ELSE SWITCH CASE DEFAULT
%token BREAK RETURN
%token<var> PLUS MOINS MUL DIV LSHIFT RSHIFT BAND BOR LAND LOR LT GT 
%token<var> GEQ LEQ EQ NEQ 
%token NOT EXTERN

%left PLUS MOINS
%left MUL DIV
%left LSHIFT RSHIFT
%left BOR BAND
%left LAND LOR
%nonassoc THEN
%nonassoc ELSE
%left OP
%left REL
%start programme

%%
push : 
        { 
            push_table(&pile_tables);
        }
;

pop :
        { 
            pop_table(&pile_tables); 
        }
;

pushf : 
        { 
            push_table(&pile_tablesFonc);
        }
;

popf :
        { 
            pop_table(&pile_tablesFonc); 
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
            //$$=concat(2,$1,$2);
        }
    |   
        { 
            $$ = "";
        }
;

liste_fonctions:
        liste_fonctions fonction
        {
            $$ = add_tree_to_list($1, $2);
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
            if(is_void == 1){
                yyerror("une déclaration ne peux pas etre de type void");
            }
            //$$ = concat(4,$1," ",$2, ";\n");

        }
;

liste_declarateurs:
        liste_declarateurs ',' declarateur
        {
            symbole_t *s = rechercher(pile_tables, $3);
            if (s != NULL) {
                char *war = concat(3, "La variable : ", $3, " a déjà été déclarée dans le même bloc");
                warningError(war);
                free(war);
            }
            declarer(pile_tables, $3, nb_dim, tailles, INT_T);
            free(tailles);
            tailles = NULL;
            nb_dim = 0;

        }
    |   declarateur
        {
            symbole_t *s = rechercher(pile_tables, $1);
            if (s != NULL) {
                char *war = concat(3, "La variable : ", $1, " a déjà été déclarée dans le même bloc");
                warningError(war);
                free(war);
            }
            declarer(pile_tables, $1, nb_dim, tailles, INT_T);
            free(tailles);
            tailles = NULL;
            nb_dim = 0;

            $$ = $1;
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
        tailles[nb_dim - 1] = atoi($3);
        free($3);
        $$ = $1;
    }
;

fonction:
        type IDENTIFICATEUR '(' push liste_parms ')' '{' liste_declarations liste_instructions pop'}' 
        {
            /*
            $$ = $2;
            int i = 0;
            while(i < incAppel){
                symbole_t sym = listeAppelFonctions[i];
                symbole_t *s =  rechercher_dans_pile(sym.nom);
                verifier_declaration(sym.nom);
                if(sym.nbParametresF != s->nbParametresF){
                    yyerror("Nombre de paramètre");
                    printf("La fonction %s doit avoir %d parametres, ici il y en a %d \n",sym.nom,s->nbParametresF,sym.nbParametresF);
                }
                i++;
            }
            n_param = 0;
            incAppel = 0;
            if(is_void == 0 && has_return == 0){
                warningError("Absence de return pour une fonction de type int");
            } else if(is_int == 0 && has_return == 1){
                warningError("Return present dans une fonction de type void");
            }
            has_return = 0;
            char *bloc = nodeName();
            char *fonc = $2;
            char *fonctionLabel = concat(3,$2,",",$1);
            exprLienEntreParentEtNom(&pileNode,&pileExprTab[exprInc--] , bloc);
            nodeEmpiler(&pileNode,bloc,"BLOC",6,fonc);
            nodeEmpiler(&pileNode,fonc,fonctionLabel,1,"");
            $$ = fonc ;
            */

            if(is_void == 0 && has_return == 0){
                warningError("Absence de return pour une fonction de type int");
            } else if(is_int == 0 && has_return == 1){
                warningError("Return present dans une fonction de type void");
            }
            has_return =0;

            int len = strlen($1) + strlen(", ") + strlen($2) + 1;
            char *label = (char *)malloc(len);
            snprintf(label, len, "%s, %s", $2, $1);
            node *bloc= create_node("BLOC", "ellipse", "black", "solid", $9);
            node *fonction = create_node(label, "invtrapezium", "blue", "solid", create_node_list(1, bloc));
            free(label);
            tree *t = create_tree(fonction);
            $$ = t;
            free($2);
        }
    |   EXTERN type IDENTIFICATEUR '(' liste_parms ')' ';'
        {
            declarer(pile_tablesFonc, $3, n_param,NULL, INT_T);
            n_param=0;
            free($3);
        }
;

type:
        VOID 
        {
            is_void = 1;
            is_int = 0; 
            $$ = "void";
            
        }
    |   INT 
        {
            is_void = 0;
            is_int = 1;        
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
            $$ = new_empty_node_list();
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
            n_param++;
            $$ = create_node($2, "ellipse", "black", "solid", NULL);
            free($2);
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
        CASE CONSTANTE ':' liste_instructions
        {
            int len = strlen("case ") + strlen($2) + 1;
            char *label = (char *)malloc(len);
            snprintf(label, len, "case %s", $2);

            node *n = create_node(label, "ellipse", "black", "solid", $4);
            $$ = n;

            free(label);
            free($2);
        }
    |   DEFAULT ':' liste_instructions
        {
            node *n = create_node("case default", "ellipse", "black", "solid", $3);
            $$ = n;
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

            node_list *fils = create_node_list(1, $2);
            node *n = create_node("RETURN", "trapezium", "blue", "solid", fils);
            $$ = n;
        }
;

affectation:
        variable '=' expression 
        {   
            symbole_t *s = rechercher_dans_pile(pile_tables, extraire_nom_base($1));
            if (!s) {
                char *err = concat(3, "Variable non déclarée : ", extraire_nom_base($1), "\n");
                warningError(err);
                free(err);
            } else {
                int nb_dim_util = get_nb_dimensions_utilisees($1);
                if (nb_dim_util != s->aritee) {
                    char *nb_dim_util_str = itoa(nb_dim_util);
                    char *s_aritee_str = itoa(s->aritee);
                    char *err = concat(5, "Variable de dimension : ", nb_dim_util_str,"au lieu de ", s_aritee_str, "\n");
                    free(nb_dim_util_str);
                    free(s_aritee_str);
                    warningError(err);
                    free(err);
                } else if (nb_dim_util == s->aritee && nb_dim_util !=0) {
                    for (int i = 0; i < nb_dim_util; i++) {
                        int indice = get_indice_dimension($1, i);
                        if (indice >= s->taillesTab[i]) {
                            char *incice_str = itoa(indice);
                            char *s_taillesTab_str = itoa(s->taillesTab[i]);
                            char *i_plus_1_str = itoa(i+1);
                            char *err = concat(7, "Accés à l'indice ", incice_str, " d'un tableau de taille ", s_taillesTab_str, " (dimension ", i_plus_1_str," du tableau)");
                            free(incice_str);
                            free(s_taillesTab_str);
                            free(i_plus_1_str);
                            warningError(err);
                            free(err);
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
            symbole_t *a = rechercher_dans_pile(pile_tablesFonc, $1);
            if (a == NULL){
                char *war = concat(3,"Fonction ",$1," pas déclarer");
                warningError(war);
                free(war);
            }
            if (a->aritee != length_of_node_list($3)){
                char *aritee = itoa(a->aritee);
                char *len = itoa(length_of_node_list($3));
                char *war = concat(4,"Fonction appelé avec ",len," parametres au lieu de",aritee);
                warningError(war);
                free(len);
                free(aritee);
                free(war);
            }
            node *n = create_node($1, "septagon", "black", "solid", $3);
            $$ = n;
            free($1);
        }
;

variable:
        IDENTIFICATEUR
        {
            node *n = create_node($1, "ellipse", "black", "solid", NULL);
            $$ = n;
            free($1);
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
            node_list *nl = create_node_list(2, n, $3);
            $$ = nl;
            free($1);
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
    |   expression binary_op expression %prec OP
        {
            node_list *fils = create_node_list(2, $1, $3);
            node *n = create_node($2, "ellipse", "black", "solid", fils);
            $$ = n;
            free($2);
        }
    |   MOINS expression 
        {
            node_list *fils = create_node_list(1, $2);
            node *n = create_node($1, "ellipse", "black", "solid", fils);
            $$ = n;
        }
    |   CONSTANTE 
        {
            node *n = create_node($1, "ellipse", "black", "solid", NULL);
            $$ = n;
            free($1);
        }
    |   variable 
        {
            $$ = $1;
        }
    |   IDENTIFICATEUR '(' liste_expressions ')' 
        {
            node *n = create_node($1, "septagon", "black", "solid", $3);
            $$ = n;
            free($1);
        }
;

liste_expressions:
        l_expr
        {
            $$ = $1;
        }
    |
        {
            $$ = new_empty_node_list();
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
    |   condition binary_rel condition %prec REL
        {
            node_list *fils = create_node_list(2, $1, $3);
            node *n = create_node($2, "ellipse", "black", "solid", fils);
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

binary_op:
        PLUS
        {
            $$ = $1;
        }
    |   MOINS
        {
            $$ = $1;
        }
    |   MUL
        {
            $$ = $1;
        }
    |   DIV
        {
            $$ = $1;
        }
    |   LSHIFT
        {
            $$ = $1;
        }
    |   RSHIFT
        {
            $$ = $1;
        }
    |   BAND
        {
            $$ = $1;
        }
    |   BOR
        {
            $$ = $1;
        }
;

binary_rel:
        LAND
        {
            $$ = $1;
        }
    |   LOR
        {
            $$ = $1;
        }
;

binary_comp:
        LT
        {
            $$ = $1;
        }
    |   GT
        {
            $$ = $1;
        }
    |   GEQ
        {
            $$ = $1;
        }
    |   LEQ
        {
            $$ = $1;
        }
    |   EQ
        {
            $$ = $1;
        }
    |   NEQ
        {
            $$ = $1;
        }
;

%%

void finProgramme(){
    liberer_pile(&pile_tables);
    liberer_pile(&pile_tablesFonc);
    yylex_destroy();
    if (arbre_abstrait) destroy_tree_list(arbre_abstrait);
    if (tailles) free(tailles);
}

int main(int argc, char* argv[]){
    if (atexit(finProgramme) != 0){
        fprintf(stderr, COLOR_RED "[Error] Erreur de l'enregistrement de la fonction finProgramme() avec atexit()\n" COLOR_RESET);
        return 4;
    }

    FILE* fichier = NULL;
    char* nom_fichier;

    if (argc == 1){
        yyin = stdin;
    } else if (argc == 2){
        nom_fichier = argv[1];
        if ((fichier = fopen(nom_fichier,"r")) == NULL){ 
            fprintf(stderr, COLOR_RED "[Error] Erreur de lecture du ficher : %s\n" COLOR_RESET, nom_fichier);
            return 2;
        }
        yyin = fichier;
    } else {
        fprintf(stderr, COLOR_RED "[Error] Veuillez ne pas donner plus d'un fichier en argument.\n" COLOR_RESET);
        return 3;
    }

    if (yyparse() != 0) {
        fprintf(stderr, COLOR_RED "[Error] Erreur lors de l'analyse lexicale, syntaxique ou sémantique\n" COLOR_RESET);
        if (fichier) fclose(fichier);
        return 1;
    }

    if (fichier) fclose(fichier);

    printf(COLOR_GREEN "Analyse lexicale, syntaxique et sémantique valide! - Construction de l'arbre syntaxique sans erreurs\n" COLOR_RESET);
    
    char *nom_fichier_dot = strdup(nom_fichier);

    char *point = strrchr(nom_fichier_dot, '.'); /* pointe vers le . du .c a la fin du nom du fichier */
    if (point) *point = '\0'; /* on enlève le .c à la fin du nom du fichier */

    convert_to_dot(arbre_abstrait, nom_fichier_dot);
    free(nom_fichier_dot);

    return 0;
}
