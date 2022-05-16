module Evaluator where
import Grammar
import CsvReader
import Data.Maybe

import Data.List

type DataBase = [[[String]]]
type TablePos = (String , Int)

isRepeat :: Ord a => [a] -> Bool
isRepeat = any ((>1) . length) . group . sort

left :: [[[String]]] -> [[[String]]] -> Int -> [[[String]]] -> Column -> Column -> [TablePos]-> [TablePos] -> [[[String]]] -- MAKE SURE IT DOESNT MERGE ON NULL
left a b index holder (ExpColumnRaw tableNameA columnNumA) (ExpColumnRaw tableNameB columnNumB) posLeft posRight  = do

    let match1 = findTableIndex posLeft tableNameA
    let match2 = findTableIndex posRight tableNameB

    if index == length a 
        then
            holder
        else do  
            let b_replicates = [ [[]] ++ (replicate (length x) "") | x <- b!!0]
            let matches = [ a!!index ++ y | y <- b, a!!index!!match1!!(columnNumA - 1) == y!!match2!!(columnNumB - 1), null (y!!match2!!(columnNumB - 1)) /= True]
            let updated = if null matches then holder ++ [(a!!index ++ b_replicates)] else holder ++ matches
            left a b (index+1) updated (ExpColumnRaw tableNameA columnNumA) (ExpColumnRaw tableNameB columnNumB) posLeft posRight


evalStatement :: Exp -> IO [()]
evalStatement (ExpQueryfull columns files predicates)   = do 
                                                            db  <- (evalFiles files)

                                                            let tableIndex = getTableIndexes files []

                                                            let preds = evalPredicate predicates db tableIndex
                                                            
                                                            let cols  = evalColumnList columns preds tableIndex

                                                            let intercalated = map (intercalate ",") cols

                                                            if isRepeat (map fst tableIndex) then error ("Duplicate Tables Found") else (mapM putStrLn intercalated)
                
evalStatement (ExpQueryNoWhere columns files ) = do 
                                                    db  <- (evalFiles files)

                                                    let tableIndex = getTableIndexes files []


                                                    let cols  = evalColumnList columns db tableIndex

                                                    let intercalated = map (intercalate ",") cols

                                                    if isRepeat (map fst tableIndex) then error ("Duplicate Tables Found") else (mapM putStrLn intercalated)

getTableIndexes :: FileList -> [TablePos] -> [TablePos]
getTableIndexes (ExpFileNamed name arity chosenName) pos     = [(toAdd )]
                                                where
                                                        toAdd = (chosenName , (arity))
getTableIndexes (ExpFile name arity ) pos     = [(toAdd )]
                                                where
                                                        toAdd = (name , (arity))
                                                                        
getTableIndexes (ExpFilesLeft fileListA fileListB _ _) pos    = (a ++ b)
                                                        where 
                                                                a =  getTableIndexes fileListA pos
                                                                b =  getTableIndexes fileListB a
getTableIndexes (ExpFiles fileListA fileListB) pos    = (a ++ b)
                                                        where 
                                                                a =  getTableIndexes fileListA pos
                                                                b =  getTableIndexes fileListB a

evalFiles :: FileList  -> IO DataBase
evalFiles (ExpFileNamed name arity chosenName)   = do 
                                                xs <- readCsv (name ++ ".csv") arity 
                                                let x = [ []++[x]  | x <- xs ]
                                                return x
evalFiles (ExpFile name arity )   = do 
                                                xs <- readCsv (name ++ ".csv") arity 
                                                let x = [ []++[x]  | x <- xs ]
                                                return x
evalFiles (ExpFilesLeft fileListA fileListB columnNumA columnNumB)  = do
                                                a <-  evalFiles fileListA 
                                                b <-  evalFiles fileListB 
                                                let posLeft = getTableIndexes fileListA []
                                                let posRight = getTableIndexes fileListB []
                                                let lefted = left (a) (b) 0 [] columnNumA columnNumB posLeft posRight
                                                return lefted

evalFiles (ExpFiles fileListA fileListB)    = do 
                                                a <-  evalFiles fileListA
                                                b <-  evalFiles fileListB
                                                let x = [x ++ y | x <- a, y <- b]
                                                return (x)
                                            
