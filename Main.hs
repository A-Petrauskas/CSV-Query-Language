import Token
import Grammar
import Evaluator
import System.Environment
import Control.Exception
import System.IO

main :: IO ()
main = catch main' noParse

main' = do
  (fileName : _) <- getArgs
  sourceText <- readFile fileName
  let parsedProg = parse (alexScanTokens sourceText)
  interpreted <- evalStatement parsedProg
  if null interpreted
    then putStrLn ""
    else putStr ""

noParse :: ErrorCall -> IO ()
noParse e = do
  let err = show e
  hPutStr stderr err