module Lib
    ( someFunc
    ) where

someFunc :: IO ()
someFunc = do
    input <- readFile "input.txt"
    let l = lines input
    let w = map words l
    let m = map length w
    print m

