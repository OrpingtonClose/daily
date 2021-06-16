{-# LANGUAGE OverloadedStrings, TypeSynonymInstances, FlexibleInstances #-}
module Lib
    ( someFunc
    ) where

import Data.Text (Text)

class DoSomething a where
    something :: a -> IO ()

instance DoSomething String where
    something _ = putStrLn "String"

instance DoSomething Text where
    something _ = putStrLn "Text"

someFunc :: IO ()
someFunc = do 
    something ("hello" :: Text)
    something ("hello" :: String)
