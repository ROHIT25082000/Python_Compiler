%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include <stdarg.h>
	
	extern int yylineno;
	extern int depth;
	extern int top();
	extern int pop();
	int current_scope = 1; 
	int previous_scope = 1;
	
	int *array_of_scope = NULL;
	
	struct table_record
	{
		char *type;
		char *name;
		int lineDeclared;
		int lastUsedLine;
	}; 
	typedef struct table_record table_record;
 
	struct Symbol_Table
	{
		int num;
		int number_of_elements;
		int element_scope;
		table_record *arr_elements;
		int Parent;
		
	};
	typedef struct Symbol_Table Symbol_Table;
	
	struct AbstractSyntaxTreeNode
	{
		int node_num;
    	char *node_type;
    	int num_ops;
    	struct AbstractSyntaxTreeNode ** NextLevel;
    	table_record *id;
	
	};
	typedef struct AbstractSyntaxTreeNode node; 
	
  
	struct Quad
	{
		char *R;
		char *A1;
		char *A2;
		char *Op;
		int I;
	};
	typedef struct Quad Quad; 
	
	
	
	
	
	Symbol_Table *symtab= NULL;
	int sIndex = -1; 
	int aIndex = -1; 
	int tabCount = 0;
	int  tIndex = 0; 
	int lIndex = 0; 
	int qIndex = 0;
	int nodeCount = 0;
	
	node *rootNode;
	char *argsList = NULL;
	char *tString = NULL, *lString = NULL;
	Quad *allQ = NULL;
	node ***Tree = NULL;
	int *levelIndices = NULL;
	
	/*-----------------------------Declarations----------------------------------*/
	
	table_record* findRecord(const char *name, const char *type, int scope);
  	node *createID_Const(char *value, char *type, int scope);
    int power(int base, int exp);
  	void updateCScope(int scope);
  	void resetDepth();
	int scopeBasedTableSearch(int scope);
	void initNewTable(int scope);
	void init();
	int searchRecordInScope(const char* type, const char *name, int index);
	void insertRecord(const char* type, const char *name, int lineNo, int scope);
	int searchRecordInScope(const char* type, const char *name, int index);
	void checkList(const char *name, int lineNo, int scope);
	void printSTable();
	void freeAll();
	void addToList(char *newVal, int flag);
	void clearArgsList();
	int checkIfBinOperator(char *Op);
	/*------------------------------------------------------------------------------*/
	
	void Xitoa(int num, char *str)
	{
		if(str == NULL)
		{
			 printf("Allocate Memory\n");
		   return;
		}
		sprintf(str, "%d", num);
	}

	
	char *makeStr(int number, int flag)
	{
		char A[10];
		Xitoa(number, A);
		
		if(flag==1)
		{
				strcpy(tString, "T");
				strcat(tString, A);
				insertRecord("ICGTempVar", tString, -1, 0);
				return tString;
		}
		else
		{
				strcpy(lString, "L");
				strcat(lString, A);
				insertRecord("ICGTempLabel", lString, -1, 0);
				return lString;
		}

	}
	
	void makeQ(char *R, char *A1, char *A2, char *Op)
	{
		
		allQ[qIndex].R = (char*)malloc(strlen(R)+1);
		allQ[qIndex].Op = (char*)malloc(strlen(Op)+1);
		allQ[qIndex].A1 = (char*)malloc(strlen(A1)+1);
		allQ[qIndex].A2 = (char*)malloc(strlen(A2)+1);
		
		strcpy(allQ[qIndex].R, R);
		strcpy(allQ[qIndex].A1, A1);
		strcpy(allQ[qIndex].A2, A2);
		strcpy(allQ[qIndex].Op, Op);
		allQ[qIndex].I = qIndex;
 
		qIndex++;
		
		return;
	}
	
	int checkIfBinOperator(char *Op)
	{
		if((!strcmp(Op, "+")) || (!strcmp(Op, "*")) || (!strcmp(Op, "/")) || (!strcmp(Op, ">=")) || (!strcmp(Op, "<=")) || (!strcmp(Op, "<")) || (!strcmp(Op, ">")) || 
			 (!strcmp(Op, "in")) || (!strcmp(Op, "==")) || (!strcmp(Op, "and")) || (!strcmp(Op, "or")))
			{
				return 1;
			}
			
			else 
			{
				return 0;
			}
	}
	
	void codeGenOp(node *opNode)
	{
		if(opNode == NULL)
		{
			return;
		}
		
		if(opNode->node_type == NULL)
		{
			if((!strcmp(opNode->id->type, "Identifier")) || (!strcmp(opNode->id->type, "Constant")))
			{
				printf("T%d = %s\n", opNode->node_num, opNode->id->name);
				makeQ(makeStr(opNode->node_num, 1), opNode->id->name, "-", "=");
			}
			return;
		}
		
		if((!strcmp(opNode->node_type, "If")) || (!strcmp(opNode->node_type, "Elif")))
		{			
			switch(opNode->num_ops)
			{
				case 2 : 
				{
					int temp = lIndex;
					codeGenOp(opNode->NextLevel[0]);
					printf("If False T%d goto L%d\n", opNode->NextLevel[0]->node_num, lIndex);
					makeQ(makeStr(temp, 0), makeStr(opNode->NextLevel[0]->node_num, 1), "-", "If False");
					lIndex++;
					codeGenOp(opNode->NextLevel[1]);
					lIndex--;
					printf("L%d: ", temp);
					makeQ(makeStr(temp, 0), "-", "-", "Label");
					break;
				}
				case 3 : 
				{
					int temp = lIndex;
					codeGenOp(opNode->NextLevel[0]);
					printf("If False T%d goto L%d\n", opNode->NextLevel[0]->node_num, lIndex);
					makeQ(makeStr(temp, 0), makeStr(opNode->NextLevel[0]->node_num, 1), "-", "If False");					
					codeGenOp(opNode->NextLevel[1]);
					printf("goto L%d\n", temp+1);
					makeQ(makeStr(temp+1, 0), "-", "-", "goto");
					printf("L%d: ", temp);
					makeQ(makeStr(temp, 0), "-", "-", "Label");
					codeGenOp(opNode->NextLevel[2]);
					printf("L%d: ", temp+1);
					makeQ(makeStr(temp+1, 0), "-", "-", "Label");
					lIndex+=2;
					break;
				}
			}
			return;
		}
		
		if(!strcmp(opNode->node_type, "Else"))
		{
			codeGenOp(opNode->NextLevel[0]);
			return;
		}
		
		if(!strcmp(opNode->node_type, "While"))
		{
			int temp = lIndex;
			codeGenOp(opNode->NextLevel[0]);
			printf("L%d: If False T%d goto L%d\n", lIndex, opNode->NextLevel[0]->node_num, lIndex+1);
			makeQ(makeStr(temp, 0), "-", "-", "Label");		
			makeQ(makeStr(temp+1, 0), makeStr(opNode->NextLevel[0]->node_num, 1), "-", "If False");								
			lIndex+=2;			
			codeGenOp(opNode->NextLevel[1]);
			printf("goto L%d\n", temp);
			makeQ(makeStr(temp, 0), "-", "-", "goto");
			printf("L%d: ", temp+1);
			makeQ(makeStr(temp+1, 0), "-", "-", "Label"); 
			lIndex = lIndex+2;
			return;
		}
		
		if(!strcmp(opNode->node_type, "Next"))
		{
			codeGenOp(opNode->NextLevel[0]);
			codeGenOp(opNode->NextLevel[1]);
			return;
		}
		
		if(!strcmp(opNode->node_type, "BeginBlock"))
		{
			codeGenOp(opNode->NextLevel[0]);
			codeGenOp(opNode->NextLevel[1]);		
			return;	
		}
		
		if(!strcmp(opNode->node_type, "EndBlock"))
		{
			switch(opNode->num_ops)
			{
				case 0 : 
				{
					break;
				}
				case 1 : 
				{
					codeGenOp(opNode->NextLevel[0]);
					break;
				}
			}
			return;
		}
		
		if(!strcmp(opNode->node_type, "ListIndex"))
		{
			printf("T%d = %s[%s]\n", opNode->node_num, opNode->NextLevel[0]->id->name, opNode->NextLevel[1]->id->name);
			makeQ(makeStr(opNode->node_num, 1), opNode->NextLevel[0]->id->name, opNode->NextLevel[1]->id->name, "=[]");
			return;
		}
		
		if(checkIfBinOperator(opNode->node_type)==1)
		{
			codeGenOp(opNode->NextLevel[0]);
			codeGenOp(opNode->NextLevel[1]);
			char *X1 = (char*)malloc(10);
			char *X2 = (char*)malloc(10);
			char *X3 = (char*)malloc(10);
			
			strcpy(X1, makeStr(opNode->node_num, 1));
			strcpy(X2, makeStr(opNode->NextLevel[0]->node_num, 1));
			strcpy(X3, makeStr(opNode->NextLevel[1]->node_num, 1));

			printf("T%d = T%d %s T%d\n", opNode->node_num, opNode->NextLevel[0]->node_num, opNode->node_type, opNode->NextLevel[1]->node_num);
			makeQ(X1, X2, X3, opNode->node_type);
			free(X1);
			free(X2);
			free(X3);
			return;
		}
		
		if(!strcmp(opNode->node_type, "-"))
		{
			if(opNode->num_ops == 1)
			{
				codeGenOp(opNode->NextLevel[0]);
				char *X1 = (char*)malloc(10);
				char *X2 = (char*)malloc(10);
				strcpy(X1, makeStr(opNode->node_num, 1));
				strcpy(X2, makeStr(opNode->NextLevel[0]->node_num, 1));
				printf("T%d = %s T%d\n", opNode->node_num, opNode->node_type, opNode->NextLevel[0]->node_num);
				makeQ(X1, X2, "-", opNode->node_type);	
			}
			
			else
			{
				codeGenOp(opNode->NextLevel[0]);
				codeGenOp(opNode->NextLevel[1]);
				char *X1 = (char*)malloc(10);
				char *X2 = (char*)malloc(10);
				char *X3 = (char*)malloc(10);
			
				strcpy(X1, makeStr(opNode->node_num, 1));
				strcpy(X2, makeStr(opNode->NextLevel[0]->node_num, 1));
				strcpy(X3, makeStr(opNode->NextLevel[1]->node_num, 1));

				printf("T%d = T%d %s T%d\n", opNode->node_num, opNode->NextLevel[0]->node_num, opNode->node_type, opNode->NextLevel[1]->node_num);
				makeQ(X1, X2, X3, opNode->node_type);
				free(X1);
				free(X2);
				free(X3);
				return;
			
			}
		}
		
		if(!strcmp(opNode->node_type, "import"))
		{
			printf("import %s\n", opNode->NextLevel[0]->id->name);
			makeQ("-", opNode->NextLevel[0]->id->name, "-", "import");
			return;
		}
		
		if(!strcmp(opNode->node_type, "NewLine"))
		{
			codeGenOp(opNode->NextLevel[0]);
			codeGenOp(opNode->NextLevel[1]);
			return;
		}
		
		if(!strcmp(opNode->node_type, "="))
		{
			codeGenOp(opNode->NextLevel[1]);
			printf("%s = T%d\n", opNode->NextLevel[0]->id->name, opNode->NextLevel[1]->node_num);
			makeQ(opNode->NextLevel[0]->id->name, makeStr(opNode->NextLevel[1]->node_num, 1), "-", opNode->node_type);
			return;
		}
		
		if(!strcmp(opNode->node_type, "Func_Name"))
		{
			printf("Begin Function %s\n", opNode->NextLevel[0]->id->name);
			makeQ("-", opNode->NextLevel[0]->id->name, "-", "BeginF");
			codeGenOp(opNode->NextLevel[2]);
			printf("End Function %s\n", opNode->NextLevel[0]->id->name);
			makeQ("-", opNode->NextLevel[0]->id->name, "-", "EndF");
			return;
		}
		
		if(!strcmp(opNode->node_type, "Func_Call"))
		{
			if(!strcmp(opNode->NextLevel[1]->node_type, "Void"))
			{
				printf("(T%d)Call Function %s\n", opNode->node_num, opNode->NextLevel[0]->id->name);
				makeQ(makeStr(opNode->node_num, 1), opNode->NextLevel[0]->id->name, "-", "Call");
			}
			else
			{
				char A[10];
				char* token = strtok(opNode->NextLevel[1]->node_type, ","); 
  			int i = 0;
				while (token != NULL) 
				{
						i++; 
				    printf("Push Param %s\n", token);
				    makeQ("-", token, "-", "Param"); 
				    token = strtok(NULL, ","); 
				}
				
				printf("(T%d)Call Function %s, %d\n", opNode->node_num, opNode->NextLevel[0]->id->name, i);
				sprintf(A, "%d", i);
				makeQ(makeStr(opNode->node_num, 1), opNode->NextLevel[0]->id->name, A, "Call");
				printf("Pop Params for Function %s, %d\n", opNode->NextLevel[0]->id->name, i);
								
				return;
			}
		}		
		
		if(!(strcmp(opNode->node_type, "Print")))
		{
			codeGenOp(opNode->NextLevel[0]);
			printf("Print T%d\n", opNode->NextLevel[0]->node_num);
			makeQ("-", makeStr(opNode->node_num, 1), "-", "Print");
		}
		if(opNode->num_ops == 0)
		{
			if(!strcmp(opNode->node_type, "break"))
			{
				printf("goto L%d\n", lIndex);
				makeQ(makeStr(lIndex, 0), "-", "-", "goto");
			}

			if(!strcmp(opNode->node_type, "pass"))
			{
				makeQ("-", "-", "-", "pass");
			}

			if(!strcmp(opNode->node_type, "return"))
			{
				printf("return\n");
				makeQ("-", "-", "-", "return");
			}
		}
		
		
	}
	
  node *createID_Const(char *type, char *value, int scope)
  {
    node *newNode;
    newNode = (node*)calloc(1, sizeof(node));
    newNode->node_type = NULL;
    newNode->num_ops = -1;
    newNode->id = findRecord(value, type, scope);
    newNode->node_num = nodeCount++;
    return newNode;
  }

  node *createOp(char *oper, int num_ops, ...)
  {
  
    va_list params;
    node *newNode;
    int i;
    newNode = (node*)calloc(1, sizeof(node));
    
    newNode->NextLevel = (node**)calloc(num_ops, sizeof(node*));
    
    newNode->node_type = (char*)malloc(strlen(oper)+1);
    strcpy(newNode->node_type, oper);
    newNode->num_ops = num_ops;
    va_start(params, num_ops);
    
    for (i = 0; i < num_ops; i++)
      newNode->NextLevel[i] = va_arg(params, node*);
    
    va_end(params);
    newNode->node_num = nodeCount++;
    return newNode;
  }
  
  void addToList(char *newVal, int flag)
  {
  	if(flag==0)
  	{
		  strcat(argsList, ", ");
		  strcat(argsList, newVal);
		}
		else
		{
			strcat(argsList, newVal);
		}
    //printf("\n\t%s\n", newVal);
  }
  
  void clearArgsList()
  {
    strcpy(argsList, "");
  }
  
	int power(int base, int exp)
	{
		int i =0, res = 1;
		for(i; i<exp; i++)
		{
			res *= base;
		}
		return res;
	}
	
	void updateCScope(int scope)
	{
		current_scope = scope;
	}
	
	void resetDepth()
	{
		while(top()) pop();
		depth = 10;
	}
	
	int scopeBasedTableSearch(int scope)
	{
		int i = sIndex;
		for(i; i > -1; i--)
		{
			if(symtab[i].element_scope == scope)
			{
				return i;
			}
		}
		return -1;
	}
	
	void initNewTable(int scope)
	{
		array_of_scope[scope]++;
		sIndex++;
		symtab[sIndex].num = sIndex;
		symtab[sIndex].element_scope = power(scope, array_of_scope[scope]);
		symtab[sIndex].number_of_elements = 0;		
		symtab[sIndex].arr_elements = (table_record*)malloc(200*sizeof(table_record));
		
		symtab[sIndex].Parent = scopeBasedTableSearch(current_scope); 
	}
	
	void init()
	{
		int i = 0;
		symtab = (Symbol_Table *)malloc(100* sizeof(Symbol_Table));
		array_of_scope = (int*)calloc(10, sizeof(int));
		initNewTable(1);
		argsList = (char *)malloc(100);
		strcpy(argsList, "");
		tString = (char*)calloc(10, sizeof(char));
		lString = (char*)calloc(10, sizeof(char));
		allQ = (Quad*)malloc(1000 * sizeof(Quad));
		
		levelIndices = (int*)malloc(20*sizeof(int));
		Tree = (node***)malloc(20*sizeof(node**));
		for(i = 0; i< 20 ; i++)
		{
			Tree[i] = (node**)malloc(100*sizeof(node*));
		}
	}

	int searchRecordInScope(const char* type, const char *name, int index)
	{
		int i =0;
		for(i=0; i<symtab[index].number_of_elements; i++)
		{
			if((strcmp(symtab[index].arr_elements[i].type, type)==0) && (strcmp(symtab[index].arr_elements[i].name, name)==0))
			{
				return i;
			}	
		}
		return -1;
	}
		
	void modifyRecordID(const char *type, const char *name, int lineNo, int scope)
	{
		int i =0;
		int index = scopeBasedTableSearch(scope);
		if(index==0)
		{
			for(i=0; i<symtab[index].number_of_elements; i++)
			{
				
				if(strcmp(symtab[index].arr_elements[i].type, type)==0 && (strcmp(symtab[index].arr_elements[i].name, name)==0))
				{
					symtab[index].arr_elements[i].lastUsedLine = lineNo;
					return;
				}	
			}
			printf("%s '%s' at line %d Not Declared\n", type, name, yylineno);
			exit(1);
		}
		
		for(i=0; i<symtab[index].number_of_elements; i++)
		{
			if(strcmp(symtab[index].arr_elements[i].type, type)==0 && (strcmp(symtab[index].arr_elements[i].name, name)==0))
			{
				symtab[index].arr_elements[i].lastUsedLine = lineNo;
				return;
			}	
		}
		return modifyRecordID(type, name, lineNo, symtab[symtab[index].Parent].element_scope);
	}
	
	void insertRecord(const char* type, const char *name, int lineNo, int scope)
	{ 
		int FScope = power(scope, array_of_scope[scope]);
		int index = scopeBasedTableSearch(FScope);
		int recordIndex = searchRecordInScope(type, name, index);
		if(recordIndex==-1)
		{
			
			symtab[index].arr_elements[symtab[index].number_of_elements].type = (char*)calloc(30, sizeof(char));
			symtab[index].arr_elements[symtab[index].number_of_elements].name = (char*)calloc(20, sizeof(char));
		
			strcpy(symtab[index].arr_elements[symtab[index].number_of_elements].type, type);	
			strcpy(symtab[index].arr_elements[symtab[index].number_of_elements].name, name);
			symtab[index].arr_elements[symtab[index].number_of_elements].lineDeclared = lineNo;
			symtab[index].arr_elements[symtab[index].number_of_elements].lastUsedLine = lineNo;
			symtab[index].number_of_elements++;

		}
		else
		{
			symtab[index].arr_elements[recordIndex].lastUsedLine = lineNo;
		}
	}
	
	void checkList(const char *name, int lineNo, int scope)
	{
		int index = scopeBasedTableSearch(scope);
		int i;
		if(index==0)
		{
			
			for(i=0; i<symtab[index].number_of_elements; i++)
			{
				
				if(strcmp(symtab[index].arr_elements[i].type, "ListTypeID")==0 && (strcmp(symtab[index].arr_elements[i].name, name)==0))
				{
					symtab[index].arr_elements[i].lastUsedLine = lineNo;
					return;
				}	

				else if(strcmp(symtab[index].arr_elements[i].name, name)==0)
				{
					printf("Identifier '%s' at line %d Not Indexable\n", name, yylineno);
					exit(1);

				}

			}
			printf("Identifier '%s' at line %d Not Indexable\n", name, yylineno);
			exit(1);
		}
		
		for(i=0; i<symtab[index].number_of_elements; i++)
		{
			if(strcmp(symtab[index].arr_elements[i].type, "ListTypeID")==0 && (strcmp(symtab[index].arr_elements[i].name, name)==0))
			{
				symtab[index].arr_elements[i].lastUsedLine = lineNo;
				return;
			}
			
			else if(strcmp(symtab[index].arr_elements[i].name, name)==0)
			{
				printf("Identifier '%s' at line %d Not Indexable\n", name, yylineno);
				exit(1);

			}
		}
		
		return checkList(name, lineNo, symtab[symtab[index].Parent].element_scope);

	}
	
	table_record* findRecord(const char *name, const char *type, int scope)
	{
		int i =0;
		int index = scopeBasedTableSearch(scope);
		//printf("FR: %d, %s\n", scope, name);
		if(index==0)
		{
			for(i=0; i<symtab[index].number_of_elements; i++)
			{
				
				if(strcmp(symtab[index].arr_elements[i].type, type)==0 && (strcmp(symtab[index].arr_elements[i].name, name)==0))
				{
					return &(symtab[index].arr_elements[i]);
				}	
			}
			printf("\n%s '%s' at line %d Not Found in Symbol Table\n", type, name, yylineno);
			exit(1);
		}
		
		for(i=0; i<symtab[index].number_of_elements; i++)
		{
			if(strcmp(symtab[index].arr_elements[i].type, type)==0 && (strcmp(symtab[index].arr_elements[i].name, name)==0))
			{
				return &(symtab[index].arr_elements[i]);
			}	
		}
		return findRecord(name, type, symtab[symtab[index].Parent].element_scope);
	}

	void printSTable()
	{
		int i = 0, j = 0;
		
		printf("\n----------------------------All Symbol Tables----------------------------");
		printf("\nScope\tName\tType\t\tDeclaration\tLast Used Line\n");
		for(i=0; i<=sIndex; i++)
		{
			for(j=0; j<symtab[i].number_of_elements; j++)
			{
				printf("(%d, %d)\t%s\t%s\t%d\t\t%d\n", symtab[i].Parent, symtab[i].element_scope, symtab[i].arr_elements[j].name, symtab[i].arr_elements[j].type, symtab[i].arr_elements[j].lineDeclared,  symtab[i].arr_elements[j].lastUsedLine);
			}
		}
		
		printf("-------------------------------------------------------------------------\n");
		
	}
	
	void ASTToArray(node *root, int level)
	{
	  if(root == NULL )
	  {
	    return;
	  }
	  
	  if(root->num_ops <= 0)
	  {
	  	Tree[level][levelIndices[level]] = root;
	  	levelIndices[level]++;
	  }
	  
	  if(root->num_ops > 0)
	  {
	 		int j;
	 		Tree[level][levelIndices[level]] = root;
	 		levelIndices[level]++; 
	    for(j=0; j<root->num_ops; j++)
	    {
	    	ASTToArray(root->NextLevel[j], level+1);
	    }
	  }
	}
	
	void printAST(node *root)
	{
		printf("\n-------------------------Abstract Syntax Tree--------------------------\n");
		ASTToArray(root, 0);
		int j = 0, p, q, maxLevel = 0, lCount = 0;
		
		while(levelIndices[maxLevel] > 0) maxLevel++;
		
		while(levelIndices[j] > 0)
		{
			for(q=0; q<lCount; q++)
			{
				printf(" ");
			
			}
			for(p=0; p<levelIndices[j] ; p++)
			{
				if(Tree[j][p]->num_ops == -1)
				{
					printf("%s  ", Tree[j][p]->id->name);
					lCount+=strlen(Tree[j][p]->id->name);
				}
				else if(Tree[j][p]->num_ops == 0)
				{
					printf("%s  ", Tree[j][p]->node_type);
					lCount+=strlen(Tree[j][p]->node_type);
				}
				else
				{
					printf("%s(%d) ", Tree[j][p]->node_type, Tree[j][p]->num_ops);
				}
			}
			j++;
			printf("\n");
		}
	}
	
	int IsValidNumber(char * string)
	{
   for(int i = 0; i < strlen( string ); i ++)
   {
      //ASCII value of 0 = 48, 9 = 57. So if value is outside of numeric range then fail
      //Checking for negative sign "-" could be added: ASCII value 45.
      if (string[i] < 48 || string[i] > 57)
         return 0;
   }
 
   return 1;
	}
	
	int deadCodeElimination()
	{
		int i = 0, j = 0, flag = 1, XF=0;
		while(flag==1)
		{
			
			flag=0;
			for(i=0; i<qIndex; i++)
			{
				XF=0;
				if(!((strcmp(allQ[i].R, "-")==0) | (strcmp(allQ[i].Op, "Call")==0) | (strcmp(allQ[i].Op, "Label")==0) | (strcmp(allQ[i].Op, "goto")==0) | (strcmp(allQ[i].Op, "If False")==0)))
				{
					for(j=0; j<qIndex; j++)
					{
							if(((strcmp(allQ[i].R, allQ[j].A1)==0) && (allQ[j].I!=-1)) | ((strcmp(allQ[i].R, allQ[j].A2)==0) && (allQ[j].I!=-1)))
							{
								XF=1;
							}
					}
				
					if((XF==0) & (allQ[i].I != -1))
					{
						allQ[i].I = -1;
						flag=1;
					}
				}
			}
		}
		return flag;
	}
	
	void printQuads()
	{
		printf("\n--------------------------------All Quads---------------------------------\n");
		int i = 0;
		for(i=0; i<qIndex; i++)
		{
			if(allQ[i].I > -1)
				printf("%d\t%s\t%s\t%s\t%s\n", allQ[i].I, allQ[i].Op, allQ[i].A1, allQ[i].A2, allQ[i].R);
		}
		printf("--------------------------------------------------------------------------\n");
	}
	
	void freeAll()
	{
		deadCodeElimination();
		printQuads();
		printf("\n");
		int i = 0, j = 0;
		for(i=0; i<=sIndex; i++)
		{
			for(j=0; j<symtab[i].number_of_elements; j++)
			{
				free(symtab[i].arr_elements[j].name);
				free(symtab[i].arr_elements[j].type);	
			}
			free(symtab[i].arr_elements);
		}
		free(symtab);
		free(allQ);
	}
