{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE DeriveAnyClass    #-}
{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications  #-}
{-# LANGUAGE TypeOperators     #-}

module Week04.Homework where

import Data.Aeson            (FromJSON, ToJSON)
import Data.Functor          (void)
import Data.Text             (Text)
import GHC.Generics          (Generic)
import Ledger
import Ledger.Ada            as Ada
import Ledger.Constraints    as Constraints
import Plutus.Contract       as Contract
import Plutus.Trace.Emulator as Emulator
import Wallet.Emulator.Wallet
import Data.Text

data PayParams = PayParams
    { ppRecipient :: PubKeyHash
    , ppLovelace  :: Integer
    } deriving (Show, Generic, FromJSON, ToJSON)

type PaySchema = Endpoint "pay" PayParams

payContract :: Contract () PaySchema Text ()
payContract = do
    pp <- endpoint @"pay"
    let tx = mustPayToPubKey (ppRecipient pp) $ lovelaceValueOf $ ppLovelace pp
        errH = \err -> Contract.logError $ "Caught an eRRor " ++ unpack err 
    Contract.handleError errH $ void $ submitTx tx
    payContract

myContract2 :: Contract () PaySchema Text ()
myContract2 = do
    void $ Contract.throwError "AAAAAAAAAAAAAAAAAAAAAAAAAA what is this AAAAAAAAAAAAAAAAAAAAA"
    Contract.logInfo @String "herp herp herp !!!!!!!!!!!!!!AAA"


-- A trace that invokes the pay endpoint of payContract on Wallet 1 twice, each time with Wallet 2 as
-- recipient, but with amounts given by the two arguments. There should be a delay of one slot
-- after each endpoint call.
payTrace :: Integer -> Integer -> EmulatorTrace ()
--payTrace _ _ = undefined -- IMPLEMENT ME!
payTrace p1 p2 = do
    h1 <- activateContractWallet (Wallet 1) payContract
    h2 <- activateContractWallet (Wallet 2) payContract
    let recipient = pubKeyHash $ walletPubKey $ Wallet 2
        payPars a = PayParams { ppRecipient = recipient, ppLovelace  = a}
    callEndpoint @"pay" h1 $ payPars p1
    void $ Emulator.waitNSlots 1
    callEndpoint @"pay" h1 $ payPars p2
    void $ Emulator.waitNSlots 1

m :: Integer -> Integer
m i = i * 1000000

payTest :: Integer -> Integer -> IO ()
payTest i1 i2 = runEmulatorTraceIO $ payTrace (m i1) (m i2)

payTest1 :: IO ()
payTest1 = payTest 1 2

payTest2 :: IO ()
payTest2 = payTest 1000 2
