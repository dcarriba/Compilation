%{

#include <stdio.h>
#include <stdlib.h>
#include "utils/tables_symboles.h"
#include "utils/abresPile.h"
#include "utils/arbres.h"

extern FILE *yyin;
extern int yylineno;
int yylex();
int yyerror();

table_t *pile_talbles = NULL;
nodePile pile_node = {NULL};  
exprPile pile_expr = {NULL};

	int n_erreur = 0;
	int n_warning = 0;
	int yylineno;
	int n_param = 0;
	int is_void = 0;
	int is_int = 0;
	int is_switch = 0;
	int has_return = 0;

    int nb_dim = 0;
    int nb_aritee = 0;

    int warningError(char *s){
		fprintf(stdout, "Warning : %s, dans la ligne %d: \n",s,yylineno);
		n_warning++;
	}
	int yyerror(char *s){
		fprintf(stderr,"\nError : %s, dans la ligne %d: \n",s ,yylineno);
		n_erreur++;
	}




%}

%union {
    char *name;
    type_t type;
    int value;
}

%type <type> type declarateur
%type <name> saut
%token<name> IDENTIFICATEUR
%token<value> CONSTANTE
%token<type> VOID INT
%token FOR WHILE IF ELSE SWITCH CASE DEFAULT
%token BREAK RETURN PLUS MOINS MUL DIV LSHIFT RSHIFT BAND BOR LAND LOR LT GT 
%token GEQ LEQ EQ NEQ NOT EXTERN

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

programme:
        liste_declarations liste_fonctions
;
liste_declarations:
        liste_declarations declaration 
    |
;
liste_fonctions:
        liste_fonctions fonction
    |   fonction
;
declaration:
        type liste_declarateurs ';' 
;

liste_declarateurs:
        liste_declarateurs ',' declarateur
    |   declarateur
;

declarateur:
    IDENTIFICATEUR {
        if (rechercher_dans_pile($1)) {  
            yyerror("La variable " + $1 + " est déjà déclarée dans la même portée.");
        } else {
            nb_dim = 0;  
            tailles = NULL;  
        }
    }
    |   declarateur '[' CONSTANTE ']' { 
        nb_aritee++;  
        tailles = realloc(tailles, nb_aritee * sizeof(int));  
        if (tailles == NULL) {
            yyerror("Erreur de réallocation de mémoire pour les tailles du tableau");
        }
        tailles[nb_aritee - 1] = $3;  
    }
    |   { 
        declarer($1, nb_aritee, nb_dim, tailles, $$, 0);  
    }
;

fonction:
        type IDENTIFICATEUR '(' liste_parms ')' '{' liste_declarations liste_instructions '}'
    |   EXTERN type IDENTIFICATEUR '(' liste_parms ')' ';'
;
type:
        VOID {
            is_void = 1;
            is_int = 0; 
            $$ = VOID_T;
            
        }
    |   INT{
            is_void = 0;
            is_int = 1;        

            $$ = INT_T;
    }
;
liste_parms:
        l_parms
    |
;
l_parms :
        l_parms ',' parm
    |   parm
;
parm:
        INT IDENTIFICATEUR
;
liste_instructions :
        liste_instructions instruction
    |
;
instruction:
        iteration
    |   selection
    |   saut
    |   affectation ';'
    |   bloc
    |   appel
;
iteration:
        FOR '(' affectation ';' condition ';' affectation ')' instruction
    |   WHILE '(' condition ')' instruction
;
selection:
        IF '(' condition ')' instruction %prec THEN
    |   IF '(' condition ')' instruction ELSE instruction
    |   SWITCH '(' expression ')' instruction
    |   CASE CONSTANTE ':' instruction
    |   DEFAULT ':' instruction
;
saut:
        BREAK ';'
    |   RETURN ';' {
                has_return = 0;
                char *parent = nodeName();
                nodeEmpiler(&pile_node,parent,"RETURN",2,"");
                $$ = parent;

                }
    |   RETURN expression ';'
;
affectation:
    variable '=' expression {
        char *nom = $1;  
        int valeur = $3; 

        symbole_t *s = rechercher_dans_pile(nom);

        if (s) {
            s->valeur = valeur;
        } else {
            yyerror("variable pas déclaré")
        }
    }
;
bloc:
        '{' liste_declarations liste_instructions '}'{
            push_table();

            pop_table();
        }
;
appel:
        IDENTIFICATEUR '(' liste_expressions ')' ';'
;
variable:
        IDENTIFICATEUR
    |   variable '[' expression ']'
;
expression:
        '(' expression ')'
    |   expression binary_op expression %prec OP
    |   MOINS expression
    |   CONSTANTE
    |   variable
    |   IDENTIFICATEUR '(' liste_expressions ')'
;
liste_expressions:
        l_expr
    |
;
l_expr:
        l_expr ',' expression
    |   expression
;
condition:
        NOT '(' condition ')'
    |   condition binary_rel condition %prec REL
    |   '(' condition ')'
    |   expression binary_comp expression
;
binary_op:
        PLUS
    |   MOINS
    |   MUL
    |   DIV
    |   LSHIFT
    |   RSHIFT
    |   BAND
    |   BOR
;
binary_rel:
        LAND
    |   LOR
;
binary_comp:
        LT
    |   GT
    |   GEQ
    |   LEQ
    |   EQ
    |   NEQ
;

%%

int yyerror(char *s){
    fprintf(stderr, "[ERREUR] %s à la ligne %d\n", s, yylineno);
    exit(1);
}

void finProgramme(){
    liberer_pile();
}

int main(int argc, char* argv[]){
    if (atexit(finProgramme) != 0){
        fprintf(stderr, "[ERREUR] Erreur de l'enregistrement de la fonction finProgramme() avec atexit()\n");
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
            fprintf(stderr, "[ERREUR] Erreur de lecture du ficher : %s\n", nom_fichier);
            return 2;
        }
        yyin = fichier;
    } else {
        fprintf(stderr, "[ERREUR] Veuillez ne pas donner plus d'un fichier en argument.\n");
        return 3;
    }
    yyparse();
    printf("Analyse syntaxique valide!\n");
    return 0;
}