-- WHERE SECTION -----------------------------------------------------------------------------

evalPredicate :: PredicateList -> DataBase -> [TablePos] -> DataBase
evalPredicate (ExpEqualValue (ExpColumnRaw name columnNum) value) db  pos   =   filter (\x -> (findColumn pos x name (columnNum )) == value) db
evalPredicate (ExpEqualInt (ExpColumnRaw name columnNum) int) db  pos   =   filter (\x -> (findColumn pos x name (columnNum )) == (show int)) db

evalPredicate (ExpColumnNotNull (ExpColumnRaw name columnNum)) db  pos      =   filter (\x -> null (findColumn pos x name (columnNum )) == False) db
evalPredicate (ExpColumnNull (ExpColumnRaw name columnNum)) db  pos      =   filter (\x -> null (findColumn pos x name (columnNum )) == True) db


evalPredicate (ExpPredicateList predicateListA predicateListB) db pos       =   evalPredicate predicateListB updatedTable pos
                                                                                    where
                                                                                        updatedTable = evalPredicate predicateListA db pos


evalPredicate (ExpNotEqualColumn (ExpColumnRaw nameA columnNumA) (ExpColumnRaw nameB columnNumB)) db pos = filter (\x -> findColumn pos x nameB (columnNumB) /= findColumn pos x nameA (columnNumA)) db
evalPredicate (ExpEqualColumn (ExpColumnRaw nameA columnNumA) (ExpColumnRaw nameB columnNumB)) db  pos  = filter    (\x -> (findColumn pos x nameB (columnNumB )) == (findColumn pos x nameA (columnNumA ))) db
                                                                                                            
findTableIndex2 :: [TablePos] -> String -> Int
findTableIndex2 pos desired = snd (head (filter (\x -> (fst x) == desired) pos))


findTableIndex :: [TablePos] -> String ->  Int
findTableIndex pos desired =  fromJust (findIndex (\x -> (fst x) == desired) pos)



-- SELECT SECTION ------------------------------------------------------------------------------------

evalColumnList :: ColumnList -> DataBase -> [TablePos] -> [[String]]

evalColumnList (ExpAll) db pos =  sort (map concat db)  -- PUT SORT HERE 

evalColumnList (ExpColumnList columns) db pos = sort (transpose (evalColumns columns db pos)) -- PUT SORT HERE

evalColumns :: Columns -> DataBase -> [TablePos] -> [[String]]
evalColumns (ExpSingleColumn (ExpColumnRaw tablename columnNum)) db pos  =  [((map (\x -> (findColumn pos x tablename (columnNum ))) db) )]  -- may be broken

evalColumns (ExpTextCol text) db pos  = [((replicate (length db) text) )]
evalColumns (ExpIntCol int) db pos  = [replicate (length db) (show int)]


evalColumns (ExpCoalesce (ExpColumnRaw tablename columnNum) (ExpColumnRaw tablenameB columnNumB)) db pos  = [(map (\x -> compareTwo x) zipped)]
    where
        a = (map (\x -> (findColumn pos x tablename (columnNum ))) db)
        b = (map (\x -> (findColumn pos x tablenameB (columnNumB ))) db)
        zipped = zip a b

evalColumns (ExpMultipleColumns columnsA columnsB) db pos  = (evalColumns columnsA db pos ) ++ (evalColumns columnsB db pos )
                                                        
compareTwo :: (String, String) -> String
compareTwo (x , y) 
    | x == "" = y
    | otherwise = x
    

findColumn :: [TablePos] -> [[String]] -> String -> Int -> String
findColumn tables row tableName columnNum 
        | null (filter (\x -> (fst x) == tableName) tables) = error ("Runtime Error: " ++ tableName ++ " Table Not recognised.")
        | null (filter (\x -> ( snd x) >= (columnNum - 1)) (filter (\x -> (fst x) == tableName) tables)) == True = error ("Runtime Error: " ++ (show columnNum) ++ " Column not found.")  -- -1 to column should be here
        | otherwise = row!!(findTableIndex tables tableName)!!(columnNum - 1)

                                                                                    
