%{
	#include <string.h>
	#include "y.tab.h"
	#define SIZE 100
	#define PRINT_TOKEN 1
	
	int yycolumn = 1;
	int start_flag = 1;
	
	#define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno; 		\
    yylloc.first_column = yycolumn; yylloc.last_column = yycolumn + yyleng - 1; 	\
    yycolumn += yyleng;												
    
 	static int sp=0; 
 	static int stack [SIZE];
 	
 	static void print_tokens(const char *X)
 	{
 		#ifdef PRINT_TOKEN
 		if(start_flag)
 		{
 			printf("---------------------------------Token Sequence--------------------------\n1 ");
 			start_flag=0;
 		}
 		
 		if(strcmp(X, "NL")==0)
 		{
 			printf("T_%s\n", X);
 		}
		else
		{
			printf("T_%s ", X);	
		}
 		#endif
 	}
 	static void push (int i) 
 	{
   		if (++sp< SIZE) stack[sp]= i;
   		else {printf ("STACK OVERFLOW\n"); exit(1);}
 	}
 	
 	int pop () 
 	{
   		if (sp>-1) return stack[sp--];
   		else {printf ("STACK UNDERFLOW\n"); exit(1);}
 	}
 	
 	int top()
 	{
 		if(sp>-1) return stack[sp];
 		else return 1;
 	}
 	
 	static int indent_depth(const char *K)
	{
		int len = strlen(K), i, tab_count=1;
		for(i=0; i< len ; i++)
		{
			if(K[i]=='\t')
			{
				tab_count++;
			}
			else
			{
				break;
			}	
		}
		return tab_count;
	}	
 	int depth = 1;
 		
%}
%option yylineno
whitespace [ ]
Multiline_comment \'\'\'.+\'\'\'
%%

[\t]*		{
			depth = indent_depth(yytext);
//			printf("Depth : %d ",  depth);
			if(depth < top())
			{
				while (depth < top()) pop();
				yylval.depth = depth;
				print_tokens("DD");
				return DD;
			}
			
			if(depth == top())
			{
				print_tokens("ND");
				yylval.depth = depth;
				return ND;				
			}
			if(depth > top())
			{
				push(depth);
				print_tokens("ID");
				yylval.depth = depth;
				return ID;
			}
			
		}

"import" {print_tokens("IMPT"); return T_Import;}
"print"  {print_tokens("Print"); return T_Print;}
"pass" {print_tokens("Pass"); return T_Pass;}
"if" {print_tokens("If"); return T_If;}
"in" {print_tokens("In"); return T_In;}
"while" {print_tokens("While"); return T_While;}
"break" {print_tokens("Break"); return T_Break;}
"and" {print_tokens("And"); return T_And;}
"or" {print_tokens("Or"); return T_Or;}
"not" {print_tokens("Not"); return T_Not;}
"elif" {print_tokens("Elif"); return T_Elif;}
"else" {print_tokens("Else"); return T_Else;}
"def" {print_tokens("Def"); return T_Def;}
"return" {print_tokens("Return"); return T_Return;}
":" {print_tokens("Cln"); return T_Cln;}
">" {print_tokens("GT"); return T_GT;}
"<" {print_tokens("LT"); return T_LT;}
">=" {print_tokens("EGT"); return T_EGT;}
"<=" {print_tokens("ELT"); return T_ELT;}
"==" {print_tokens("EQ"); return T_EQ;}
"!=" {print_tokens("NEQ"); return T_NEQ;}
"True" {print_tokens("True"); return T_True;}
"False" {print_tokens("False"); return T_False;}
"+" {print_tokens("PL"); return T_PL;}
"-" {print_tokens("MN"); return T_MN;}
"*" {print_tokens("ML"); return T_ML;}
"/" {print_tokens("DV"); return T_DV;}
"(" { print_tokens("OP"); return T_OP;}
")" {print_tokens("CP"); return T_CP;}
"[" {print_tokens("OB"); return T_OB;}
"]" {print_tokens("CB"); return T_CB;}
"," {print_tokens("Comma"); return T_Comma;}
"=" {print_tokens("EQL"); return T_EQL;}
"list" {print_tokens("List"); return T_List;}
[0-9]+ {yylval.text = strdup(yytext); print_tokens(yylval.text); return T_Number;}
[_a-zA-Z][_a-zA-Z0-9]* {yylval.text = strdup(yytext); print_tokens(yylval.text); return T_ID;}
\"([^\"\n])*\" {yylval.text = strdup(yytext); print_tokens(yylval.text); return T_String;}
\'([^\'\n])*\' {yylval.text = strdup(yytext); print_tokens(yylval.text); return T_String;}
"#"([a-z]|[0-9]|[A-Z]|" ")* {}
{whitespace} {} 
"\n" {yycolumn=1; print_tokens("NL"); return T_NL;}
<<EOF>> {print_tokens("EOF"); return T_EndOfFile;}

%%
