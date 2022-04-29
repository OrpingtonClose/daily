import qualified Data.Text                 as T
import           Language.Plutus.Contract  hiding (when)
import           Language.PlutusTx.Prelude
import           Playground.Contract

-- | A 'Contract' that logs a message.
-- hello :: Contract BlockchainActions T.Text ()
-- hello = logInfo @String "herp merp"

endpoints :: Contract BlockchainActions T.Text ()
endpoints = logInfo @String "no hello needed"

mkSchemaDefinitions ''BlockchainActions

$(mkKnownCurrencies [])
