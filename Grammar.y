{
module Grammar where
import Token
}

%name parse
%tokentype { Token }
%error { parseError }
%token
  





  SELECT        { TokenSelect _ } 
  FROM          { TokenFrom _ }
  WHERE         { TokenWhere _ }
  LEFT          { TokenLeftJoin _ }
  ON            { TokenOn _ }
  JOIN          { TokenJoin _ }
  AS            { TokenAs _ }
  AND           { TokenAnd _ }
  COALESCE      { TokenCoalesce _ }
  int           { TokenInt _ $$ }
  null          { TokenNull _ }
  '*'           { TokenAsterisk _ }
  '['           { TokenLBrack _ }
  ']'           { TokenRBrack _ }
  '='           { TokenEq _ }
  ':'           { TokenColon _ }
  ','           { TokenComma _ }
  '!'          { TokenNotEqual _ }
  '('           { TokenLParen _ }
  ')'           { TokenRParen _ }
  '\"'           { TokenSpeechMark _}
  var           { TokenVar _ $$ } 

%left AND
%right LEFT
%right JOIN
%left ','
%%


Exp : SELECT  ColumnList  FROM  FileList  WHERE  PredicateList  { ExpQueryfull $2 $4 $6 }
    | SELECT  ColumnList  FROM  FileList                        { ExpQueryNoWhere $2 $4 }
					
ColumnList	:	'*'                     {ExpAll  }
            | Columns                 { ExpColumnList $1 }

Columns :	Column                                { ExpSingleColumn $1 }
        |	COALESCE '(' Column ',' Column ')'    { ExpCoalesce $3 $5}
        | '\"' var '\"'                           { ExpTextCol $2 }
        | '\"' int '\"'                           { ExpIntCol $2 }
        | Columns ',' Columns                   { ExpMultipleColumns $1 $3 }
                    
Column : var '[' int ']'                        { ExpColumnRaw $1 $3}        		

FileList  : '(' var  ':' int ')' AS var                             { ExpFileNamed $2 $4 $7}
          | '(' var  ':' int ')'                                    { ExpFile $2 $4}
          | FileList LEFT FileList ON Column '=' Column             { ExpFilesLeft $1 $3 $5 $7}
          | FileList JOIN FileList                                  { ExpFiles $1 $3}

PredicateList :	Column '=' Column                   { ExpEqualColumn $1 $3}
              |	Column '!' Column                    { ExpNotEqualColumn $1 $3}
              | Column '=' '\"' var '\"'              { ExpEqualValue $1 $4}
              | Column '=' '\"' int '\"'              { ExpEqualInt $1 $4}
              |	Column '!' null                    { ExpColumnNotNull $1}
              |	Column '=' null                     { ExpColumnNull $1}
              | PredicateList AND PredicateList     { ExpPredicateList $1 $3}
                  











{

parseError :: [Token] -> a
parseError [] = error "Unknown Parse Error" 
parseError (t:ts) = error ("Parse error at line:column " ++ (tokenPosn t))



data Exp  = ExpQueryfull ColumnList FileList PredicateList 
          | ExpQueryNoWhere ColumnList FileList
          

          deriving (Show,Eq)
         
data ColumnList = ExpAll
                | ExpColumnList Columns

                deriving (Show,Eq)

data Columns  = ExpSingleColumn Column 
              | ExpTextCol String
              | ExpIntCol Int
              | ExpCoalesce Column Column 
              | ExpMultipleColumns Columns Columns
        
              deriving (Show,Eq)

data Column = ExpColumnRaw String Int 
              
              deriving (Show,Eq)

data FileList   = ExpFile String Int
                | ExpFileNamed String Int String
                | ExpFilesLeft FileList FileList Column Column
                | ExpFiles FileList FileList

                deriving (Show,Eq)

data PredicateList  = ExpEqualColumn Column Column
                    | ExpNotEqualColumn Column Column
                    | ExpEqualValue Column String
                    | ExpEqualInt Column Int
                    |	ExpColumnNull Column
                    |	ExpColumnNotNull Column
                    | ExpPredicateList PredicateList PredicateList
              
                    deriving (Show,Eq)







}