%{
#include<stdio.h>
#include<string.h>
#include<stdlib.h>
extern int lineno;
%}

%token TOK_MAIN TOK_LPARANTH TOK_RPARANTH TOK_LBRACE TOK_RBRACE TOK_PRINT
	TOK_SEMICOLON TOK_EQUALS TOK_NUM TOK_ID TOK_SUB TOK_MUL TOK_FLOAT

%union{
	float float_val;
	char id[100];
	}

%code requires{

struct table
{
	char name[100];
	float value;
};
	      }

%code{
struct table symboltable[9000]; int pos=0; int label[10]={0,0,0,0,0,0,0,0,0,0};
int i=-1;
     }

%type <float_val> exprs TOK_NUM
%type <id>  TOK_ID

%left TOK_SUB 
%left TOK_MUL

%%

prog: TOK_MAIN TOK_LPARANTH TOK_RPARANTH TOK_LBRACE stmts TOK_RBRACE
    ;

stmts:  |stmt TOK_SEMICOLON stmts
;

stmt:	TOK_FLOAT TOK_ID
    	{
		strcpy(symboltable[pos].name,$2);
		symboltable[pos].value=0.0;
		pos++;
		
		      	    
	}

       |TOK_PRINT TOK_ID
	{
	 int k;int j=2;int m;
	for(k=pos-1;k>=0;k--)
	    {
		j=strcmp(symboltable[k].name,$2);
	    
		if(j==0)
			{
			m=k;
			goto next;
			}
	   }
	next: printf("%f\n",symboltable[m].value);
            
	}
      
      |TOK_ID TOK_EQUALS exprs
	{
	int k; int j;int m;
	for(k=pos-1;k>=0;k--)
		{
		j=strcmp(symboltable[k].name,$1);
		if(j==0)
			{
			m=k;
			goto nextt;
			}
		}
	nextt: symboltable[m].value=$3;
	}

      | TOK_LPARANTH_COUNT stmts TOK_RPARANTH_COUNT

;
TOK_LPARANTH_COUNT: TOK_LBRACE
	  	{
			i++;
			label[i]=pos;
			
		}
;
TOK_RPARANTH_COUNT: TOK_RBRACE
	  	{
		pos=label[i];
		i--;
		}
;
exprs:	TOK_NUM
     		{
		$$=$1;
		}
       | TOK_SUB TOK_NUM
		{
		$$=-$2;
		}
	
       |  TOK_ID
	  	{
		int k; int j;int m;
		for(k=pos-1;k>=0;k--)
		{
		j=strcmp(symboltable[k].name,$1);
		if(j==0)
			{
			m=k;
			goto nexttt;
			}
		}
		nexttt:$$=symboltable[m].value ;
	}

      | exprs TOK_SUB exprs
	{
	$$=$1-$3;
	}

     | exprs TOK_MUL exprs
	{
	$$=$1*$3;
	}
    
     | TOK_LPARANTH TOK_SUB TOK_NUM TOK_RPARANTH
	{$$=-$3;}

;


%%

int  yyerror(char *s)
	{
	fprintf(stderr,"Parsing error at line %d\n",lineno);
	return 0;
	}

int main()	
	{
	struct table symboltable[9000];
	int pos=0; int label[10];
	int i=-1;
	yyparse();
	return 0;
	}
