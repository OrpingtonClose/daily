import Data.Char

main = do
    things <- getContents
    putStr $ concat [replicate 10 "=", things, "<<<<<pure Retardation"]