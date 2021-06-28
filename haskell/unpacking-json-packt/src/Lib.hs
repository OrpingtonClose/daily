{-# LANGUAGE OverloadedStrings #-}

module Lib
    ( someFunc
    ) where

import Data.Aeson
import Control.Applicative
import qualified Data.ByteString.Lazy as B

data Mathematician = Mathematician 
                     { name :: String --B.ByteString
                     , nationality :: String --B.ByteString
                     , born :: Int
                     , died :: Maybe Int
                     } 

instance FromJSON Mathematician where
    parseJSON (Object v) = Mathematician
                           <$> (v .: "name")
                           <*> (v .: "nationality")
                           <*> (v .: "born")
                           <*> (v .:? "died")

greet m = (show.name) m ++ " was born in the year " ++ (show.born) m

someFunc :: IO ()
someFunc = do
    input <- B.readFile "input.json"
    let mm = decode input :: Maybe Mathematician
    case mm of 
        Nothing -> print "error parsing JSON"
        Just m -> (putStrLn.greet) m