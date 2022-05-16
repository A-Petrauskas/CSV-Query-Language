{ 
module Token where 
}

%wrapper "posn" 
$digit = 0-9     
$alpha = [a-zA-Z]    

tokens :-
$white+       ; 
  "--".*        ; 
  SELECT        { \p s -> TokenSelect p } 
  FROM          { \p s -> TokenFrom p }
  WHERE         { \p s -> TokenWhere p }
  "LEFT JOIN"   { \p s -> TokenLeftJoin p }
  ON            { \p s -> TokenOn p }
  JOIN          { \p s -> TokenJoin p }
  AS            { \p s -> TokenAs p }
  AND           { \p s -> TokenAnd p }
  COALESCE      { \p s -> TokenCoalesce p }
  $digit+       { \p s -> TokenInt p (read s) }
  null          { \p s -> TokenNull p }
  \*            { \p s -> TokenAsterisk p }
  \[            { \p s -> TokenLBrack p }
  \]            { \p s -> TokenRBrack p }
  \=            { \p s -> TokenEq p }
  \:            { \p s -> TokenColon p }
  ","           { \p s -> TokenComma p }
  "!="          { \p s -> TokenNotEqual p }
  \(            { \p s -> TokenLParen p }
  \)            { \p s -> TokenRParen p }
  \"            { \p s -> TokenSpeechMark p }
  $alpha [$alpha $digit \_ \']*   { \p s -> TokenVar p s }
  $digit [$alpha $digit \_ \']*   { \p s -> TokenVar p s }

{ 
data Token = 
  TokenSelect     AlexPosn |
  TokenFrom       AlexPosn |
  TokenWhere      AlexPosn |
  TokenLeftJoin   AlexPosn |
  TokenOn         AlexPosn |  
  TokenJoin       AlexPosn |
  TokenAs         AlexPosn |
  TokenAnd        AlexPosn |
  TokenCoalesce   AlexPosn |
  TokenInt   AlexPosn  Int |
  TokenNull       AlexPosn |
  TokenAsterisk   AlexPosn |
  TokenLBrack     AlexPosn |
  TokenRBrack     AlexPosn | 
  TokenEq         AlexPosn |
  TokenColon      AlexPosn |
  TokenComma      AlexPosn |
  TokenNotEqual   AlexPosn |
  TokenLParen     AlexPosn |
  TokenRParen     AlexPosn |
  TokenSpeechMark AlexPosn |
  TokenVar AlexPosn String

  deriving (Eq,Show) 

tokenPosn :: Token -> String
tokenPosn (TokenSelect (AlexPn _ l c)) = show(l) ++ ":" ++ show(c)
tokenPosn (TokenFrom (AlexPn _ l c)) = show(l) ++ ":" ++ show(c)
tokenPosn (TokenWhere (AlexPn _ l c)) = show(l) ++ ":" ++ show(c)
tokenPosn (TokenLeftJoin (AlexPn _ l c)) = show(l) ++ ":" ++ show(c)
tokenPosn (TokenOn (AlexPn _ l c)) = show(l) ++ ":" ++ show(c)
tokenPosn (TokenJoin (AlexPn _ l c)) = show(l) ++ ":" ++ show(c)
tokenPosn (TokenAs (AlexPn _ l c)) = show(l) ++ ":" ++ show(c)
tokenPosn (TokenAnd (AlexPn _ l c)) = show(l) ++ ":" ++ show(c)
tokenPosn (TokenCoalesce (AlexPn _ l c)) = show(l) ++ ":" ++ show(c)
tokenPosn (TokenInt (AlexPn _ l c) _) = show(l) ++ ":" ++ show(c)
tokenPosn (TokenNull (AlexPn _ l c)) = show(l) ++ ":" ++ show(c)
tokenPosn (TokenAsterisk (AlexPn _ l c)) = show(l) ++ ":" ++ show(c)
tokenPosn (TokenLBrack (AlexPn _ l c)) = show(l) ++ ":" ++ show(c)
tokenPosn (TokenRBrack (AlexPn _ l c)) = show(l) ++ ":" ++ show(c)
tokenPosn (TokenEq (AlexPn _ l c)) = show(l) ++ ":" ++ show(c)
tokenPosn (TokenColon (AlexPn _ l c)) = show(l) ++ ":" ++ show(c)
tokenPosn (TokenComma (AlexPn _ l c)) = show(l) ++ ":" ++ show(c)
tokenPosn (TokenNotEqual (AlexPn _ l c)) = show(l) ++ ":" ++ show(c)
tokenPosn (TokenLParen (AlexPn _ l c)) = show(l) ++ ":" ++ show(c)
tokenPosn (TokenRParen (AlexPn _ l c)) = show(l) ++ ":" ++ show(c)
tokenPosn (TokenSpeechMark  (AlexPn _ l c)) = show(l) ++ ":" ++ show(c)
tokenPosn (TokenVar (AlexPn _ l c) _) = show(l) ++ ":" ++ show(c)

}