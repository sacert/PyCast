%{
  #include <stdio.h>
%}

%x DOUB_QUOTE_CONTENT
%%

\"          { printf("\""); BEGIN DOUB_QUOTE_CONTENT; }
"//".*\n    { printf("\n"); }
"/*"        {
    printf ("    ");
    register int c;

    for ( ; ; )
    {
        while ( (c = input()) != '*' && c != EOF ) printf(" ");    /* eat up text of comment */

        if ( c == '*' )
        {
            while ( (c = input()) == '*' );
            if ( c == '/' ) break;    /* found the end */
        }

        if ( c == EOF ) break;
    }
}

<DOUB_QUOTE_CONTENT>{
    \" { printf("\""); BEGIN(INITIAL); }
}

%%

