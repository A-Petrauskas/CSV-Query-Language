module CsvReader where

readCsv :: String -> Int -> IO [[String]]
readCsv name arity = do
  contents <- readFile name
  let result = getRows (map removeSpaces (lines contents)) arity
  return result

removeSpaces :: String -> String
removeSpaces [] = []
removeSpaces (x : xs)
  | x == ' ' = removeSpaces xs
  | otherwise = x : removeSpaces xs

getSingleValue :: String -> String
getSingleValue [] = []
getSingleValue (x : xs)
  | x == ',' = []
  | otherwise = x : getSingleValue xs

getSingleRow :: String -> [String]
getSingleRow [] = []
getSingleRow x = take size x : getSingleRow (drop (size + 1) x)
  where
    size = length $ getSingleValue x

getRows :: [String] -> Int -> [[String]]
getRows [] _ = []
getRows (x : xs) arity =
  if (length aRow == arity)
    then aRow : getRows xs arity
    else (aRow ++ [""]) : getRows xs arity
  where
    aRow = getSingleRow x