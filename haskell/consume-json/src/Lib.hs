{-# LANGUAGE OverloadedStrings #-}

module Lib
    ( someFunc
    ) where

import Network.HTTP.Simple
import qualified Data.ByteString.Char8 as B8

someFunc :: IO ()
someFunc = httpBS "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd&include_market_cap=true&include_24hr_vol=true&include_24hr_change=true&include_last_updated_at=true" >>= B8.putStrLn . getResponseBody