%}

%union { char *text; int depth; struct AbstractSyntaxTreeNode * node;};
%locations
   	  
%token T_EndOfFile T_Return T_Number T_True T_False T_ID T_Print T_Cln T_NL T_EQL T_NEQ T_EQ T_GT T_LT T_EGT T_ELT T_Or T_And T_Not T_In ID ND DD T_String T_If T_Elif T_While T_Else T_Import T_Break T_Pass T_MN T_PL T_DV T_ML T_OP T_CP T_OB T_CB T_Def T_Comma T_List

%right T_EQL                                          
%left T_PL T_MN
%left T_ML T_DV
%nonassoc T_If
%nonassoc T_Elif
%nonassoc T_Else

%type<node> StartDebugger /*args*/ start_suite suite end_suite /*func_call call_args*/ StartParse finalStatements arith_exp bool_exp term constant basic_stmt cmpd_stmt /*func_def*/ list_index import_stmt pass_stmt break_stmt print_stmt if_stmt elif_stmts else_stmt while_stmt return_stmt assign_stmt bool_term bool_factor

%%

StartDebugger : {init();} StartParse T_EndOfFile {printf("\nValid Python Syntax\n");  printAST($2); codeGenOp($2); printQuads(); printSTable(); freeAll(); exit(0);} ;

