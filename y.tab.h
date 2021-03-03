/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    T_Number = 258,
    T_EndOfFile = 259,
    T_Import = 260,
    T_Print = 261,
    T_Pass = 262,
    T_If = 263,
    T_In = 264,
    T_While = 265,
    T_Break = 266,
    T_And = 267,
    T_Or = 268,
    T_Not = 269,
    T_Elif = 270,
    T_Else = 271,
    T_Def = 272,
    T_Return = 273,
    T_Cln = 274,
    T_GT = 275,
    T_LT = 276,
    T_GTE = 277,
    T_LTE = 278,
    T_EQ = 279,
    T_NEQ = 280,
    T_True = 281,
    T_False = 282,
    T_PL = 283,
    T_MN = 284,
    T_ML = 285,
    T_DV = 286,
    T_OP = 287,
    T_CP = 288,
    T_OB = 289,
    T_CB = 290,
    T_Comma = 291,
    T_EQL = 292,
    T_ID = 293,
    T_String = 294,
    T_NL = 295,
    ID = 296,
    ND = 297,
    DD = 298
  };
#endif
/* Tokens.  */
#define T_Number 258
#define T_EndOfFile 259
#define T_Import 260
#define T_Print 261
#define T_Pass 262
#define T_If 263
#define T_In 264
#define T_While 265
#define T_Break 266
#define T_And 267
#define T_Or 268
#define T_Not 269
#define T_Elif 270
#define T_Else 271
#define T_Def 272
#define T_Return 273
#define T_Cln 274
#define T_GT 275
#define T_LT 276
#define T_GTE 277
#define T_LTE 278
#define T_EQ 279
#define T_NEQ 280
#define T_True 281
#define T_False 282
#define T_PL 283
#define T_MN 284
#define T_ML 285
#define T_DV 286
#define T_OP 287
#define T_CP 288
#define T_OB 289
#define T_CB 290
#define T_Comma 291
#define T_EQL 292
#define T_ID 293
#define T_String 294
#define T_NL 295
#define ID 296
#define ND 297
#define DD 298

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 84 "parser_python.y" /* yacc.c:1909  */

	char * text; 
	int depth; 

#line 145 "y.tab.h" /* yacc.c:1909  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif

/* Location type.  */
#if ! defined YYLTYPE && ! defined YYLTYPE_IS_DECLARED
typedef struct YYLTYPE YYLTYPE;
struct YYLTYPE
{
  int first_line;
  int first_column;
  int last_line;
  int last_column;
};
# define YYLTYPE_IS_DECLARED 1
# define YYLTYPE_IS_TRIVIAL 1
#endif


extern YYSTYPE yylval;
extern YYLTYPE yylloc;
int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
