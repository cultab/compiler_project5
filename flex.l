/* Tokenizing is contained to a single file and stops at EOF */
%option noyywrap

%x unknown
%x indent
%x string_d
%x string_d_esc
%x string_s
%x string_s_esc
%x concat_line

/* C code to include header files, anything between %{ and %} is compliled as-is */

%{

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h> /* needed for va_list */

/* Header file than contains token definitions */
#include "bison.h"

/* Declare current line variable */
int line = 1;

int token_count = 0;
int token_error_count = 0;

void print(const char *s);

/* easy print with line count */
extern void yyerror(const char *restrict format, ...);

%}

/* Names and definitions of regural expresions
 * After this the names can be used (on the left) instead of the hard to read 
 * and long regural expresions 
 */

/* The three following definitions are hardcoded keywords, operators and misc. words that
 * would usually be found in a symbol table.
 */

BUILDIN         (len)|(cmp)|(print)|(del)
KEYWORD         (def)|(return)|(while)|(if)|(and)|(or)|(not)

OPERATOR	(\*{1,2})|(\/{1,2})|(<[=<]?)|(>[=>]?)|(\|)|([+\-&@%^~])|(==)|(![=]?)		
SPECIAL_WORD    ([\(\[\{\)\]\}])|([\,\:\.\;])|(@[=]?)|(->)|=|([+\-%&|^]=)|(\*{1,2}=)|(\/{1,2}=)|(<<=)|(>>=)

