%{
	#include <stdio.h>  
	#include <string.h>  
	#include "y.tab.h"
	#define SIZE 50
	#define TOKENIZE 1
	char * p;  
	
	int yycolumn = 1; 
	int startFlag = 1;
	#define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno;  \
	yylloc.first_column = yycolumn; yylloc.last_column = yycolumn + yyleng - 1;  \
	yycolumn += yyleng;  
	
	static int sp = 0;
	static int stack[SIZE];
	static void print_token(const char *X)
 	{
 		#if TOKENIZE
 		if(startFlag)
 		{
 			printf("-----------------Tokenisation-----------------------------\n ");
 			startFlag=0;
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
	static void push(int i)
	{
		if(sp+1 < SIZE)
		{
			stack[++sp] = i; 
		}
		else{ 
			printf("error occured stack overflow\n");
			exit(1); 
		}
	}
	
	int pop()
	{ 
		if(sp > -1)
			return stack[sp--]; 
		else{  
			printf("error : stack underflow \n"); 
			exit(1); 
		}
	}
	
	int top()
	{ 
		if(sp > -1)
			return stack[sp]; 
		else
			return 0;   
	}
	
	static int indent_depth(const char * string)
	{
		int length = strlen(string);
		//printf("The length of indentation  = %d\n",length);
		int tab_count = 0; 
		for(int i = 0; i < length; ++i)
		{	
			if(string[i] == '\t')
			{
				tab_count++; 
			}
			else {
				break;
			}
		}	
		return tab_count;
	}
	int depth = 0; 
		
%} 
%option yylineno 
whitespace	[ ]
MultilineComment	\'\'\'(.|\n)+\'\'\'
%% 

[\t]*	{
			//printf("I came here \n");
			depth = indent_depth(yytext);
			//printf("The depth %d\n",depth);
			//printf("The top %d\n",top());
			if(depth < top())
			{
				while(depth < top())
					pop(); 
				yylval.depth = depth;
				print_token("DD"); 
				return DD;
			} 
			if(depth == top())
			{
				yylval.depth = depth; 
				print_token("ND");
				return ND; 
			}
			if(depth > top()) 
			{
				push(depth); 
				yylval.depth = depth; 
				print_token("ID");
				return ID; 
			}
		}
"import"	{print_token("IMPT");return T_Import;}
"print"	{print_token("Print");return T_Print;}
"pass"	{print_token("Pass");return T_Pass;}
"if"	{print_token("If");return T_If;}
"in"	{print_token("In");return T_In;}
"while"	{print_token("While");return T_While;}
"break"	{print_token("Break");return T_Break;}
"and"	{print_token("And");return T_And;}
"or"	{print_token("Or");return T_Or;}
"not"	{print_token("Not");return T_Not;}
"elif"	{print_token("Elif");return T_Elif;}
"else"	{print_token("Else");return T_Else;}
"def"	{print_token("Def");return T_Def;}
"return"	{print_token("Return");return T_Return;}
":"	{print_token("Cln");return T_Cln;}
">"	{print_token("GT");return T_GT;}
"<"	{print_token("LT");return T_LT;}
">="	{print_token("GTE");return T_GTE;}
"<="	{print_token("LTE");return T_LTE;}
"=="	{print_token("EQ");return T_EQ;}
"!="	{print_token("NEQ");return T_NEQ;}
"True"	{print_token("True");return T_True;}
"False"	{print_token("False");return T_False;}
"+"	{print_token("PL");return T_PL;}
"-"	{print_token("MN");return T_MN;}
"*"	{print_token("ML");return T_ML;}
"/"	{print_token("DV");return T_DV;}
"("	{print_token("OP");return T_OP;}
")"	{print_token("CP");return T_CP;}
"["	{print_token("OB");return T_OB;}
"]"	{print_token("CB");return T_CB;}
","	{print_token("Comma");return T_Comma;}
"="	{print_token("EQL");return T_EQL;}
[0-9]+(\.[0-9]+)?([Ee][+-]?[0-9]+)?	{yylval.text = strdup(yytext); print_token(yylval.text);return T_Number;}
[_a-zA-Z][_a-zA-Z0-9]*	{yylval.text = strdup(yytext);print_token(yylval.text); return T_ID;}
\"([^\"\n])*\"	{yylval.text = strdup(yytext);print_token(yylval.text);return T_String;}
\'([^\'\n])*\'	{yylval.text = strdup(yytext);print_token(yylval.text);return T_String;}
"#"([a-z]|[0-9]|[A-Z]|" ")*	{}
{whitespace}	{}
{MultilineComment}	{}
"\n"	{yycolumn = 1;print_token("NL");return T_NL;}
<<EOF>>	{print_token("EOF");return T_EndOfFile;}
%%




