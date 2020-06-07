/* Onoma arxeiou:       simple-bison-code.y
   Perigrafh:           Ypodeigma gia anaptyksh syntaktikou analyth me xrhsh tou ergaleiou Bison
   Syggrafeas:          Ergasthrio Metaglwttistwn, Tmhma Mhxanikwn Plhroforikhs kai Ypologistwn,
                        Panepisthmio Dytikhs Attikhs
   Sxolia:              To paron programma ylopoiei (me th xrhsh Bison) enan aplo syntaktiko analyth
                        pou anagnwrizei thn prosthesh (dekadikwn mono) akeraiwn arithmwn kai metablhtwn
                        kai ektypwnei to apotelesma sthn othonh (thewrontas oti oi metablhtes exoun
                        panta thn timh 0). Leitourgei autonoma, dhladh xwris Flex kai anagnwrizei kena
                        (space & tab), (dekadikous) akeraious kai onomata metablhtwn ths glwssas
                        Uni-Python enw diaxeirizetai tous eidikous xarakthres neas grammhs '\n' (new
                        line) kai 'EOF' (end of file). Kathara gia logous debugging typwnei sthn
                        othonh otidhpote epistrefei h synarthsh yylex().
   Odhgies ekteleshs:   Dinete "make" xwris ta eisagwgika ston trexonta katalogo. Enallaktika:
                        bison -o simple-bison-code.c simple-bison-code.y
                        gcc -o simple-bison-code simple-bison-code.c
                        ./simple-bison-code
*/

%{
/* Orismoi kai dhlwseis glwssas C. Otidhpote exei na kanei me orismo h arxikopoihsh
   metablhtwn & synarthsewn, arxeia header kai dhlwseis #define mpainei se auto to shmeio */
        #include <stdio.h>
        #include <stdlib.h>
        #include <stdarg.h>
        #include <string.h>
        #include <math.h>
        /* #define YYDEBUG 1 */
        int  yylex(void);
        void yyerror(const char *restrict format, ...);
        void yywarn(const char *restrict format, ...);
        void found(const char *name);

        /* counter is used to keep a running count
         * of how many expressions the parser has found
         */
        int counter = 0;

        /* assume stdout is to a terminal emulator */
        int terminal = 1;

        extern int line;
        extern int token_count;
        extern int token_error_count;
        extern FILE *yyin, *yyout;
%}

/* Orismos twn anagnwrisimwn lektikwn monadwn. */
%nonassoc INTCONST IMAGCONST FLOATCONST NEWLINE 
%nonassoc STRING
%nonassoc VARIABLE 
%nonassoc DEL LEN PRINT WHILE IF CMP AND OR NOT
%nonassoc INDENT RETURN
%nonassoc DEF
%nonassoc '+' '-' '*' '/' '%' '@' '<' '>' '&' '|' '^' '~' '!' '(' ')' '[' ']' '{' '}' ',' ':' ';' '\\' /* atoms */
%nonassoc DSTAR DSLASH LSHIFT RSHIFT LSEQ GREQ EQUAL NOTEQUAL ARROW PLUSEQ MINUSEQ MULTEQ DIVEQ MODEQ DOTPRODEQ
%nonassoc BITANDEQ BITOREQ BITXOREQ
%nonassoc DSLASHEQ RSHIFTEQ LSHIFTEQ DSTAREQ
%nonassoc UNKNOWN_TOKEN
%%

   /* Orismos twn grammatikwn kanonwn. Kathe fora pou antistoixizetai enas grammatikos
    * kanonas me ta dedomena eisodou, ekteleitai o kwdikas C pou brisketai anamesa sta
    * agkistra. H anamenomenh syntaksh einai:
    *                           onoma : kanonas { kwdikas C }
    */
program
        : program literal_line
        | program error NEWLINE { yyclearin;  } /* catch errors and resume after next NEWLINE */
        |
        ;

type
        : INTCONST
        | IMAGCONST
        | FLOATCONST
        | VARIABLE { $$ =-3; }
        | STRING
        | func_call
        | builtin
        | slice
        ;

