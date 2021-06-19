module Lib
    ( someFunc
    ) where

import System.Environment (getArgs)
import Data.Char

isNum s = foldl (&&) True arg where
    arg = map isDigit s

someFunc :: IO ()
someFunc = do
    args <- getArgs
    print args
    let numbers = filter isNum args
    print $ sum $ map (read::String->Int) numbers where
    