%option noyywrap noinput nounput
%option yylineno

D                       [0-9]
L                       [a-zA-Z_]

%{

#include <stdio.h>
#include "utils/old/arbresPile.h"
#include "utils/old/arbres.h"
#include "utils/couleurs_terminal.h"
#include "utils/tables_symboles.h"
#include "utils/noeuds.h"
#include "utils/arbres.h"
#include "y.tab.h"

extern YYSTYPE yylval;
extern int yylineno;

int yylex();
int yyerror(char *s);

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

{L}({L}|{D})*               {
                                yylval.var = strdup(yytext);
                                return IDENTIFICATEUR;
                            }

{D}+                        {
                                yylval.var = strdup(yytext);
                                /* remplacer par: yylval.ival = atoi(yytext); */
                                return CONSTANTE; 
                            }

"+"                         { 
                                yylval.var = strdup(yytext);
                                return PLUS;
                            }
"-"                         { 
                                yylval.var = strdup(yytext);
                                return MOINS;
                            }
"*"                         { 
                                yylval.var = strdup(yytext);
                                return MUL;
                            }
"/"                         { 
                                yylval.var = strdup(yytext);
                                return DIV; 
                            }
"<<"                        { 
                                yylval.var = strdup(yytext);
                                return LSHIFT;
                            }
">>"                        {
                                yylval.var = strdup(yytext);
                                return RSHIFT;
                            }
"&"                         { 
                                yylval.var = strdup(yytext);
                                return BAND;
                            }
"|"                         { 
                                yylval.var = strdup(yytext);
                                return BOR;
                            }
"&&"                        {
                                yylval.var = strdup(yytext);
                                return LAND;
                            }
"||"                        {
                                yylval.var = strdup(yytext);
                                return LOR;
                            }
"<"                         { 
                                yylval.var = strdup(yytext);
                                return LT;
                            }
">"                         { 
                                yylval.var = strdup(yytext);
                                return GT;
                            }
">="                        { 
                                yylval.var = strdup(yytext);
                                return GEQ;
                            }
"<="                        { 
                                yylval.var = strdup(yytext);
                                return LEQ;
                            }
"=="                        { 
                                yylval.var = strdup(yytext);
                                return EQ;
                            }
"!="                        { 
                                yylval.var = strdup(yytext);
                                return NEQ;
                            }
"!"                         { return NOT; }
"{"                         { return '{'; }
"}"                         { return '}'; }
"("                         { return '('; }
")"                         { return ')'; }
"["                         { return '['; }
"]"                         { return ']'; }
";"                         { return ';'; }
":"                         { return ':'; }
","                         { return ','; }
"="                         { return '='; }

[ \t\v\n\f]                 { /* Ignorer les espaces blancs */ }
"/*"([^*]|\*+[^*/])*\*+"/"  { /* Ignorer les commentaires */ }

.                           {
                                fprintf (stderr, COLOR_RED "[Error] lexical error %s à la ligne %d" COLOR_RESET, yytext, yylineno);
                                exit(1); 
                            }
 
%%