expr
        : type
        | type '+' expr      { found("Addition expr"); }
        | type '-' expr      { found("Subtraction expr"); }
        | type '*' expr      { found("Multiplication expr"); }
        | type '/' expr      { found("Division expr"); }
        | type '%' expr      { found("Modulo expr"); }
        | type '@' expr      { found("Dot Product expr"); }
        | type '<' expr      { found("Less Than expr"); }
        | type '>' expr      { found("Greater Than expr"); }
        | type '&' expr      { found("Bitwise And expr"); }
        | type '|' expr      { found("Bitwise Or expr"); }
        | type '^' expr      { found("Bitwise Xor expr"); }
        | '~' expr           { found("Bitwise Invertion expr"); $$ = $2; }
        | type DSTAR    expr { found("Power expr"); }
        | type DSLASH   expr { found("Floor Division expr"); }
        | type LSHIFT   expr { found("Bitwise Shift Left expr"); }
        | type RSHIFT   expr { found("Bitwise Shift Right expr"); }
        | type LSEQ     expr { found("Less Than Equal expr"); }
        | type GREQ     expr { found("Greater Than Equal expr"); }
        | type EQUAL    expr { found("Equal expr"); }
        | type NOTEQUAL expr { found("Not Equal expr"); }
        | type AND expr      { found("Logical AND expr"); }
        | type OR expr       { found("Logical OR expr"); }
        | type NOT expr      { found("Logical NOT expr"); }
        ;

assign
        : assignable '=' expr       { found("Assingment from expr"); }
        | assignable '=' list       { $$ = $3; found("Assingment from list"); }
        | assignable '=' tuple      { $$ = $3; found("Assingment from tuple"); }
        | assignable '=' merge      { found("Assingment from merge"); }
        | assignable PLUSEQ    expr { found("Equal Addition expr"); }
        | assignable MINUSEQ   expr { found("Equal Subtraction expr"); }
        | assignable MULTEQ    expr { found("Equal Multiplication expr"); }
        | assignable DIVEQ     expr { found("Equal Division expr"); }
        | assignable MODEQ     expr { found("Equal Modulo expr"); }
        | assignable DOTPRODEQ expr { found("Equal Dot product expr"); }
        | assignable BITANDEQ  expr { found("Equal Bitwise And expr"); }
        | assignable BITOREQ   expr { found("Equal Bitwise Or expr"); }
        | assignable BITXOREQ  expr { found("Equal Bitwise Xor expr"); }
        | assignable DSLASHEQ  expr { found("Equal Floor Division expr"); }
        | assignable LSHIFTEQ  expr { found("Equal Bitwise Shift Left expr"); }
        | assignable RSHIFTEQ  expr { found("Equal Bitwise Shift Right expr"); }
        | assignable DSTAREQ   expr { found("Equal Power expr"); }
        ;

assignable
        : VARIABLE
        | slice
        ;

literal_line
        : logic_line NEWLINE { found("Line");  }
        | if                 { found("Line"); }
        | while              { found("Line"); }
        | NEWLINE            { found("Empty Line"); }
        ;

logic_line
        : logic_line ';' statement
        | statement
        ;

statement
        : assign
        | func
        | STRING    { found("Docstring"); }
        | func_call { found("Function Call"); }
        ;

if
        : IF expr ':' NEWLINE indentbody   { found("If statement"); }
        | IF expr ':' logic_line NEWLINE   { found("If statement"); found("Line"); }
        /* Print warning on missing : */
        | IF expr NEWLINE indentbody       { found("If statement"); yywarn("Missing ':' after if condition."); yynerrs++; }
        | IF expr logic_line NEWLINE       { found("If statement"); found("Line"); yywarn("Missing ':' after if condition."); yynerrs++; }
        ;