constant : T_Number {insertRecord("Constant", $<text>1, @1.first_line, current_scope); $$ = createID_Const("Constant", $<text>1, current_scope);}
         | T_String {insertRecord("Constant", $<text>1, @1.first_line, current_scope); $$ = createID_Const("Constant", $<text>1, current_scope);};

term : T_ID {modifyRecordID("Identifier", $<text>1, @1.first_line, current_scope); $$ = createID_Const("Identifier", $<text>1, current_scope);} 
     | constant {$$ = $1;} 
     | list_index {$$ = $1;};


list_index : T_ID T_OB constant T_CB {checkList($<text>1, @1.first_line, current_scope); $$ = createOp("ListIndex", 2, createID_Const("ListTypeID", $<text>1, current_scope), $3);};

StartParse : T_NL StartParse {$$=$2;}| finalStatements T_NL {resetDepth();} StartParse {$$ = createOp("NewLine", 2, $1, $4);}| finalStatements T_NL {$$=$1;};

basic_stmt : pass_stmt {$$=$1;}
           | break_stmt {$$=$1;}
           | import_stmt {$$=$1;}
           | assign_stmt {$$=$1;}
           | arith_exp {$$=$1;}
           | bool_exp {$$=$1;}
           | print_stmt {$$=$1;}
           | return_stmt {$$=$1;};

