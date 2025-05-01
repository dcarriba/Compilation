%option noyywrap
%option yylineno

D                       [0-9]
L                       [a-zA-Z_]

%{

#include <stdio.h>
#include "y.tab.h"

extern int yylval;
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

{L}({L}|{D})*               { return IDENTIFICATEUR; }
{D}+                        { return CONSTANTE; }

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
.                           { fprintf (stderr, "[ERREUR] lexical error %s à la ligne %d\n", yytext, yylineno); exit(1); }
%%