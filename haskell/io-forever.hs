import Control.Monad
import Data.Char
import System.IO

main = do
    c <- getContents
    when ((not . null) c) (putStrLn $ concat [(map toUpper c), " WHY WOULD YOU TYPE THIS"])
    putStrLn "Write something"
    hFlush stdout
    forever $ do 
        l <- getLine
        putStrLn $ (++) "this is stupid ->" $ concat ["<<<", map toUpper l, ">>>"]