while
        : WHILE expr ':' NEWLINE indentbody { found("While loop"); }
        | WHILE expr ':' logic_line NEWLINE { found("While loop"); found("Line"); }
        /* Print warning on missing : */
        | WHILE expr NEWLINE indentbody     { found("While loop"); yywarn("Missing ':' after while condition."); yynerrs++; }
        | WHILE expr logic_line NEWLINE     { found("While loop"); found("Line"); yywarn("Missing ':' after while condition."); yynerrs++; }
        ;

list
        : '[' content ']' { found("Literal List"); $$ = $2; }
        /* Contain errors in list declaration until closing bracket */
        | '[' content ')' { yywarn("Misspelled ']' for ')' in literal list "); found("Literal List"); $$ = $2; }
        ;

slice
        : VARIABLE '[' INTCONST ']'
        | VARIABLE '[' VARIABLE ']'
        /* Contain errors between brackets */
        ;

tuple
        : '(' content ')' { found("Literal Tuple"); $$ = $2; }
        /* Contain errors in tuple declaration until closing parenthesis */
        | '(' content ']' { yywarn("Mispelled ')' for ']' in literal tuple."); found("Literal Tuple"); $$ = $2; }
        ;

merge
        : list '+' list     { found("Merge of Lists"); $$ = $1 + $3; }
        | list error list   { yywarn("'+' expected between when merging lists."); found("Merge of Lists"); $$ = $1 + $3; }
        | tuple '+' tuple   { found("Merge of Tuples" ); $$ = $1 + $3; }
        | tuple error tuple { yywarn("'+' expected between when merging tuples."); found("Merge of Tuples"); $$ = $1 + $3; }
        ;

content
        : content ',' listable { $$ = $1 + 1; }
        | listable             { $$ = 1; }
        |                      { $$ = 0; }
        ;

listable
        : expr
        | list
        | tuple
        ;

builtin
        : DEL '(' VARIABLE ')'    { found("Delete Function"); }
        | LEN '(' list ')'        { found("Length Function"); }
        | LEN '(' VARIABLE ')'    { found("Length Function"); }
        | LEN '(' tuple ')'       { found("Length Function"); }
        | PRINT '(' printable ')' { found("Print Function"); }
        | PRINT builtin           { found("Print Function"); }
        | comp_function
        ;

printable
        : printable ',' printable
        | expr
        | list
        | tuple
        |
        ;

func_call
        : VARIABLE '(' arglist ')'
        ;

func
        : builtin
        | userfunc { found("Function Defintion"); }
        ;

userfunc
        : DEF VARIABLE '(' def_arglist ')' ':' NEWLINE indentbody INDENT RETURN expr
        | DEF VARIABLE '(' def_arglist ')' ':' NEWLINE indentbody INDENT RETURN
        /* Print Warning for missing for missing : */
        | DEF VARIABLE '(' def_arglist ')' NEWLINE indentbody INDENT RETURN expr { yywarn("Missing ':' after function definition."); yynerrs++; }
        | DEF VARIABLE '(' def_arglist ')' NEWLINE indentbody INDENT RETURN      { yywarn("Missing ':' after function definition."); yynerrs++; }
        ;

arglist
        : arglist ',' arg
        | arg
        | 
        ;

def_arglist
        : def_arglist ',' VARIABLE
        | VARIABLE
        |
        ;

arg
        : list
        | tuple
        | expr
        ;

indentbody
        : INDENT literal_line
        | indentbody INDENT literal_line
        ;

comp_function
        : CMP '(' list ',' list ')'   { 
                if ( $3 != $5 ){ 
                        yyerror("cmp expects lists of equal lenght, got lengths of: %d and %d",$3,$5);
                        yynerrs++;
                } 
                found("Compare Function with Lists");
                $$ = 1; 
        }
        | CMP '(' tuple ',' tuple ')' { 
                if ( $3 != $5 ){
                        yyerror("cmp expects tuples of equal length, got lengths of %d and %d",$3,$5); 
                        yynerrs++;
                } 
                $$ = 1;
                found("Compare Function with Tuples");
        }
        | CMP '(' VARIABLE ',' VARIABLE ')' { found("Compare Function with Variables"); }
        | CMP '(' tuple ',' VARIABLE ')'    { found("Compare Function with Tuple and Variable"); }
        | CMP '(' VARIABLE ',' tuple ')'    { found("Compare Function with Variable and Tuple"); }
        | CMP '(' list ',' VARIABLE ')'     { found("Compare Function with List and Variable"); }
        | CMP '(' VARIABLE ',' list ')'     { found("Compare Function with Variable and List"); }
        | CMP '(' list ',' tuple ')'        { yyerror("Mismatch of argument types (CMP LIST AND TUPLE)"); yynerrs++; }
        | CMP '(' tuple ',' list ')'        { yyerror("Mismatch of argument types (CMP LIST AND TUPLE)"); yynerrs++; }
        ;