arith_exp : term {$$=$1;}
          | arith_exp  T_PL  arith_exp {$$ = createOp("+", 2, $1, $3);}
          | arith_exp  T_MN  arith_exp {$$ = createOp("-", 2, $1, $3);}
          | arith_exp  T_ML  arith_exp {$$ = createOp("*", 2, $1, $3);}
          | arith_exp  T_DV  arith_exp {$$ = createOp("/", 2, $1, $3);}
          | T_MN arith_exp {$$ = createOp("-", 1, $2);}
          | T_OP arith_exp T_CP {$$ = $2;} ;
		    

bool_exp : bool_term T_Or bool_term {$$ = createOp("or", 2, $1, $3);}
         | arith_exp T_LT arith_exp {$$ = createOp("<", 2, $1, $3);}
         | bool_term T_And bool_term {$$ = createOp("and", 2, $1, $3);}
         | arith_exp T_GT arith_exp {$$ = createOp(">", 2, $1, $3);}
         | arith_exp T_ELT arith_exp {$$ = createOp("<=", 2, $1, $3);}
         | arith_exp T_EGT arith_exp {$$ = createOp(">=", 2, $1, $3);}
         | arith_exp T_In T_ID {checkList($<text>3, @3.first_line, current_scope); $$ = createOp("in", 2, $1, createID_Const("Constant", $<text>3, current_scope));}
         | bool_term {$$=$1;}; 

