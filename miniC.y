%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "utils/old/arbresPile.h"
#include "utils/old/arbres.h"
#include "utils/couleurs_terminal.h"
#include "utils/tables_symboles.h"
#include "utils/noeuds.h"
#include "utils/arbres.h"

extern FILE *yyin;
extern int yylineno;
int yylex();
int yyerror();
int yylex_destroy();

/*
 * Arbre Abstrait 
 */
tree_list *arbre_abstrait = NULL;

table_t *pile_talbles = NULL;
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
    fprintf(stdout, COLOR_MAGENTA "[Warning] %s à la ligne %d: \n" COLOR_RESET, s, yylineno);
    n_warning++;
}

int yyerror(char *s){
    fprintf(stderr, COLOR_RED "[Error] %s à la ligne %d\n" COLOR_RESET, s, yylineno);
    n_erreur++;
    exit(1);
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
%type<liste_noeuds> liste_instructions l_instructions liste_expressions l_expr liste_parms l_parms
%type<noeud> appel instruction iteration selection condition bloc affectation variable expression saut parm
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
            push_table(&pile_talbles);
        }
;

pop :
        { 
            pop_table(&pile_talbles); 
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
            $$=concat(2,$1,$2);
        }
    |   
        { $$ = "";

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
            $$ = concat(4,$1," ",$2, ";\n");

        }
;

liste_declarateurs:
        liste_declarateurs ',' declarateur 
        {
            $$ = concat(3,$1,",",$3);
        }
    |   declarateur 
        {
            $$ = $1;
        }
;

declarateur:
        IDENTIFICATEUR
        { 
            declarer(pile_talbles, $1, nb_dim,tailles, INT_T);
            nb_dim = 0;
            $$ = $1;
            /*
            declarer($1, 0, nb_dim, tailles, INT_T, 0);
            */


        }
    |   declarateur '[' CONSTANTE ']' 
        { 
            
            nb_dim++;
            tailles = realloc(tailles, nb_dim * sizeof(int));  
            if (tailles == NULL) {
                yyerror("Erreur de réallocation de mémoire pour les tailles du tableau");
            }
            tailles[nb_dim - 1] = atoi($3);
            $$ = concat(4,$1,"[",$3,"]");
            

        }
    |   
        {

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
            snprintf(label, len, "%s, %s", $1, $2);
            node *n = create_node(label, "invtrapezium", "blue", "solid", $9);
            free(label);
            tree *t = create_tree(n);
            $$ = t;
        }
    |   EXTERN type IDENTIFICATEUR '(' liste_parms ')' ';'
        {
        declarer(pile_tablesFonc, $3, n_param,NULL, INT_T);
        n_param=0;
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
    |   SWITCH '(' expression ')' instruction
        {
            node_list *fils = create_node_list(2, $3, $5);
            node *n = create_node("SWITCH", "ellipse", "black", "solid", fils);
            $$ = n;
        }
    |   CASE CONSTANTE ':' instruction
        {
            int len = strlen("case ") + strlen($2) + 1;
            char *label = (char *)malloc(len);
            snprintf(label, len, "case %s", $2);

            node_list *fils = create_node_list(1, $4);
            node *n = create_node(label, "ellipse", "black", "solid", fils);
            $$ = n;

            free(label);
        }
    |   DEFAULT ':' instruction
        {
            node_list *fils = create_node_list(1, $3);
            node *n = create_node("case default", "ellipse", "black", "solid", fils);
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
        
            symbole_t *s = rechercher_dans_pile(pile_talbles,$1->label);
            if (s == NULL){
                warningError(concat(3,"affectation sur la variable ",$1->label," qui n'est pas déclarer"));
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
                warningError(concat(3,"Fonction ",$1," pas déclarer"));
            }
            if (a->aritee != length_of_node_list($3)){
                warningError(concat(6,"Fonction ",$1,"a",length_of_node_list($3),"parametres au lieu de",a->aritee));
            }
            node *n = create_node($1, "septagon", "black", "solid", $3);
            $$ = n;
        }
;

variable:
        IDENTIFICATEUR
        {
            node *n = create_node($1, "ellipse", "black", "solid", NULL);
            $$ = n;
        }
    |   variable '[' expression ']' 
        {
            node_list *fils = create_node_list(2, $1, $3);
            node *n = create_node("variable", "ellipse", "black", "solid", fils); /* Chercher le nom de la variabla dans la table de symbole et le mettre comme label du node */
            $$ = n;
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
        }
    |   variable 
        {
            $$ = $1;
        }
    |   IDENTIFICATEUR '(' liste_expressions ')' 
        {
            node *n = create_node($1, "septagon", "black", "solid", $3);
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
    liberer_pile(&pile_talbles);
    liberer_pile(&pile_tablesFonc);
    yylex_destroy();
}

int main(int argc, char* argv[]){
    if (atexit(finProgramme) != 0){
        fprintf(stderr, COLOR_RED "[Error] Erreur de l'enregistrement de la fonction finProgramme() avec atexit()\n" COLOR_RESET);
        return 4;
    }
    FILE* fichier;
    char* nom_fichier;
    if (argc == 1){
        yyin = stdin;
    } else if (argc == 2){
        nom_fichier = argv[1];
        /* si fichier existe pas alors erreur */
        if ((fichier = fopen(nom_fichier,"r")) == NULL){ 
            fprintf(stderr, COLOR_RED "[Error] Erreur de lecture du ficher : %s\n" COLOR_RESET, nom_fichier);
            return 2;
        }
        yyin = fichier;
    } else {
        fprintf(stderr, COLOR_RED "[Error] Veuillez ne pas donner plus d'un fichier en argument.\n" COLOR_RESET);
        return 3;
    }
    yyparse();
    printf(COLOR_GREEN "Analyse lexicale, syntaxique et sémantique valide! - Construction de l'arbre syntaxique sans erreurs\n" COLOR_RESET);
    print_tree_list(arbre_abstrait);
    destroy_tree_list(arbre_abstrait);

    return 0;
}
