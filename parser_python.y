%{ 
	#include <stdio.h>  
	#include <stdarg.h>  
	#include <stdlib.h>  
	#include <string.h>  
	
	extern int yylineno;
	extern int depth; 
	extern int top(); 
	extern int pop(); 
	
	struct table_record
	{
		char * type; 
		char * name;  
		int line_declared; 
		int last_line_used; 
	};
	
	typedef struct table_record table_record;  
	
	table_record * symbolTable;  
	int index_t = -1; 
	
	void init()
	{	
		symbolTable = (table_record*)malloc(sizeof(table_record)*100); 
		printf("......Symbol Table is activated......[*]\n");
	}
	
	int search_record(const char * type, const char * name) 
	{
		for(int i = 0; i  <= index_t; ++i) 
		{
			if((strcmp(symbolTable[i].type,type) == 0) &&(strcmp(symbolTable[i].name,name) == 0))
			{
				return i;
			}
		}
		return -1;
	}	
	void edit_record(int index, const char * type, const char * name, int lineNo)
	{
		symbolTable[index].last_line_used = lineNo; 
	}
	void insert_record(const char * type, const char * name, int lineNo)
	{ 
		//printf("type added: %s and name : %s\n",type,name);
		int indexIfavailable = search_record(type,name); 
		if(indexIfavailable == -1)
		{
			//printf("I came in insert\n");
			++index_t; 
			symbolTable[index_t].type = (char *)malloc(sizeof(char)*30); 
			symbolTable[index_t].name = (char *)malloc(sizeof(char)*30); 
			strcpy(symbolTable[index_t].type, type); 
			strcpy(symbolTable[index_t].name, name); 
			symbolTable[index_t].line_declared = lineNo; 
			symbolTable[index_t].last_line_used = lineNo; 
		}
		else
		{ 
			//printf("I came to edit \n");
			edit_record(indexIfavailable,type,name,lineNo); 
		}
	}
	void displaySymbolTable() 
	{	printf("\n\n+--------------------------------The symbol Table----------------------------------------------+ ");
		printf("\nS.No        Symbol            Type           Declaration_line_no        Last_line_used\n\n");
		printf("--------+----------------+-----------------+-----------------------------+------------------------+\n"); 
		for(int i = 0; i <= index_t; ++i)
		{	
			printf("%-15d %-15s %-15s %-15d\t %-15d\n",i+1,symbolTable[i].name,symbolTable[i].type,symbolTable[i].line_declared,symbolTable[i].last_line_used);
		}
	}
	void reset_depth()
	{
		while(top()) pop();
		depth = 0;
	}
	
%}  
%union
{
	char * text; 
	int depth; 
}
%locations 

%token T_Number T_EndOfFile T_Import T_Print T_Pass T_If T_In T_While T_Break T_And T_Or T_Not T_Elif T_Else T_Def T_Return T_Cln T_GT T_LT T_GTE T_LTE T_EQ T_NEQ T_True T_False T_PL T_MN T_ML T_DV T_OP T_CP T_OB T_CB T_Comma T_EQL T_ID T_String T_NL ID ND DD 
%right T_EQL                                          
%left T_PL T_MN
%left T_ML T_DV
%nonassoc T_If
%nonassoc T_Elif
%nonassoc T_Else


%%
StartDebugger : {init();} StartParse T_EndOfFile {printf("\nValid Python Syntax\n------------------------------------------------------------"); displaySymbolTable();exit(0);} ;
constant : T_Number {insert_record("Constant", $<text>1, @1.first_line);}
         | T_String {insert_record("Constant", $<text>1, @1.first_line);}
         ;
term : T_ID {insert_record("Identifier", $<text>1, @1.first_line);} 
     | constant 
     ;
StartParse : T_NL StartParse | finalStatements T_NL {reset_depth();}StartParse | finalStatements T_NL;    

basic_stmt : pass_stmt 
           | break_stmt 
           | import_stmt
           | assign_stmt
           | arith_exp 
           | bool_exp 
           | print_stmt 
           | return_stmt
           ;
arith_exp : term
          | arith_exp  T_PL  arith_exp
          | arith_exp  T_MN  arith_exp
          | arith_exp  T_ML  arith_exp
          | arith_exp  T_DV  arith_exp
          | T_MN arith_exp 
          | T_OP arith_exp T_CP
          ;
bool_exp : bool_term T_Or bool_term
         | arith_exp T_LT arith_exp
         | bool_term T_And bool_term
         | arith_exp T_GT arith_exp
         | arith_exp T_LTE arith_exp
         | arith_exp T_GTE arith_exp
         | arith_exp T_In T_ID
         | bool_term
         ;
bool_term : bool_factor
          | arith_exp T_EQ arith_exp
          | T_True {insert_record("Constant", "True", @1.first_line);}
          | T_False {insert_record("Constant", "False", @1.first_line);}
          ;
bool_factor : T_Not bool_factor
            | T_OP bool_exp T_CP
            ; 
import_stmt : T_Import T_ID {insert_record("PackageName", $<text>2, @2.first_line);}
			; 
pass_stmt : T_Pass
		  ;
break_stmt : T_Break
		   ;
return_stmt : T_Return
			;

assign_stmt : T_ID T_EQL arith_exp {insert_record("Identifier", $<text>1, @1.first_line);}  
            | T_ID T_EQL bool_exp {insert_record("Identifier", $<text>1, @1.first_line);}    
            | T_ID T_EQL T_OB T_CB {insert_record("ListTypeID", $<text>1, @1.first_line);}
            ;
print_stmt : T_Print T_OP term T_CP
		   ;
		   

finalStatements : basic_stmt
                | cmpd_stmt 
                ;
cmpd_stmt : if_stmt
          | while_stmt
          ;
if_stmt : T_If bool_exp T_Cln start_suite 
        | T_If bool_exp T_Cln start_suite elif_stmts
        ;

elif_stmts : else_stmt
           | T_Elif bool_exp T_Cln start_suite elif_stmts
           ;

else_stmt : T_Else T_Cln start_suite
		  ;

while_stmt : T_While bool_exp T_Cln start_suite
		   ;

start_suite : basic_stmt | T_NL ID finalStatements suite
			;

suite : T_NL ND finalStatements suite | T_NL end_suite
	  ;
end_suite : DD finalStatements | DD |
          {reset_depth();};


%%
void yyerror(const char *msg)
{
	printf("Syntax Error at Line %d\n",  yylineno);
	printf("\nSyntax Error at Line %d, Column : %d\n",  yylineno, yylloc.last_column);
	exit(0);
}
int main()
{
	printf("python>\n");
	yyparse();
	return 0;
}












