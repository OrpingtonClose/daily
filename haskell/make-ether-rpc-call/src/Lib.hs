{-# LANGUAGE OverloadedStrings #-}

module Lib
    ( someFunc
    ) where

import           Data.Aeson           
import qualified Data.ByteString.Char8 as S8
import qualified Data.Yaml             as Yaml
import           Network.HTTP.Simple
import Data.Text

simpleRequest :: IO ()
simpleRequest = do
    request' <- parseRequest "POST http://httpbin.org/post"
    let request
            = setRequestMethod "PUT"
            $ setRequestPath "/put"
            $ setRequestQueryString [("hello", Just "world")]
            $ setRequestBodyFile "aaa.txt"
            $ setRequestSecure True
            $ setRequestPort 443
            $ request'
    response <- httpJSON request

    putStrLn $ "The status code was: " ++
               show (getResponseStatusCode response)
    print $ getResponseHeader "Content-Type" response
    S8.putStrLn $ Yaml.encode (getResponseBody response :: Value)

--{"jsonrpc":"2.0","method":"eth_protocolVersion","params":[],"id":67}
--https://www.schoolofhaskell.com/school/to-infinity-and-beyond/pick-of-the-week/sum-types
--data EtherParam = T Text | B Bool deriving Show
--data EthereumRequest = EthereumRequest { jsonrpc :: Text, method :: Text, params :: [EtherParam], id :: Int} deriving Show
data EthereumRequest = EthereumRequest { jsonrpc :: Text, method :: Text, params :: [Text], id :: Int} deriving Show
instance ToJSON EthereumRequest where
    toJSON (EthereumRequest jsonrpc method params id) = object
        [ "jsonrpc" .= jsonrpc
        , "method"  .= method
        , "params" .= params
        , "id" .= id
        ]

-- instance FromJSON EthereumRequest where
--     toJSON (EthereumRequest jsonrpc method params id) = object
--         [ "jsonrpc" .= jsonrpc
--         , "method"  .= method
--         , "params" .= params
--         , "id" .= id
--         ]

protocolVersion = do
    request' <- parseRequest "POST https://mainnet.infura.io/v3/fde0dbb3269540a29059ed81756e7923"
    let request
            = setRequestMethod "POST"
            $ setRequestBodyJSON (EthereumRequest "2.0" "eth_protocolVersion" [] 67)
            $ request'
    response <- httpJSON request

    putStrLn $ "The status code was: " ++
               show (getResponseStatusCode response)
    print $ getResponseHeader "Content-Type" response
    --S8.putStrLn $ Yaml.encode (getResponseBody response :: Value)
    print $ (getResponseBody response :: Value)

-- getBlockByNumber = do
--     request' <- parseRequest "POST https://mainnet.infura.io/v3/fde0dbb3269540a29059ed81756e7923"
--     let request
--             = setRequestMethod "POST"
--             $ setRequestBodyJSON (EthereumRequest "2.0" "eth_getBlockByNumber" [(T "latest"), (B True)] 67)
--             $ request'
--     response <- httpJSON request

--     putStrLn $ "The status code was: " ++
--                show (getResponseStatusCode response)
--     print $ getResponseHeader "Content-Type" response
--     --S8.putStrLn $ Yaml.encode (getResponseBody response :: Value)
--     print $ (getResponseBody response :: Value)

someFunc :: IO ()
someFunc = do
    simpleRequest
    print $ Prelude.concat $ (Prelude.replicate 10 "=")
    protocolVersion
    print $ Prelude.concat $ (Prelude.replicate 10 "=")
    -- getBlockByNumber