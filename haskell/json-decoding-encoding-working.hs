-- {-# LANGUAGE DeriveGeneric #-}
-- {-# LANGUAGE OverloadedStrings #-}
-- import Data.Aeson
-- import Data.Text (Text)
-- import GHC.Generics
-- import Control.Applicative

-- data Person = Person { name :: Text, age :: Int } deriving (Generic, Show)

-- instance FromJSON Person
-- instance ToJSON Person where
--     toEncoding = genericToEncoding defaultOptions

-- testPerson :: IO ()
-- testPerson = do
--     let p = Person { name = "Joe", age = 12 }
--         ps = show $ encode p
--         pstr = "{ \"name\": \"Joe\", \"age\": 12 }"
--         dec = decode pstr :: Maybe Person
--     putStrLn $ "Encode: " ++ ps
--     putStrLn $ "Decode: " ++ show dec

-- data Person2 = Person2 { name2 :: Text, age2 :: Int } deriving (Show)
-- instance FromJSON Person2 where
--     parseJSON (Object v) = Person2 <$> v .: "name2" <*> v .: "age2"
--     parseJSON _ = empty 

-- instance ToJSON Person2 where
--     toJSON (Person2 name age) = object ["name2" .= name2, "age2" .= age2]


-- main :: IO ()
-- main = do
--     testPerson
--     putStrLn $ "Encode: " ++ (show (encode (Person2 { name2 = "Joe", age2 = 12 })))
--     putStrLn $ "Decode: " ++
--         (show (decode "{ \"name2\": \"Joe\", \"age2\": 12 }" :: Maybe Person2))    

{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DuplicateRecordFields #-}

import Control.Applicative
import Data.Aeson
import Data.Text (Text)

-- Same type as before, but without the Generic instance.
data Person = Person { name :: Text, age :: Int, dog:: Maybe Dog, children :: Maybe [Person] } deriving Show
data Dog = Dog { name :: Text, age :: Int } deriving Show

-- We expect a JSON object, so we fail at any non-Object value.
-- instance FromJSON Person where
--     parseJSON (Object v) = Person <$> v .: "name" <*> v .: "age"
--     parseJSON _ = empty

instance FromJSON Person where
    parseJSON (Object v) = do
        name <- v .: "name"
        age <- v .: "age"
        dog <- v .:? "dog"
        children <- v .:? "children"
        return $ case children of
            (Just []) -> Person { name = name, age = age, dog = dog, children = Nothing }
            (Just children) -> Person { name = name, age = age, dog = dog, children = Just children }
            Nothing -> Person { name = name, age = age, dog = dog, children = Nothing }
    parseJSON _ = empty

instance ToJSON Person where
    toJSON (Person name age dog children) = let r = ["name" .= name, "age" .= age]
                                            in object $ case dog of
                                                (Just dog) -> case children of 
                                                    (Just []) -> r ++ ["dog" .= dog]
                                                    (Just children) -> r ++ ["dog" .= dog, "children" .= children]
                                                    Nothing -> r ++ ["dog" .= dog]
                                                Nothing -> case children of 
                                                    (Just children) -> r ++ ["children" .= children]
                                                    Nothing -> r

instance FromJSON Dog where
    parseJSON (Object v) = do
        name <- v .: "name"
        age <- v .: "age"
        return (Dog { name = name, age = age })
    parseJSON _ = empty

instance ToJSON Dog where
    toJSON (Dog name age) = object ["name" .= name, "age" .= age]

--data Herp = Twerp Herp | Merp deriving Show

-- The main function is unchanged from before.
main :: IO ()
main = do
    let c1 = Person { name = "Tom", age = 12, dog = Nothing, children = Just [] }
        c2 = Person { name = "Julia", age = 13, dog = Just Dog {name="BoBo", age=5}, children = Nothing }
        c3 = Person { name = "Charlie", age = 14, dog = Nothing, children = Nothing }
        d1 = Dog { name = "Tom", age = 12}
    putStrLn $ "Encode: " ++ (show (encode (Person { name = "Joe", age = 12, dog = Just d1, children = Just [c1, c2, c3] })))
    putStrLn $ "Encode: " ++ (show (encode (Person { name = "Joe", age = 12, dog = Nothing, children = Just [c1, c2, c3] })))
    putStrLn $ "Encode: " ++ (show (encode (Person { name = "Joe", age = 12, dog = Nothing, children = Nothing })))    
    putStrLn $ "Decode: " ++
        (show (decode "{ \"name\": \"Joe\", \"age\": 12, \"dog\": { \"name\": \"Joe\", \"age\": 12 }, \"children\": [] }" :: Maybe Person))
    putStrLn $ "Decode: " ++
        (show (decode "{ \"name\": \"Joe\", \"age\": 12, \"dog\": { \"name\": \"Joe\", \"age\": 12 }, \"children\": [{ \"name\": \"Joe\", \"age\": 12 },{ \"name\": \"Joe\", \"age\": 12 }] }" :: Maybe Person))        
    -- putStrLn $ "Decode: " ++
    --     (show (decode "{ \"name\": \"Joe\", \"age\": 12, \"dog\": { \"name\": \"Joe\", \"age\": 12 }, \"children\": [ { \"name\": \"Joe\", \"age\": 12 }, { \"name\": \"Joe\", \"age\": 124 }, { \"name\": \"Joe\", \"age\": 132 } ] }" :: Maybe Person))
    -- putStrLn $ "Decode: " ++
    --     (show (decode "{ \"name\": \"Joe\", \"age\": 12, \"children\": [ { \"name\": \"Joe\", \"age\": 12 }, { \"name\": \"Joe\", \"age\": 124 }, { \"name\": \"Joe\", \"age\": 132 } ] }" :: Maybe Person))
