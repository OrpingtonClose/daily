import Prelude
-- https://www.youtube.com/watch?v=IMlDZNWTurw
-- stack new json-tutorial quanterall/basic
import RIO
import qualified Network.HTTP.Client as HTTP
import Network.HTTP.Client.TLS (newTlsManager)
import Data.Aeson (FromJSON(..), ToJSON(..), (.:))
import qualified Data.Aeson as JSON
import Data.Char

data User = User {
  userId :: !Int,
  userName :: !Text,
  userUsername :: !Text,
  userEmail :: !Text
} deriving (Eq, Show, Generic)

data Address = Address {
  
}

instance ToJSON User where
  toJSON = JSON.genericToJSON $ jsonOptions "user"

instance FromJSON User where
  parseJSON = JSON.genericParseJSON $ jsonOptions "user"

jsonOptions :: String -> JSON.Options
jsonOptions prefix = let prefixLength = length prefix
                         lowercaseFirstCharacter (c : rest) = toLower c : rest
                         lowercaseFirstCharacter [] = []
                      in JSON.defaultOptions {JSON.fieldLabelModifier = drop prefixLength >>>lowercaseFirstCharacter}


getUsersContent :: IO LByteString
getUsersContent = do
  manager <- newTlsManager
  request <- HTTP.parseRequest "https://jsonplaceholder.typicode.com/users"
  HTTP.responseBody <$> HTTP.httpLbs request manager

getUsers :: IO (Either String [User])
getUsers = do
  manager <- newTlsManager
  request <- HTTP.parseRequest "https://jsonplaceholder.typicode.com/users"
  (HTTP.responseBody >>> JSON.eitherDecode) <$> HTTP.httpLbs request manager

runMain :: IO ()
runMain = do
  putStrLn "Hello, World!"
