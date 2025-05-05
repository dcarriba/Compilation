%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "utils/tables_symboles.h"
#include "utils/arbresPile.h"
#include "utils/arbres.h"

extern FILE *yyin;
extern int yylineno;
int yylex();
int yyerror();

table_t *pile_talbles = NULL;
table_t *pile_tablesFonc = NULL;
nodePile pileNode = {NULL};  
exprPile pileExpr = {NULL};
exprPile pileExprTab[100];
int exprInc = 0;


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
    fprintf(stdout, "[Warning] %s à la ligne %d: \n",s,yylineno);
    n_warning++;
}

int yyerror(char *s){
    fprintf(stderr, "[ERREUR] %s à la ligne %d\n", s, yylineno);
    n_erreur++;
    exit(1);
}

%}

%union {
    char *var;
}

%type<var> liste_declarations declaration liste_fonctions fonction type
%type<var> saut bloc liste_declarateurs

%type<var> variable expression declarateur 

%token<var> IDENTIFICATEUR
%token<var> CONSTANTE
%token<var> VOID INT
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
push : 
    { push_table(); }
;

pop :
    { pop_table(); }
;

programme:
        push liste_declarations liste_fonctions pop
;

liste_declarations:
        liste_declarations declaration {
            $$=concat(2,$1,$2);
        }
    | {push_table();
        $$ = "";
        exprPile ePile = {NULL};
        pileExprTab[++exprInc]= ePile;}
;

liste_fonctions:
        liste_fonctions fonction {$$ = concat(2,$1,$2);}
    |   fonction
;

declaration:
        type liste_declarateurs ';'  {
            if (is_void == 1){
                yyerror("Déclaration de type void impossible");
            }
            $$ = concat(4,$1," ",$2, ";\n");
        }
;

liste_declarateurs:
        liste_declarateurs ',' declarateur {
            $$ = concat(3,$1,",",$3);
        }
    |   declarateur {
            $$=$1;
        }
;

declarateur:
        IDENTIFICATEUR { declarer($1, 0,nb_dim, tailles, INT_T, 0);
        $$ = $1;
        }
    |   declarateur '[' CONSTANTE ']' { 
            nb_dim++;
            tailles = realloc(tailles, nb_dim * sizeof(int));  
            if (tailles == NULL) {
                yyerror("Erreur de réallocation de mémoire pour les tailles du tableau");
            }
            tailles[nb_dim - 1] = (int) $3;   
            $$ = concat(4,$1,"[",$3,"]");  
        }
    | {nb_dim =0;
        $$ = "";}
;

fonction:
        type IDENTIFICATEUR '(' liste_parms ')' '{' liste_declarations liste_instructions '}' {
            pop_table();

            $$=$2;
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
            push_table();
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

        }
    |   EXTERN type IDENTIFICATEUR '(' liste_parms ')' ';'{
        $$ = "";
    }
;

type:
        VOID {
            is_void = 1;
            is_int = 0; 
            $$ = "void";
            
        }
    |   INT {
            is_void = 0;
            is_int = 1;        
            $$ = "int";
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
        BREAK ';' {
            char *nom = nodeName();
            nodeEmpiler(&pileNode,nom,"BREAK",4,"");
            $$ = nom;
        }
    |   RETURN ';' {
            has_return = 0;
            char *parent = nodeName();
            nodeEmpiler(&pileNode, parent, "RETURN", 2, "");
            $$ = parent;
        }
    |   RETURN expression ';' {
            has_return = 1;
            if(is_void ==1){
                warningError("Return sur une fonction de type void interdit");
            }
        char *parent = nodeName();
        lienEntreParentEtNom(&pileNode,$2,parent);
        nodeEmpiler(&pileNode,parent,"RETURN",2,"");
        $$ =parent;
    }
;

affectation:
        variable '=' expression {
            char *parent = nodeName();
            lienEntreParentEtNom(&pileNode,$1,parent);
            lienEntreParentEtNom(&pileNode,$3,parent);
            nodeEmpiler(&pileNode,parent,":=",6,"");
        }
;

bloc:
        '{' push liste_declarations liste_instructions pop '}'{
            char *bloc = nodeName();
            // exprLienEntreParentEtNom(&pileNode,&exprPile[exprInc--],bloc);
            nodeEmpiler(&pileNode,bloc,"BLOC",6,"");
            $$ = bloc;

        }
;

appel:
        IDENTIFICATEUR '(' liste_expressions ')' ';'
;

variable:
        IDENTIFICATEUR {
            verifier_declaration($1);
            char *nom = nodeName();
            nodeEmpiler(&pileNode,nom,$1,6,"");
            char *n = $1;
            $$ = nom;
        }
    |   variable '[' expression ']' {
            /*$$ = $1;*/
        }
;

expression:
        '(' expression ')' {
            $$ = $2;
        }
    |   expression binary_op expression %prec OP
    |   MOINS expression {
            char *parent = nodeName();
            lienEntreParentEtNom(&pileNode,$2,parent);
            nodeEmpiler(&pileNode,parent,"- unaire",6,"");
            $$ = parent;
        }
    |   CONSTANTE {
            char *nom = nodeName();
            nodeEmpiler(&pileNode,nom,$1,6,"");
            $$ = nom;

            

        }
    |   variable {
            $$ = $1;
        }
    |   IDENTIFICATEUR '(' liste_expressions ')' {
            symbole_t *s = rechercher(top_table(), $1);
 
        }
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
