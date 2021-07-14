{-# LANGUAGE OverloadedStrings #-}

module Main where

import Network.HTTP.Simple
import qualified Data.ByteString.Char8 as B8
import Data.Aeson
import Control.Lens
import Data.Aeson.Lens
import Data.Text
import qualified Data.Text.IO as TIO
import qualified Data.HashMap.Internal
import Data.Maybe

fetchJSON :: IO B8.ByteString
fetchJSON = do
  res <- httpBS "https://api.coindesk.com/v1/bpi/currentprice.json"
  return (getResponseBody res)

getRate :: B8.ByteString -> Maybe Value
--getRate = preview (key "bpi" . key "USD" . key "rate" . _String)
getRate = preview (key "bpi" . key "USD" )
-- map key ["bpi","USD","rate"] ++ [_String]

--stringifyJson :: IO String
--stringifyJson = B8.unpack fetchJSON

--herp = httpBS "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd&include_market_cap=true&include_24hr_vol=true&include_24hr_change=true&include_last_updated_at=true"  
--herp1 = decode (B8.unpack herp) :: Maybe Value
--getResponseBody $
main :: IO ()
main =  do
  json <- fetchJSON
  case getRate json of 
              Nothing -> TIO.putStrLn "Nothing"
              --Just (Object a) -> print $ Prelude.foldl (\acc (x,y) -> acc ++ x ++ ":" ++ y ++ "\n") "" $ Data.HashMap.Internal.toList a
              Just (Object a) -> print $ fromJust $ Data.HashMap.Internal.lookup "rate" a
  --TIO.putStrLn $ preview _String json              
  --  herp <- B8.unpack json --) --:: Maybe Value
    --print fetchJSON
--main = decode herp :: Maybe Value