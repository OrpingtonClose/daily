import Data.Char

main = do
    contents <- getContents
    putStr $ map (\(c,h) -> if h == 1 then toUpper c else toLower c) $ zip contents [ mod e 2 | e <- [0..(length contents - 1)]]
