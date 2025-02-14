%option noyywrap
/* ^ a enlever plus tard */

D                       [0-9]
L                       [a-zA-Z_]
/* A SUPPRIMER ??? V */
H                       [a-fA-F0-9]
E                       [Ee][+-]?{D}+
FS                      (f|F|l|L)
IS                      (u|U|l|L)*
/* -- */

%{
#include <stdio.h>
/* #include "y.tab.h" */
/* ^ a remettre plus tard */

#define TOKEN_EOF 0
#define IDENTIFICATEUR 256
#define CONSTANTE 257
#define VOID 258
#define INT 259
#define FOR 260
#define WHILE 261
#define IF 262
#define ELSE 263
#define SWITCH 264
#define CASE 265
#define DEFAULT 266
#define BREAK 267
#define RETURN 268
#define PLUS '+'
#define MOINS '-'
#define MUL '*'
#define DIV '/'
#define LSHIFT 269
#define RSHIFT 270
#define BAND '&'
#define BOR '|'
#define LAND 271
#define LOR 272
#define LT '<'
#define GT '>'
#define GEQ 273
#define LEQ 274
#define EQ 275
#define NEQ 276
#define NOT '!'
#define EXTERN 277
#define THEN '{' /* pas sur */
#define OP 278 /* pas sur */
#define REL 279 /* pas sur */
#define programme 280 /* pas sur */


/* Ne gere pas les commentaires. A rajouter */
/* Supprimer les lignes dont vous n'avez pas besoin. */

%}

%%

"break"                     { return BREAK; }
"case"                      { return CASE; }
"default"                   { return DEFAULT; }
"else"                      { return ELSE; }
"extern"                    { return EXTERN; }
"for"                       { return FOR; }
"if"                        { return IF; }
"int"                       { return INT; }
"return"                    { return RETURN; }
"switch"                    { return SWITCH; }
"void"                      { return VOID; }
"while"                     { return WHILE; }

{L}({L}|{D})*               { return IDENTIFICATEUR; }
{D}*                        { return CONSTANTE; }

0[xX]{H}+{IS}?              { /* A completer */ } /* HEX */ /* a supprimer ?? */
0{D}+{IS}?                  { /* A completer */ } /* ?? */ /* a supprimer ?? */
{D}+{IS}?                   { /* A completer */ } /* ?? */ /* a supprimer ?? */
L?'(\\.|[^\\'])+'           { /* A completer */ } /* STRING */ /* a supprimer ?? */

{D}+{E}{FS}?                { /* A completer */ } /* FLOAT */ /* a supprimer ?? */
{D}*"."{D}+({E})?{FS}?      { /* A completer */ } /* FLOAT */ /* a supprimer ?? */
{D}+"."{D}*({E})?{FS}?      { /* A completer */ } /* FLOAT */ /* a supprimer ?? */

L?\"(\\.|[^\\"])*\"         { /* A completer */ } /* STRING */ /* a supprimer ?? */

"+"                         { return PLUS; }
"-"                         { return MOINS; }
"*"                         { return MUL; }
"/"                         { return DIV; }
"<<"                        { return LSHIFT; }
">>"                        { return RSHIFT; }
"&"                         { return BAND; }
"|"                         { return BOR; }
"&&"                        { return LAND; }
"||"                        { return LOR; }
"<"                         { return LT; }
">"                         { return GT; }
">="                        { return GEQ; }
"<="                        { return LEQ; }
"=="                        { return EQ; }
"!="                        { return NEQ; }
"!"                         { return NOT; }
"{"                         { return THEN; } /* pas sur */

[ \t\v\n\f]                 { /* Ignorer les espaces blancs */ }
"/*"([^*]|\*+[^*/])*\*+"/"  { /* Ignorer les commentaires */ }
.                           { fprintf (stderr, "erreur lexicale %s à la ligne %d.\n", yytext, yylineno); }
%%
/* ^ peut etre rajouter les characteres "(", ")", "[", "]", ";", etc. */

int main(){
    printf("Codes des tokens retournés par yylex:\n");
    int token_courant = yylex();
    do {
        printf("%d\n", token_courant);
        token_courant = yylex();
    } while (token_courant != TOKEN_EOF);
    return 0;
}
