%{
    enum tokentype
    {
        T_NUMBER = 258,
        T_BOOL = 259,
        T_NULL = 260,
        T_STRING = 261,
        T_OBJ_STRT = 262,
        T_OBJ_END = 263,
        T_OBJ_KEY = 264,
        T_ARR_STRT = 265,
        T_ARR_END = 266
    };

    // typedef struct token
    // {
    //     int type;
    //     union
    //     {
    //         int intval;
    //         char* strval;
    //     } value;
    // } token;

    int intval;
    char* strval;
%}

curly_start     \{
curly_end       \}
bract_start     \[
bract_end       \]
paren_start     \(
paren_end       \)
colon           :

whitespace      [\t\n\v\f\r ]+
space           [ ]+
digit           [\-0-9]
digits          {digit}+
bool            true|false
null            "<>"
quoted_word     [a-zA-Z_0-9\"\"]+
unquoted_word   [a-zA-Z_0-9]+

spaced_digit    {digits}{space}
constvalue      {spaced_digit}{bract_start}{space}{spaced_digit}+{bract_end}

%%

{constvalue} {
    // reads string until the first space
    // converts to int
    int space_at = 0;

    while (yytext[space_at++] != ' ');
    space_at--;

    yytext[space_at] = '\0';

    intval = atoi(yytext);
    return T_NUMBER;
}
{digits} { intval = atoi(yytext); return T_NUMBER; }
{bool} { intval = yytext[1] == 't'; return T_BOOL; }
{null} { return T_NULL; }
{unquoted_word} { strval = yytext; return T_STRING; }
{quoted_word}   {
                    // remove the quote
                    int len = strlen(yytext);
                    yytext[len-1] = '\0';
                    strval = yytext+1;
                    return T_STRING;
                }

{curly_start}{unquoted_word} { strval = yytext+1; return T_OBJ_STRT; }
{colon}{unquoted_word} { strval = yytext+1; return T_OBJ_KEY; }
{curly_end} {  return T_OBJ_END; }
{paren_start} { return T_ARR_STRT; }
{paren_end} { return T_ARR_END; }
{whitespace} { /* ignore */ }

%%

#define PRINT_COMMA printf(",")
#define PRINT_NEWLINE printf("\n");
#define PRINT_COMMA_OPT \
    if (prev_tok == T_STRING || prev_tok == T_NUMBER || prev_tok == T_BOOL || prev_tok == T_NULL || prev_tok == T_OBJ_END || prev_tok == T_ARR_END) \
    { \
        PRINT_COMMA; \
        PRINT_NEWLINE; \
    };
#define PRINT_STRING(str) printf("\"%s\"", (str));
#define PRINT_KEY(key) printf("\"%s\": ", (key));
#define PRINT_INDENTATION \
    { \
        int i = 0; \
        while (i++ < indent) \
            printf(" "); \
    }

#define INDENT indent += 4;
#define DEINDENT indent -=4;

void main(int argc, char **argv)
{
    int tok;
    int prev_tok = -1;
    int indent = 0;

    while(tok = yylex())
    {
        switch (tok)
        {
            case T_OBJ_STRT:
                // PRINT_INDENTATION;

                PRINT_COMMA_OPT;
                printf("{");
                PRINT_NEWLINE;

                // INDENT;
                // PRINT_INDENTATION;

                PRINT_KEY("type");
                PRINT_STRING(strval);
                break;

            case T_OBJ_END:
                PRINT_NEWLINE;

                // DEINDENT;
                // PRINT_INDENTATION;

                printf("}");
                break;

            case T_OBJ_KEY:
                PRINT_COMMA;
                PRINT_NEWLINE;

                // PRINT_INDENTATION;

                PRINT_KEY(strval);
                break;

            case T_ARR_STRT:

                PRINT_COMMA_OPT;
                printf("[");
                PRINT_NEWLINE;
                break;

            case T_ARR_END:
                PRINT_NEWLINE;
                printf("]");
                break;

            case T_STRING:
                PRINT_COMMA_OPT;
                PRINT_STRING(strval);
                break;

            case T_NUMBER:
                PRINT_COMMA_OPT;
                printf("%d", intval);
                break;

            case T_BOOL:
                PRINT_COMMA_OPT;
                printf("%s", intval ? "true" : "false");
                break;

            case T_NULL:
                PRINT_COMMA_OPT;
                printf("null");
                break;

            default:
                break;
        }

        prev_tok = tok;
    }
}
