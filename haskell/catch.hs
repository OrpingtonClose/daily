import System.Environment
import System.IO
import System.IO.Error

main = toTry `catch` handler

toTry :: IO ()
toTry = do (fileName:_) <- getArgs
           contents <- readFile fileName
           putStrLn $ "The File has " ++ show (length (lines contents)) ++ "lines!"

handler :: IOError -> IO ()
handler e --https://downloads.haskell.org/~ghc/6.10.1/docs/html/libraries/base/System-IO-Error.html#3
    | isDoesNotExistError e = case ioeGetFileName e of Just path -> putStrLn "The file doesn't exist at " ++ path
                                                       Nothing -> putStrLn "The file doesn't existat an unknown location!"
    | otherwise = ioError e
