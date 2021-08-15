{-# LANGUAGE DataKinds           #-}
{-# LANGUAGE DeriveAnyClass      #-}
{-# LANGUAGE DeriveGeneric       #-}
{-# LANGUAGE FlexibleContexts    #-}
{-# LANGUAGE NoImplicitPrelude   #-}
{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell     #-}
{-# LANGUAGE TypeApplications    #-}
{-# LANGUAGE TypeFamilies        #-}
{-# LANGUAGE TypeOperators       #-}

module Week05.Free where

import           Control.Monad          hiding (fmap)
import           Data.Aeson             (ToJSON, FromJSON)
import           Data.Text              (Text)
import           Data.Void              (Void)
import           GHC.Generics           (Generic)
import           Plutus.Contract        as Contract
import           Plutus.Trace.Emulator  as Emulator
import qualified PlutusTx
import           PlutusTx.Prelude       hiding (Semigroup(..), unless)
import           Ledger                 hiding (mint, singleton)
import           Ledger.Constraints     as Constraints
import qualified Ledger.Typed.Scripts   as Scripts
import           Ledger.Value           as Value
import           Playground.Contract    (printJson, printSchemas, ensureKnownCurrencies, stage, ToSchema)
import           Playground.TH          (mkKnownCurrencies, mkSchemaDefinitions)
import           Playground.Types       (KnownCurrency (..))
import           Prelude                (IO, Show (..), String)
import           Text.Printf            (printf)
import           Wallet.Emulator.Wallet

-- """""""""""""""""""""""COPIED
-- maximum permissiviness
import PlutusTx
import qualified PlutusTx.AssocMap                as Map

tname :: TokenName
--tname = error ()
tname = tokenName "abc"

{-# INLINABLE mkOneAtATimePolicy #-}
mkOneAtATimePolicy :: () -> ScriptContext -> Bool
mkOneAtATimePolicy _ ctx = 
    -- 'ownCurrencySymbol' lets us get our own hash (= currency symbol) from the context
    --  ownCurrencySymbol :: PolicyCtx -> CurrencySymbol
    let ownSymbol = ownCurrencySymbol ctx
        --https://alpha.marlowe.iohkdev.io/doc/haddock/plutus-ledger-api/html/Plutus-V1-Ledger-Contexts.html
        --TxInfo 
        txinfo = scriptContextTxInfo ctx
        --txInfoForge :: Value 
        minted = txInfoForge txinfo
        --getValue :: Map CurrencySymbol (Map TokenName Integer) 
        --mp = getValue minted
        fval = show $ flattenValue minted
        --val = case Map.lookup ownSymbol mp of 
        --        Nothing -> 0
        --        Just i -> case Map.lookup tname i of
        --            Nothing -> 0
        --            Just v -> v 
        --minted = txInfoMint txinfo
    -- Here we're looking at some specific token name, which we
    -- will assume we've got from elsewhere for now.
    -- valueOf :: Value -> CurrencySymbol -> TokenName -> Integer
    --in valueOf minted ownSymbol tname == 1
    in fval /= ""

-- We can use 'compile' to turn a minting policy into a compiled Plutus Core program,
-- just as for validator scripts. We also provide a 'wrapMintingPolicy' function
-- to handle the boilerplate.
oneAtATimeCompiled :: Scripts.MintingPolicy --CompiledCode (Data -> Data -> ())
oneAtATimeCompiled = mkMintingPolicyScript $$(PlutusTx.compile [|| Scripts.wrapMintingPolicy mkOneAtATimePolicy ||])

oneAtATimeCurSymbol :: CurrencySymbol
oneAtATimeCurSymbol = scriptCurrencySymbol oneAtATimeCompiled

data MintParams = MintParams
    { mpTokenName :: TokenName 
    , mpAmount :: !Integer
    } deriving (Generic, ToJSON, FromJSON, ToSchema)

type OneAtATimeSchema = Endpoint "mintOneAtATime" MintParams

mintOneAtATime :: MintParams -> Contract w OneAtATimeSchema Text ()
mintOneAtATime mp = do
    let tok     = mpTokenName mp
        amo     = mpAmount mp
        val     = Value.singleton oneAtATimeCurSymbol tok amo
        lookups = Constraints.mintingPolicy oneAtATimeCompiled
        tx      = Constraints.mustMintValue val
    ledgerTx <- submitTxConstraintsWith @Void lookups tx
    void $ awaitTxConfirmed $ txId ledgerTx
    Contract.logInfo @String $ printf "forged %s" (show val)

oneAtATimeEndpoint :: Contract () OneAtATimeSchema Text ()
oneAtATimeEndpoint = mint' >> oneAtATimeEndpoint
    where mint' = endpoint @"mintOneAtATime" >>= mintOneAtATime

mkSchemaDefinitions ''OneAtATimeSchema

test3 :: IO ()
test3 = runEmulatorTraceIO $ do
    --let tn = error ()
    let tn = tokenName "abc" 
    h1 <- activateContractWallet (Wallet 1) oneAtATimeEndpoint
    h2 <- activateContractWallet (Wallet 2) oneAtATimeEndpoint
    callEndpoint @"mintOneAtATime" h1 $ MintParams {
        mpTokenName = tn,
        mpAmount = 555
    }
    callEndpoint @"mintOneAtATime" h2 $ MintParams {
        mpTokenName = tn,
        mpAmount = 444
    }
    void $ Emulator.waitNSlots 1
    callEndpoint @"mintOneAtATime" h1 $ MintParams {
        mpTokenName = tn,
        mpAmount = 1
    }
    callEndpoint @"mintOneAtATime" h1 $ MintParams {
        mpTokenName = tn,
        mpAmount = 1
    }
    callEndpoint @"mintOneAtATime" h2 $ MintParams {
        mpTokenName = tn,
        mpAmount = 1
    }        
    void $ Emulator.waitNSlots 1
 
{- 
{-# LANGUAGE DataKinds           #-}
{-# LANGUAGE NoImplicitPrelude   #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell     #-}
module BasicPolicies where

--import qualified PlutusCore.Default   as PLC
import           PlutusTx
import           PlutusTx.Lift
import           PlutusTx.Prelude

import           Ledger
import           Ledger.Ada
import           Ledger.Typed.Scripts
import           Ledger.Value

tname :: TokenName
tname = error ()

key :: PubKeyHash
key = error ()

-- BLOCK1
oneAtATimePolicy :: () -> ScriptContext -> Bool
oneAtATimePolicy _ ctx =
    -- 'ownCurrencySymbol' lets us get our own hash (= currency symbol)
    -- from the context
    let ownSymbol = ownCurrencySymbol ctx
        txinfo = scriptContextTxInfo ctx
        minted = txInfoForge txinfo
    -- Here we're looking at some specific token name, which we
    -- will assume we've got from elsewhere for now.
    in valueOf minted ownSymbol tname == 1

-- We can use 'compile' to turn a minting policy into a compiled Plutus Core program,
-- just as for validator scripts. We also provide a 'wrapMintingPolicy' function
-- to handle the boilerplate.
oneAtATimeCompiled :: CompiledCode (BuiltinData -> BuiltinData -> ())
oneAtATimeCompiled = $$(compile [|| wrapMintingPolicy oneAtATimePolicy ||])
-- BLOCK2
singleSignerPolicy :: ScriptContext -> Bool
singleSignerPolicy ctx = txSignedBy (scriptContextTxInfo ctx) key
-- BLOCK3 -}