VARIABLE	[a-zA-Z_][a-zA-Z0-9_]*
STRING_D        [\"]
STRING_S        [\']

INTCONST        ([1-9][0-9]*)|0([bB][01]+)?
FLOATCONST      ([1-9][0-9]*|0)(\.[0-9]+)?([eE]-?[0-9]+)?
IMAGCONST       ([1-9][0-9]*|0)(\.[0-9]+)?([eE]-?[0-9]+)?(j|J)

COMMENT         #.*
DELIMITER       [ \t]+

 /* anything not matched by the above rules falls through here */

UNKNOWN_TOKEN   .

/* For every pattern (on the left) that matches, the corresponding code
 * in the brackets is executed. The return command enables the return of 
 * and integer value throught the function yylex() 
 *
 * If a pattern is preceded by a state, denoted by angle brackets '<' and '>'
 * it can only be matched if we have entered that state with the directive BEGIN(state_name);
 *
 */

%%

{BUILDIN} {
        token_count++;
        if(!strcmp(yytext,"len")) {
                print("LEN");    
                return LEN;
        } 
        if(!strcmp(yytext,"cmp")) {
                print("CMP");
                return CMP;
        } 
        if(!strcmp(yytext,"print")) {
                print("PRINT");
                return PRINT;
        } 
        if(!strcmp(yytext,"del")) {
                print("DEL");
                return DEL;
        } 
}

{KEYWORD} { 
        token_count++;
        if(!strcmp(yytext,"def")) {
                print("DEF");    
                return DEF;
        } 
        if(!strcmp(yytext,"return")) {
                print("RETURN");
                return RETURN;
        } 
        if(!strcmp(yytext,"while")) {
                print("WHILE");
                return WHILE;
        } 
        if(!strcmp(yytext,"if")) {
                print("IF");
                return IF;
        } 
        if(!strcmp(yytext,"and")) {
                print("AND");
                return AND;
        } 
        if(!strcmp(yytext,"or")) {
                print("OR");
                return OR;
        } 
        if(!strcmp(yytext,"not")) {
                print("NOT");
                return NOT;
        } 
}

{SPECIAL_WORD} { 
        token_count++;
        if(!strcmp(yytext,"(")) {
                print("ATOM (");
                return '(';
        }
        if(!strcmp(yytext,")")) {
                print("ATOM )");
                return ')';
        }
        if(!strcmp(yytext,"[")) {
                print("ATOM [");
                return '[';
        }
        if(!strcmp(yytext,"]")) {
                print("ATOM ]");
                return ']';
        }
        if(!strcmp(yytext,"{")) {
                print("ATOM {");
                return '{';
        }
        if(!strcmp(yytext,"}")) {
                print("ATOM }");
                return '}';
        }
        if(!strcmp(yytext,",")) {
                print("ATOM ,");
                return ',';
        }
        if(!strcmp(yytext,":")) {
                print("ATOM :");
                return ':';
        }
        if(!strcmp(yytext,";")) {
                print("ATOM ;");
                return ';';
        }
        if(!strcmp(yytext,"=")) {
                print("ATOM =");
                return '=';
        }
        if(!strcmp(yytext,"->")) {
                print("ARROW");
                return ARROW;
        }
        if(!strcmp(yytext,"+=")) {
                print("PLUSEQ");
                return PLUSEQ;
        }
        if(!strcmp(yytext,"-=")) {
                print("MINUSEQ");
                return MINUSEQ;
        }
        if(!strcmp(yytext,"*=")) {
                print("MULTEQ");
                return MULTEQ;
        }
        if(!strcmp(yytext,"/=")) {
                print("DIVEQ");
                return DIVEQ;
        }
        if(!strcmp(yytext,"//=")) {
                print("DSLASHEQ");
                return DSLASHEQ;
        }
        if(!strcmp(yytext,"%=")) {
                print("MODEQ");
                return MODEQ;
        }
        if(!strcmp(yytext,"@=")) {
                print("DOTPRODEQ");
                return DOTPRODEQ;
        }
        if(!strcmp(yytext,"&=")) {
                print("BITANDEQ");
                return BITANDEQ;
        }
        if(!strcmp(yytext,"|=")) {
                print("BITOREQ");
                return BITOREQ;
        }
        if(!strcmp(yytext,"^=")) {
                print("BITXOREQ");
                return BITXOREQ;
        }
        if(!strcmp(yytext,">>=")) {
                print("RSHIFTEQ");
                return RSHIFTEQ;
        }
        if(!strcmp(yytext,"<<=")) {
                print("LSHIFTEQ");
                return LSHIFTEQ;
        }
        if(!strcmp(yytext,"**=")) {
                print("DSTAREQ");
                return DSTAREQ;
        }
        perror("Special Word, unimplemented.");
}

{OPERATOR} { 
        token_count++;
        if (!strcmp(yytext,"+")) {  
                print("ATOM +"); 
                return '+';
        }  
        if (!strcmp(yytext,"-")) {  
                print("ATOM -"); 
                return '-';
        }     
        if (!strcmp(yytext,"*")) {  
                print("ATOM *"); 
                return '*';
        } 
        if (!strcmp(yytext,"/")) {  
                print("ATOM /"); 
                return '/';
        }
        if (!strcmp(yytext,"%")) {  
                print("ATOM %"); 
                return '%';
        } 
        if (!strcmp(yytext,"@")) {  
                print("ATOM @"); 
                return '@';
        }  
        if (!strcmp(yytext,"<")) {  
                print("ATOM <"); 
                return '<';
        }  
        if (!strcmp(yytext,">")) {  
                print("ATOM >"); 
                return '>';
        } 
        if (!strcmp(yytext,"&")) {  
                print("ATOM &"); 
                return '&';
        }
        if (!strcmp(yytext,"|")) {  
                print("ATOM |"); 
                return '|';
        }
        if (!strcmp(yytext,"^")) {  
                print("ATOM ^"); 
                return '^';
        }
        if (!strcmp(yytext,"~")) {  
                print("ATOM ~"); 
                return '~';
        }
        if (!strcmp(yytext,"**")) {  
                print("DSTAR"); 
                return DSTAR;
        }
        if (!strcmp(yytext,"==")) {  
                print("EQUAL"); 
                return EQUAL;
        }
        if (!strcmp(yytext,"!=")) {  
                print("NOTEQUAL"); 
                return NOTEQUAL;
        }
        if (!strcmp(yytext,"//")) {  
                print("DSLASH"); 
                return DSLASH;
        }
        if (!strcmp(yytext,"<<")) {  
                print("LSHIFT"); 
                return LSHIFT;
        }
        if (!strcmp(yytext,">>")) {  
                print("RSHIFT"); 
                return RSHIFT;
        }
        if (!strcmp(yytext,"<=")) {  
                print("LSEQ"); 
                return LSEQ;
        }
        if (!strcmp(yytext,">=")) {  
                print("GREQ"); 
                return GREQ;
        }
        perror("Operator not implemented");
}

{VARIABLE} { 
        token_count++;
        print("VARIABLE"); 
        return VARIABLE;
}

 /*
  * When a quote is matched we enter the appropriate string state, either string_d
  * for a double quote or string_s for a single quote.
  * The logic for double quoted strings and single quoted strings is the same.
  *
  * If a return cariage char or quote is found we jump into state <unknown>
  * If a newline is found it's pushed back (so it can be handled by the rules in the following state)
  * and we enter the state <unknown>.
  * The EOF instantly produces and error
  * 
  * If a slash is found it we enter the state <string_{d,s}_esc> where
  * any character found other than a slash, n, r or quote makes us jump into the state <unknown>
  *
  */

{STRING_D}     { BEGIN(string_d); yymore(); }

<string_d>[\\] { BEGIN(string_d_esc); yymore(); }

<string_d>["] {
        BEGIN(INITIAL);  /* get out of state <string> */
        token_count++;
        print("STRING"); 
        return STRING;
}

<string_d>["'] { yyerror("Error: Unescaped %c in string.", yytext[yyleng-1]); BEGIN(unknown); yymore(); }
<string_d>[\r] { yyerror("Error: Unescaped \\r in string.", yytext[yyleng-1]); BEGIN(unknown); yymore(); }
<string_d>[\n] { yyerror("Error: Unescaped \\n in string.", yytext[yyleng-1]); BEGIN(unknown); yymore(); }
<string_d><<EOF>> { yyerror("Error: EOF reached while lexing string."); }

<string_d>.     { yymore(); }

<string_d_esc>["'nr\\] { BEGIN(string_d); yymore(); }

<string_d_esc>. { yyerror("Error: No such escape character like '\\%c'", yytext[yyleng-1]); BEGIN(unknown); yymore(); }

{STRING_S}      { BEGIN(string_s); yymore(); }

<string_s>[\\]  { BEGIN(string_s_esc); yymore(); }

<string_s>['] {
        BEGIN(INITIAL);  /* get out of state <string> */
        token_count++;
        print("STRING");
        return STRING;
}

<string_s>["'] { yyerror("Error: Unescaped %c in string.", yytext[yyleng-1]); BEGIN(unknown); yymore(); }
<string_s>[\r] { yyerror("Error: Unescaped \\r in string.", yytext[yyleng-1]); BEGIN(unknown); yymore(); }
<string_s>[\n] { yyerror("Error: Unescaped \\n in string.", yytext[yyleng-1]); BEGIN(unknown); yymore(); }
<string_s><<EOF>> { yyerror("Error: EOF reached while lexing string."); }

<string_s>.     { yymore(); }

<string_s_esc>["'nr\\] { BEGIN(string_s); yymore(); }

<string_s_esc>. { yyerror("Error: No such escape character like '\\%c'", yytext[yyleng-1]); BEGIN(unknown); yymore(); }

{INTCONST} { 
        token_count++;
        print("INTCONST"); 
        return INTCONST;
}
{FLOATCONST} {
        token_count++;
        print("FLOATCONST");
        return FLOATCONST; 
}
{IMAGCONST} { 
        token_count++;
        print("IMAGCONST");
        return IMAGCONST; 
}

{COMMENT} {
        print("COMMENT"); 
}

{DELIMITER} { }

 /* ignore newline if preceded by a slash */
\\ { BEGIN(concat_line); }

<concat_line>\n { BEGIN(INITIAL); line++; }

 /* if there is a character other than a newline after the slash it's an error
  * so we print an appropriate message and enter the appropriate state
  */
<concat_line>. { yyerror("Error: Expected newline after \\, found: %c", yytext[yyleng-1]); BEGIN(unknown); }

\n { 
        BEGIN(indent);
        line++; 
        token_count++;
        print("NEWLINE");
        return NEWLINE; 
}

 /* indents are 8 spaces or a tab character */
<indent>(\ ){8} {
        BEGIN(INITIAL);
        token_count++;
        print("INDENT");
        return INDENT;
}

<indent>[\t] {
        BEGIN(INITIAL);
        token_count++;
        print("INDENT");
        return INDENT;
}

<indent>. {
        yyless(yyleng-1);
        BEGIN(INITIAL);
}

<indent>\n {
        yyless(yyleng-1);
        BEGIN(INITIAL);
}

<<EOF>>	{ 
        fprintf(yyout, "#END-OF-FILE#\n");
        return YYEOF;
}

 /*
  * Anything not matching a rule is concidered unknown
  * if a delimiter is found the last character read is pushed back
  * and we jump back out of the state <unknown>
  * anything not a delimiter is consumed.
  * newlines are handled separetly to increace the line count
  */

{UNKNOWN_TOKEN} { BEGIN(unknown); yymore(); }

<unknown>{DELIMITER} {
                yyless(yyleng-1);
                token_error_count++;
                yyerror("Warning: UNKNOWN TOKEN, value: %s", yytext);
                BEGIN(INITIAL);
                }

<unknown>[\n]   { 
                yyless(yyleng-1);
                token_error_count++;
                yyerror("Warning: UNKNOWN TOKEN, value: %s", yytext);
                line++;
                BEGIN(INITIAL);
                }

<unknown>. { yymore(); }
%%

/* Array with all the tokens and the corresponding numbers as defined in token.h */

void print(const char *s)
{
        fprintf(yyout, "\tFlex -> Found token: %s \n", s);
}

/* respect indent size of 8 */
/* vim: set tabstop=8 shiftwidth=8 softtabstop=8 expandtab: */
