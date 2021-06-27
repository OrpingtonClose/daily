{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module Lib
    ( someFunc
    ) where

-- import Data.Aeson

-- val :: Value
-- val = object [
--   "boolean" .= True,
--   "numbers" .= [1,2,3::Int] ] 

-- data Bitcoin = Bitcoin
--   { bitcoin :: BitcoinData } deriving (Show)

-- data Occupation = Occupation
--   { title :: String
--   , tenure :: Int
--   , salary :: Int 
--   } deriving (Show)

-- import Control.Lens
  -- from lens

import Data.Aeson
import Data.Map
import Data.Text
import Data.Time.Clock
import Data.Maybe
-- import Data.Aeson.QQ
-- import Data.Aeson.Lens
  -- from lens-aeson

-- someJSON :: Value
-- someJSON = [aesonQQ|
--   {
--     "data": {
--       "timestamps": {
--         "created_at": "2019-05-11 17:53:21"
--       }
--     }
--   }
-- |]

someFunc :: IO ()
--https://www.fpcomplete.com/haskell/library/aeson/
someFunc = do
    print $ (decode "true" :: Maybe Bool)
    print $ (decode "[1, 2, 3]" :: Maybe [Int])
    print $ (decode "\"1984-10-15T00:00:00Z\"" :: Maybe UTCTime)
    print $ (decode "{ \"foo\": 0, \"bar\":1, \"baz\": 2 }" :: Maybe (Map Text Int))
    print $ encode (read "1984-10-15 00:00:00 UTC" :: UTCTime)
    print $ encode (fromList [ ("bar" :: Text, 1 :: Int), ("baz" :: Text, 2 :: Int), ("foo" :: Text, 0 :: Int) ])
    print $ Prelude.replicate 10 '='
    print $ (decode "{ \"foo\": false, \"bar\": [1, 2, 3] }" :: Maybe Value)
    -- print $ encode [1, 2, 3]
    -- print $ (decode "[1,2,3]" :: Maybe [Integer])
    -- print $ (decode "foo" :: Maybe [Integer])
    -- print $ (eitherDecode "[1,2,[3,false]]" :: Either String (Int, Int, (Int, Bool)))
    -- print $ show val
    -- print $ show $ someJSON ^? key "data".key "timestamps".key "created_at"
    --print (decodeJSON aa :: Person)
    --let aa = "{\"name\": \"some body\", \"age\" : 23, \"address\" : {\"house\" : 285, \"street\" : \"7th Ave.\", \"city\" : \"New York\", \"state\" : \"New York\", \"zip\" : 10001}}"
    --putStrLn "someFunc"