bool_term : bool_factor {$$ = $1;}
          | arith_exp T_EQ arith_exp {$$ = createOp("==", 2, $1, $3);}
          | T_True {insertRecord("Constant", "True", @1.first_line, current_scope); $$ = createID_Const("Constant", "True", current_scope);}
          | T_False {insertRecord("Constant", "False", @1.first_line, current_scope); $$ = createID_Const("Constant", "False", current_scope);}; 
          
bool_factor : T_Not bool_factor {$$ = createOp("!", 1, $2);}
            | T_OP bool_exp T_CP {$$ = $2;}; 

import_stmt : T_Import T_ID {insertRecord("PackageName", $<text>2, @2.first_line, current_scope); $$ = createOp("import", 1, createID_Const("PackageName", $<text>2, current_scope));};
pass_stmt : T_Pass {$$ = createOp("pass", 0);};
break_stmt : T_Break {$$ = createOp("break", 0);};
return_stmt : T_Return {$$ = createOp("return", 0);};;

assign_stmt : T_ID T_EQL arith_exp {insertRecord("Identifier", $<text>1, @1.first_line, current_scope); $$ = createOp("=", 2, createID_Const("Identifier", $<text>1, current_scope), $3);}  
            | T_ID T_EQL bool_exp {insertRecord("Identifier", $<text>1, @1.first_line, current_scope);$$ = createOp("=", 2, createID_Const("Identifier", $<text>1, current_scope), $3);}   
            //| T_ID  T_EQL func_call {insertRecord("Identifier", $<text>1, @1.first_line, current_scope); $$ = createOp("=", 2, createID_Const("Identifier", $<text>1, current_scope), $3);} 
            | T_ID T_EQL T_OB T_CB {insertRecord("ListTypeID", $<text>1, @1.first_line, current_scope); $$ = createID_Const("ListTypeID", $<text>1, current_scope);} ;
	      
