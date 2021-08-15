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

{-# INLINABLE mkPolicy #-}
mkPolicy :: () -> ScriptContext -> Bool
mkPolicy () _ = True

{-# INLINABLE mkPolicySigned #-}
mkPolicySigned :: PubKeyHash -> () -> ScriptContext -> Bool
mkPolicySigned pkh () ctx = txSignedBy (scriptContextTxInfo ctx) pkh

{- tname :: TokenName
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
 -}
policy :: Scripts.MintingPolicy
policy = mkMintingPolicyScript $$(PlutusTx.compile [|| Scripts.wrapMintingPolicy mkPolicy ||])

policySigned :: PubKeyHash -> Scripts.MintingPolicy
policySigned pkh = mkMintingPolicyScript $ 
    $$(PlutusTx.compile [|| Scripts.wrapMintingPolicy . mkPolicySigned ||])
    `PlutusTx.applyCode`
    (PlutusTx.liftCode pkh)
  
-- We can use 'compile' to turn a minting policy into a compiled Plutus Core program,
-- just as for validator scripts. We also provide a 'wrapMintingPolicy' function
-- to handle the boilerplate.
--oneAtATimeCompiled :: Scripts.MintingPolicy --CompiledCode (Data -> Data -> ())
--oneAtATimeCompiled = mkMintingPolicyScript $$(PlutusTx.compile [|| Scripts.wrapMintingPolicy mkOneAtATimePolicy ||])

curSymbol :: CurrencySymbol
curSymbol = scriptCurrencySymbol policy
--curSymbol -> 94e87e7456582edf7c8504a2352802450013a36ee9e5f2855d73db3e
--hash of compiled minting policy

curSymbolSigned :: PubKeyHash -> CurrencySymbol
curSymbolSigned = scriptCurrencySymbol . policySigned

--oneAtATimeCurSymbol :: CurrencySymbol
--oneAtATimeCurSymbol = scriptCurrencySymbol oneAtATimeCompiled

-- :set -XOverloadedStrings
-- show $ snd (1, 4) 
-- show $ fst (1, 4) 
-- Plutus.V1.Ledger.Ada.lovelaceValueOf 123
-- lovelaceValueOf 123 <> lovelaceValueOf 10
-- lovelaceValueOf 123 <> lovelaceValueOf -110
-- lovelaceValueOf 123 <> lovelaceValueOf 10
-- Plutus.V1.Ledger.Value.singleton "a8ff" "aaa" 7 <> lovelaceValueOf 12 <> Plutus.V1.Ledger.Value.singleton "a8ff" "xyz" 7
-- let v = Plutus.V1.Ledger.Value.singleton "a8ff" "aaa" 7 <> lovelaceValueOf 12 <> Plutus.V1.Ledger.Value.singleton "a8ff" "xyz" 7
-- import Plutus.V1.Ledger.Value
-- valueOf
-- valueOf v "a8ff" "xyz"
-- valueOf v "" ""
-- Plutus.V1.Ledger.Value.flattenValue v
-- [(show k, k2, v1) | (k, vs) <- (PlutusTx.AssocMap.toList $ getValue $ v), (k2, v1) <- PlutusTx.AssocMap.toList vs]

data MintParams = MintParams
    { mpTokenName :: TokenName 
    , mpAmount :: !Integer
    } deriving (Generic, ToJSON, FromJSON, ToSchema)

type FreeSchema = Endpoint "mint" MintParams

type SignedFreeSchema = Endpoint "mintSigned" MintParams

--type OneAtATimeSchema = Endpoint "mintOneAtATime" MintParams

mint :: MintParams -> Contract w FreeSchema Text ()
mint mp = do
    let tok     = mpTokenName mp
        amo     = mpAmount mp
        val     = Value.singleton curSymbol tok amo
        lookups = Constraints.mintingPolicy policy
        tx      = Constraints.mustMintValue val
    ledgerTx <- submitTxConstraintsWith @Void lookups tx
    void $ awaitTxConfirmed $ txId ledgerTx
    Contract.logInfo @String $ printf "forged %s" (show val)

mintSigned :: MintParams -> Contract w SignedFreeSchema Text ()
mintSigned mp = do
    pkh <- pubKeyHash <$> Contract.ownPubKey
    let cur     = curSymbolSigned pkh
        tok     = mpTokenName mp
        amo     = mpAmount mp
        val     = Value.singleton cur tok amo
        lookups = Constraints.mintingPolicy $ policySigned pkh 
        tx      = Constraints.mustMintValue val
    ledgerTx <- submitTxConstraintsWith @Void lookups tx
    void $ awaitTxConfirmed $ txId ledgerTx
    Contract.logInfo @String "======================================"
    Contract.logInfo @String $ printf "forged ====<<SIGNED>>==== %s" (show val)
    Contract.logInfo @String "======================================"

{- mintOneAtATime :: MintParams -> Contract w OneAtATimeSchema Text ()
mintOneAtATime mp = do
    let tok     = mpTokenName mp
        amo     = mpAmount mp
        val     = Value.singleton oneAtATimeCurSymbol tok amo
        lookups = Constraints.mintingPolicy oneAtATimeCompiled
        tx      = Constraints.mustMintValue val
    ledgerTx <- submitTxConstraintsWith @Void lookups tx
    void $ awaitTxConfirmed $ txId ledgerTx
    Contract.logInfo @String $ printf "forged %s" (show val) -}

endpoints :: Contract () FreeSchema Text ()
endpoints = mint' >> endpoints
    where mint' = endpoint @"mint" >>= mint

endpointsSigned :: Contract () SignedFreeSchema Text ()
endpointsSigned = mint' >> endpointsSigned
    where mint' = endpoint @"mintSigned" >>= mintSigned

{- oneAtATimeEndpoint :: Contract () OneAtATimeSchema Text ()
oneAtATimeEndpoint = mint' >> oneAtATimeEndpoint
    where mint' = endpoint @"mintOneAtATime" >>= mintOneAtATime
 -}
mkSchemaDefinitions ''FreeSchema
mkSchemaDefinitions ''SignedFreeSchema
--mkSchemaDefinitions ''OneAtATimeSchema
mkKnownCurrencies []

test :: IO ()
test = runEmulatorTraceIO $ do
    let tn = "abc"
    h1 <- activateContractWallet (Wallet 1) endpoints
    h2 <- activateContractWallet (Wallet 2) endpoints
    callEndpoint @"mint" h1 $ MintParams {
        mpTokenName = tn,
        mpAmount = 555
    }
    callEndpoint @"mint" h2 $ MintParams {
        mpTokenName = tn,
        mpAmount = 444
    }
    void $ Emulator.waitNSlots 1
    callEndpoint @"mint" h1 $ MintParams {
        mpTokenName = tn,
        mpAmount = -222
    }
    void $ Emulator.waitNSlots 1

test2 :: IO ()
test2 = runEmulatorTraceIO $ do
    let tn = "abc"
    h1 <- activateContractWallet (Wallet 1) endpointsSigned
    h2 <- activateContractWallet (Wallet 2) endpointsSigned
    callEndpoint @"mintSigned" h1 $ MintParams {
        mpTokenName = tn,
        mpAmount = 555
    }
    callEndpoint @"mintSigned" h2 $ MintParams {
        mpTokenName = tn,
        mpAmount = 444
    }
    void $ Emulator.waitNSlots 1
    callEndpoint @"mintSigned" h1 $ MintParams {
        mpTokenName = tn,
        mpAmount = -222
    }
    void $ Emulator.waitNSlots 1

{- test3 :: IO ()
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
  -}