%%

        /* 
         * yyerror and yywarn take a format string (like printf does)
         * prepend the line number and 'error' or 'warning'
         * color the text if yyout is pointing to a terminal
         * and print the msg given to them formated correctly
         */

void yyerror(const char *restrict format, ...)
{
        va_list vl;

        if (terminal)
                fprintf(yyout, "\033[1;31m"); //color red
        fprintf(yyout, "Line %d: error: ", line);

        va_start(vl, format);
        vfprintf(yyout,format, vl);
        if (terminal)
                fprintf(yyout, "\033[0m"); //reset color
        fprintf(yyout, "\n");
        va_end(vl);
}

void yywarn(const char *restrict format, ...)
{
        va_list vl;

        if (terminal)
                fprintf(yyout, "\033[1;35m"); //color magenta
        fprintf(yyout, "Line %d: warning: ", line);

        va_start(vl, format);
        vfprintf(yyout,format, vl);
        if (terminal)
                fprintf(yyout, "\033[0m"); //reset color
        fprintf(yyout, "\n");
        va_end(vl);
}

void found(const char *restrict name)
{
        fprintf(yyout, "\t\tParser -> Found(%d): %s\n", counter, name);
        counter++;
}


/* H synarthsh main pou apotelei kai to shmeio ekkinhshs tou programmatos.
   Sthn sygkekrimenh periptwsh apla kalei thn synarthsh yyparse tou Bison
   gia na ksekinhsei h syntaktikh analysh. */

int main(int argc, char *argv[])
{
        /* yydebug = 1; */

        /* Check command line arguments. If argc is 3, read from the file in the
         * second argument and write in the file from the third. If argc is 2
         * then read from the file in the second argument and write to the screen.
         * Note: argv[0] is the filename given on the command line to run this program
         */


        if(argc == 3){
                /* stdout is a file so set terminal to 0 */
                terminal = 0;
                if(!(yyin = fopen(argv[1], "r"))) {
                        fprintf(stderr, "Cannot read file: %s\n", argv[1]);
                        return 2;
                }
                if(!(yyout = fopen(argv[2], "w"))) {
                        fprintf(stderr, "Cannot create file: %s\n", argv[2]);
                        return 2;
                }
        }
        else if(argc == 2){
                if(!(yyin = fopen(argv[1], "r"))) {
                        fprintf(stderr, "Cannot read file: %s\n", argv[1]);
                        return 2;
                }
        }

        yyparse();

        if (yynerrs == 0) {
                if (terminal)
                        fprintf(yyout, "\033[1;32m"); //color magenta
                fprintf(yyout, "Parsing Succesful!\n");
        } else {
                if (terminal)
                        fprintf(yyout, "\033[1;31m"); //color magenta
                fprintf(yyout, "Parsing Failed!\n");
        }

        fprintf(yyout, "Tokens %d\n", token_count);
        fprintf(yyout, "Token errors %d\n", token_error_count);
        fprintf(yyout, "Syntax errors %d\n",yynerrs);
        fprintf(yyout, "Expresions %d\n", counter);
        
        if (terminal)
                fprintf(yyout, "\033[0m"); //reset color

        return 0;
}

/* respect indent size of 8 */
/* vim: set tabstop=8 shiftwidth=8 softtabstop=8 expandtab: */
