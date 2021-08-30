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
import Data.Aeson.Encode.Pretty
import GHC.Prelude (putStrLn)
import Data.Aeson.Lens
import Control.Lens hiding ((.=))
import Data.List
import Data.Char

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
        , "params" .= [T "0x41550b", B True]   --(Data.Vector.cons (Data.Aeson.String "latest") $ Data.Vector.singleton $ Data.Aeson.Bool True)   --[T "latest", B True]
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
            $ setRequestBodyJSON (EthereumGetBlockByNumberRequest "2.0" "eth_getBlockByNumber" [T "0x41550b", B True] 67)
--            $ setRequestBodyJSON (object [ "jsonrpc" .= "2.0", "method"  .= "eth_blockNumber", "params" .= [], "id" .= 67])
            $ request'
    response <- httpJSON request
    return (getResponseBody response) -- :: EthereumBlockNumberResponse

-- mapM_ print ((\(s, n) -> (unpack s) ++ (unpack " -> ") ++ (show n)) <$> ((arr Data.List.head) &&& (arr Data.List.length)) <$> (Data.List.group $ sort ((Prelude.map (\(Object o) -> fst <$> toList o) (a ^.. key "result" . key "transactions". values) ) >>= Prelude.id)))

--eth_getTransactionByHash
--mapM_ print ((\(s, n) -> (unpack s) ++ (unpack " -> ") ++ (show n)) <$> (getTransactionByHash hash)
getTransactionByHash :: String -> IO Data.Aeson.Value
getTransactionByHash hash = do
    request' <- parseRequest "POST https://mainnet.infura.io/v3/fde0dbb3269540a29059ed81756e7923"
    let request
            = setRequestMethod "POST"
--            $ setRequestBodyJSON (EthereumGetBlockByNumberRequest "2.0" "eth_getBlockByNumber" [T "latest", B True] 67)
            $ setRequestBodyJSON (object [ "jsonrpc" .= ("2.0" :: Text)
                                         , "method"  .= ("eth_getTransactionByHash" :: Text)
                                         , "params" .= [pack hash]
                                         , "id" .= ("67" :: Text)])
            $ request'
    response <- httpJSON request
    return (getResponseBody response) -- :: EthereumBlockNumberResponse

--a <- getTransactionReceipt "0xbb3a336e3f823ec18197f1e13ee875700f08f03e2cab75f0d0b118dabb44cba0"
--a <- getTransactionReceipt "0x5488510df045770efbff57f25d0c6d2c1404d58c1199b21eb8dc5072b22d91d7"
--a ^.. key "result" . key "contractAddress"
getTransactionReceipt :: Text -> IO Data.Aeson.Value
getTransactionReceipt hash = do
    request' <- parseRequest "POST https://mainnet.infura.io/v3/fde0dbb3269540a29059ed81756e7923"
    let request
            = setRequestMethod "POST"
--            $ setRequestBodyJSON (EthereumGetBlockByNumberRequest "2.0" "eth_getBlockByNumber" [T "latest", B True] 67)
            $ setRequestBodyJSON (object [ "jsonrpc" .= ("2.0" :: Text)
                                         , "method"  .= ("eth_getTransactionReceipt" :: Text)
                                         , "params" .= [hash]
                                         , "id" .= ("67" :: Text)])
            $ request'
    response <- httpJSON request
    return (getResponseBody response) -- :: EthereumBlockNumberResponse

--a <- getGetCode "0x514910771af9ca656af840dff83e8264ecf986ca"
--a <- getGetCode "0xf55037738604fddfc4043d12f25124e94d7d1780"
getGetCode :: String -> IO Data.Aeson.Value
getGetCode addr = do
    request' <- parseRequest "POST https://mainnet.infura.io/v3/fde0dbb3269540a29059ed81756e7923"
    let request
            = setRequestMethod "POST"
            $ setRequestBodyJSON (object [ "jsonrpc" .= ("2.0" :: Text)
                                         , "method"  .= ("eth_getCode" :: Text)
                                         , "params" .= [pack addr, "latest"]
                                         , "id" .= ("67" :: Text)])
            $ request'
    response <- httpJSON request
    return (getResponseBody response)

printBlocknum = do
    a <- ethBlockNumber
    print a

--https://github.com/danidiaz/lens-aeson-examples/blob/master/src/Data/Aeson/Lens/Examples.hs
-- == Getting the names and ages of all persons
-- Module "Control.Lens.Reified" provides the 'ReifiedFold' newtype, which has
-- many useful instances. In particular, the "Applicative" instance can be used to
-- extract two fields at the same time:
-- >>> :{
--     let Fold nameAndAge = (,) <$> Fold (key "name"._String) <*> Fold (key "age"._Integer)
--     in persons^..values.nameAndAge
--     :}
-- [("Alice",43),("Bob",50),("Jim",51)]

--(Object o) = Prelude.head $ (a ^.. key "result" . key "transactions" . nth 1 )
--fst <$> toList o
--((arr Data.List.head) &&& (arr Data.List.length)) <$> (Data.List.group $ sort ((Prelude.map (\(Object o) -> fst <$> toList o) (a ^.. key "result" . key "transactions". values) ) >>= Prelude.id))
--mapM_ print ((\(s, n) -> (unpack s) ++ (unpack " -> ") ++ (show n)) <$> ((arr Data.List.head) &&& (arr Data.List.length)) <$> (Data.List.group $ sort ((Prelude.map (\(Object o) -> fst <$> toList o) (a ^.. key "result" . key "transactions". values) ) >>= Prelude.id)))

someFunc :: IO ()
someFunc = do
    --printBlocknum
    block <- getBlockByNumber
    let trns = Data.List.filter (not . Data.List.null) (Data.List.map ((^.. key "result" . key "contractAddress" . nonNull) ) recipts) >>= Prelude.id
    recipts <- mapM getTransactionReceipt trns
    let b = Data.List.map (^.. key "result" . key "contractAddress") recipts
    print b
