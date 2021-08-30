{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DuplicateRecordFields #-}

import           Data.Aeson           
import qualified Data.ByteString.Char8 as S8
--import qualified Data.Yaml             as Yaml
import Network.HTTP.Simple
import Data.Text
import Numeric
import qualified Data.ByteString as BS
import Data.Text.Read (hexadecimal)
import Data.Either (fromRight)
import Data.Aeson.Types
import Data.Vector (singleton, cons)

--{"jsonrpc":"2.0","method":"eth_protocolVersion","params":[],"id":67}
--https://www.schoolofhaskell.com/school/to-infinity-and-beyond/pick-of-the-week/sum-types
--data EtherParam = T Text | B Bool deriving Show
--data EthereumRequest = EthereumRequest { jsonrpc :: Text, method :: Text, params :: [EtherParam], id :: Int} deriving Show
data EthereumProtocolVersionRequest = EthereumProtocolVersionRequest { jsonrpc :: Text, method :: Text, params :: [Text], id :: Int} deriving Show
data EthereumProtocolVersionResponse = EthereumProtocolVersionResponse { jsonrpc :: Text, result :: Text, id :: Int} deriving Show
instance ToJSON EthereumProtocolVersionRequest where
    toJSON (EthereumProtocolVersionRequest jsonrpc method params id) = object
        [ "jsonrpc" .= jsonrpc
        , "method"  .= method
        , "params" .= params
        , "id" .= id
        ]

instance FromJSON EthereumProtocolVersionResponse where
    parseJSON (Object v) = do
        id <- v .: "id"
        result <- v .: "result"
        jsonrpc <- v .: "jsonrpc"
        return EthereumProtocolVersionResponse {jsonrpc = jsonrpc, result = result, id = id}
--    parseJSON _ = empty

data EthereumBlockNumberRequest = EthereumBlockNumberRequest { jsonrpc :: Text, method :: Text, params :: [Text], id :: Int} deriving Show
data EthereumBlockNumberResponse = EthereumBlockNumberResponse { jsonrpc :: Text, result :: Text, id :: Int} deriving Show
instance ToJSON EthereumBlockNumberRequest where
    toJSON (EthereumBlockNumberRequest jsonrpc method params id) = object
        [ "jsonrpc" .= jsonrpc
        , "method"  .= method
        , "params" .= params
        , "id" .= id
        ]

instance FromJSON EthereumBlockNumberResponse where
    parseJSON (Object v) = do
        id <- v .: "id"
        result <- v .: "result"
        jsonrpc <- v .: "jsonrpc"
        return EthereumBlockNumberResponse {jsonrpc = jsonrpc, result = result, id = id}


ethBlockNumber :: IO Int
ethBlockNumber = do
    request' <- parseRequest "POST https://mainnet.infura.io/v3/fde0dbb3269540a29059ed81756e7923"
    let request
            = setRequestMethod "POST"
            $ setRequestBodyJSON (EthereumProtocolVersionRequest "2.0" "eth_blockNumber" [] 67) $ request'
            -- $ setRequestBodyJSON (object [ "jsonrpc" .= ("2.0" :: Data.Text.Text), 
            --                                "method"  .= ("eth_blockNumber" :: Data.Text.Text), 
            --                                "params" .= (Data.Aeson.Types.emptyArray), 
            --                                "id" .= (67 :: Int)]) $ request'
    response <- httpJSON request
    --let r = result $ 
    return (fst $ fromRight ((0, "") :: (Int, Data.Text.Text)) $ Data.Text.Read.hexadecimal $ (result (getResponseBody response :: EthereumBlockNumberResponse)))

ethProtocolVersion = do
    request' <- parseRequest "POST https://mainnet.infura.io/v3/fde0dbb3269540a29059ed81756e7923"
    let request
            = setRequestMethod "POST"
            $ setRequestBodyJSON (EthereumProtocolVersionRequest "2.0" "eth_protocolVersion" [] 67)
            $ request'
    response <- httpJSON request

    putStrLn $ "The status code was: " ++ show (getResponseStatusCode response)
    print $ getResponseHeader "Content-Type" response
    print $ (getResponseBody response :: EthereumProtocolVersionResponse)

data GetBlockByNumberParamType = T Text | B Bool deriving Show
instance ToJSON GetBlockByNumberParamType where
    toJSON (T text) = String text
    toJSON (B bool) = if bool then Bool True else Bool False

data EthereumGetBlockByNumberRequest = EthereumGetBlockByNumberRequest { jsonrpc :: Text, method :: Text, params :: [GetBlockByNumberParamType], id :: Int} deriving Show
data EthereumGetBlockByNumberResponse = EthereumGetBlockByNumberResponse { jsonrpc :: Text, result :: Text, id :: Int} deriving Show
instance ToJSON EthereumGetBlockByNumberRequest where
    toJSON (EthereumGetBlockByNumberRequest jsonrpc method params id) = object
        [ "jsonrpc" .= jsonrpc
        , "method"  .= method
        , "params" .= [T "latest", B True]   --(Data.Vector.cons (Data.Aeson.String "latest") $ Data.Vector.singleton $ Data.Aeson.Bool True)   --[T "latest", B True]
        , "id" .= id
        ]

-- instance FromJSON EthereumBlockNumberResponse where
--     parseJSON (Object v) = do
--         id <- v .: "id"
--         result <- v .: "result"
--         jsonrpc <- v .: "jsonrpc"
--         return EthereumBlockNumberResponse {jsonrpc = jsonrpc, result = result, id = id}


getBlockByNumber :: IO Data.Aeson.Value
getBlockByNumber = do
    request' <- parseRequest "POST https://mainnet.infura.io/v3/fde0dbb3269540a29059ed81756e7923"
    let request
            = setRequestMethod "POST"
            $ setRequestBodyJSON (EthereumGetBlockByNumberRequest "2.0" "eth_getBlockByNumber" [T "latest", B True] 67)
--            $ setRequestBodyJSON (object [ "jsonrpc" .= "2.0", "method"  .= "eth_blockNumber", "params" .= [], "id" .= 67])
            $ request'
    response <- httpJSON request
    return (getResponseBody response) -- :: EthereumBlockNumberResponse


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

printBlocknum = do
    a <- ethBlockNumber
    print a

someFunc :: IO ()
someFunc = do
    printBlocknum
    a <- getBlockByNumber
    print $ encode a
    print "fff"
    --a <- ethBlockNumber
    --print ethBlockNumber
--    let r = result (a :: EthereumBlockNumberResponse) 
--    print $ fst $ fromRight ((0, "") :: (Int, Data.Text.Text)) $ Data.Text.Read.hexadecimal a
--    print $ fst $ fromRight ((0, "") :: (Int, Data.Text.Text)) $ Data.Text.Read.hexadecimal r
--    print $ Prelude.concat $ (Prelude.replicate 10 "=")
--    ethProtocolVersion
--    print $ Prelude.concat $ (Prelude.replicate 10 "=")
--    getBlockByNumber
