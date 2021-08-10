-- import Plutus.Contract.Trace
-- :i InitialDistribution
-- defaultDist
-- import Plutus.Trace.Emulator
-- :i EmulatorConfig
-- import Data.Default
-- def :: EmulatorConfig
-- :i FeeConfig
-- def :: FeeConfig
-- :i runEmulatorTrace
-- runEmulatorTrace def def $ return ()
-- a lot of things produced
-- :i runEmulatorTraceIO
-- runEmulatorTraceIO $ return ()
-- :i TraceConfig
-- def :: TraceConfig

-- Activate the nix-shell inside the plutus repo directory: __@__:~/plutus$ nix-shell
-- Move to plutus-pioneer-program/code/week04/
-- Access the repl: cabal repl
-- Load the Contract.hs module :l src/Week04/Contract.hs

{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators #-}

module Week04.Trace where

import Control.Monad.Freer.Extras as Extras
import Data.Default
import Data.Functor
import Ledger
import Ledger.TimeSlot
import Plutus.Trace.Emulator as Emulator
import Wallet.Emulator.Wallet
import Plutus.Contract as Contract
import Data.Text
import Data.Void 

import Week04.Vesting

test1 :: IO ()
test1 = runEmulatorTraceIO $ myTrace 20

test2 :: IO ()
test2 = runEmulatorTraceIO $ myTrace 15

myTrace :: Integer -> EmulatorTrace ()
myTrace i = do
    h1 <- activateContractWallet (Wallet 1) endpoints
    h2 <- activateContractWallet (Wallet 2) endpoints
    callEndpoint @"give" h1 $ GiveParams 
        { gpBeneficiary = pubKeyHash $ walletPubKey $ Wallet 2
        , gpDeadline = slotToBeginPOSIXTime def $ Slot 20
        , gpAmount = 10000000
        }
    void $ Emulator.waitUntilSlot (Slot i)
    callEndpoint @"grab" h2 ()
    s <- Emulator.waitNSlots 1
    Extras.logInfo $ "reached UGABUUUGOA" ++ show s

    

herp = print "ggggg"

myContract1 :: Contract () Empty Text ()
myContract1 = Contract.logInfo @String "herp herp herp !!!!!!!!!!!!!!AAA"

myTrace1 :: EmulatorTrace ()
myTrace1 = void $ activateContractWallet (Wallet 1) myContract1

test3 :: IO ()
test3 = runEmulatorTraceIO myTrace1

myContract2 :: Contract () Empty Text ()
myContract2 = do
    void $ Contract.throwError "AAAAAAAAAAAAAAAAAAAAAAAAAA what is this AAAAAAAAAAAAAAAAAAAAA"
    Contract.logInfo @String "herp herp herp !!!!!!!!!!!!!!AAA"

myContract3 :: Contract () Empty Void ()
myContract3 = Contract.handleError
    (\err -> Contract.logError $ "Caught an eRRor " ++ unpack err)
    myContract2


myTrace2 :: EmulatorTrace ()
myTrace2 = void $ activateContractWallet (Wallet 1) myContract2

myTrace3 :: EmulatorTrace ()
myTrace3 = void $ activateContractWallet (Wallet 1) myContract3

test4 :: IO ()
test4 = runEmulatorTraceIO myTrace2

test5 :: IO ()
test5 = runEmulatorTraceIO myTrace3

--"foo" enabled by {-# LANGUAGE DataKinds #-}
type MySchema = Endpoint "foo" Int 

myContract4 :: Contract () MySchema Text ()
myContract4 = do
    n <- endpoint @"foo"
    Contract.logInfo n

myTrace4 :: EmulatorTrace ()
myTrace4 = do
    s <- activateContractWallet (Wallet 1) myContract4
    callEndpoint @"foo" s 42

test6 :: IO ()
test6 = runEmulatorTraceIO myTrace4

-- .\/ <- type operator enabled by {-# LANGUAGE TypeOperators #-}
type MySchemaTwo = Endpoint "foo" Int .\/ Endpoint "bar" String

myContract5 :: Contract () MySchemaTwo Text ()
myContract5 = do
    n <- endpoint @"foo"
    Contract.logInfo n
    s <- endpoint @"bar"
    Contract.logInfo s

myTrace5 :: EmulatorTrace ()
myTrace5 = do
    s <- activateContractWallet (Wallet 1) myContract5
    callEndpoint @"foo" s 42
    callEndpoint @"bar" s "fdsgfdsgsfdgfdsgfdsgrgeagregfeg"

test7 :: IO ()
test7 = runEmulatorTraceIO myTrace5

myContract6 :: Contract [Int] Empty Text ()
myContract6 = do
    void $ Contract.waitNSlots 10
    tell [1]
    void $ Contract.waitNSlots 10
    tell [2]
    void $ Contract.waitNSlots 10

myTrace6 :: EmulatorTrace ()
myTrace6 = do
    h <- activateContractWallet (Wallet 1) myContract6
    void $ Emulator.waitNSlots 5
    xs <- observableState h
    Extras.logInfo $ show xs

    void $ Emulator.waitNSlots 10
    ys <- observableState h
    Extras.logInfo $ show ys

    void $ Emulator.waitNSlots 10
    zs <- observableState h
    Extras.logInfo $ show zs

test8 :: IO ()
test8 = runEmulatorTraceIO myTrace6

tests :: [IO ()]
tests = [test1,test2,test3,test4,test5,test6,test7,test8]