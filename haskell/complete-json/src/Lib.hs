{-# LANGUAGE OverloadedStrings #-}
--{-# LANGUAGE DeriveGeneric #-}

module Lib
    ( someFunc
    ) where

import Data.Aeson
import Data.Map
import Data.Text
import Data.Time.Clock
import Data.Maybe
import Control.Applicative

data Person = Person { name :: Text, age :: Int} deriving Show

instance FromJSON Person where 
    parseJSON = withObject "Person" $ \v -> Person
        <$> v .: "name"
        <*> v .: "age"
    -- toEncoding = genericToEncoding defaultOptions
    -- parseJSON (Object v) = Person <$> v .: "name" <*> v .: "age"
    -- parseJSON _ = Control.Applicative.empty

instance ToJSON Person where
    -- this generates a Value
    toJSON (Person name age) = object ["name" .= name, "age" .= age]
    -- this encodes directly to a bytestring Builder
    toEncoding (Person name age) = pairs ("name" .= name <> "age" .= age)
    -- toJson (Person name age) = object ["name" .= name, "age" .= age]

get a = Prelude.concat . maybeToList $ decode a
--https://stackoverflow.com/questions/8540999/extracting-a-maybe-value-in-io
Just onePerson = (decode "{ \"name\": \"Joe\", \"age\": 12 }" :: Maybe Person)

someFunc :: IO ()
someFunc = do
    putStrLn $ "Encode: " ++ (show (encode (Person { name = "Joe", age = 12 })))
    putStrLn $ "Decode: " ++ (show (decode "{ \"name\": \"Joe\", \"age\": 12 }" :: Maybe Person))
    putStrLn $ show onePerson
    --http://wiki.penson.io/languages/haskell.html
    --https://en.wikibooks.org/wiki/Haskell/More_on_datatypes
    --auto generated accessor functons
    putStrLn $ show $ name onePerson
    putStrLn $ show $ age onePerson     54
    -- print Just a <- (decode "{ \"name\": \"Joe\", \"age\": 12 }" :: Maybe Person) -- onePerson <- decode "{ \"name\": \"Joe\", \"age\": 12 }" :: Maybe Person
    --show $ get (decode "{ \"name\": \"Joe\", \"age\": 12 }" :: Maybe Person)