print_stmt : T_Print T_OP term T_CP {$$ = createOp("Print", 1, $3);};

finalStatements : basic_stmt {$$ = $1;}
                | cmpd_stmt {$$ = $1;}//| func_def {$$ = $1;}
                //| func_call {$$ = $1;}
                | error T_NL {yyerrok; yyclearin; $$=createOp("SyntaxError", 0);};

cmpd_stmt : if_stmt {$$ = $1;}
          | while_stmt {$$ = $1;};


if_stmt : T_If bool_exp T_Cln start_suite {$$ = createOp("If", 2, $2, $4);}
        | T_If bool_exp T_Cln start_suite elif_stmts {$$ = createOp("If", 3, $2, $4, $5);};

elif_stmts : else_stmt {$$= $1;}
           | T_Elif bool_exp T_Cln start_suite elif_stmts {$$= createOp("Elif", 3, $2, $4, $5);};

else_stmt : T_Else T_Cln start_suite {$$ = createOp("Else", 1, $3);};

while_stmt : T_While bool_exp T_Cln start_suite {$$ = createOp("While", 2, $2, $4);}; 

start_suite : basic_stmt {$$ = $1;}
            | T_NL ID {initNewTable($<depth>2); updateCScope($<depth>2);} finalStatements suite {$$ = createOp("BeginBlock", 2, $4, $5);};

suite : T_NL ND finalStatements suite {$$ = createOp("Next", 2, $3, $4);}
      | T_NL end_suite {$$ = $2;};

end_suite : DD {updateCScope($<depth>1);} finalStatements {$$ = createOp("EndBlock", 1, $3);} 
          | DD {updateCScope($<depth>1);} {$$ = createOp("EndBlock", 0);}
          | {$$ = createOp("EndBlock", 0); resetDepth();};
 
%%

void yyerror(const char *msg)
{
	printf("\nSyntax Error at Line %d, Column : %d\n",  yylineno, yylloc.last_column);
	exit(0);
}

int main()
{
	printf("python>\n");
	yyparse();
	return 0;
}

