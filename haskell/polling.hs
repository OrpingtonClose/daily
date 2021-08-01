{-# LANGUAGE OverloadedStrings #-}

import Network.HTTP.Conduit
import qualified Data.ByteString.Lazy as L
import Network (withSocketsDo)
import Control.Concurrent (threadDelay)
import Data.Char

--url = "https://api.coindesk.com/v1/bpi/historical/close.json"
url = "https://www.reddit.com/r/CryptoMoonShots/"

get :: String -> IO L.ByteString
get url = do
    r <- simpleHttp url
    return r

pool :: IO ()
pool = do
    r <- get url
--    L.putStr $ map (\x -> x ++ 10) $ L.split (fromIntegral (ord '<')) r
    L.putStr $ L.intercalate "\n" $ L.split (fromIntegral (ord '<')) r
    threadDelay (3 * 10^6)
    pool

main :: IO ()
main = do
    putStrLn $ "Polling " ++ url ++ " …"
    pool
