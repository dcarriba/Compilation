%{

#include <stdio.h>
#include <stdlib.h>
#include "utils/tables_symboles.h"

extern FILE *yyin;
extern int yylineno;
int yylex();
int yyerror();

%}

%union {
    char *name;
    type_t type;
    int value;
}

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
        IDENTIFICATEUR
    |   declarateur '[' CONSTANTE ']'
;
fonction:
        type IDENTIFICATEUR '(' liste_parms ')' '{' liste_declarations liste_instructions '}'
    |   EXTERN type IDENTIFICATEUR '(' liste_parms ')' ';'
;
type:
        VOID
    |   INT
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
    |   RETURN ';'
    |   RETURN expression ';'
;
affectation:
        variable '=' expression
;
bloc:
        '{' liste_declarations liste_instructions '}'
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
