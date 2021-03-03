python.out : lex.yy.c y.tab.c y.tab.h 
	gcc lex.yy.c y.tab.c -ll -o python.out

lex.yy.c : lexer_python.l
	lex lexer_python.l

y.tab.c : parser_python.y
	yacc -d parser_python.y

clean :
	rm lex.yy.c y.tab.c y.tab.h python.out
