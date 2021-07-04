{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE EmptyDataDecls #-}
--compiler told me to add those:
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE DataKinds #-}

module Main where

import Database.Persist.TH
import Data.Text as T
import Database.Persist.Sqlite
import Database.Persist.Sql as S
import Control.Monad.Reader
import Control.Monad.IO.Class 

share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
    Stock
     exchange Text
     symbol Text
     UniqueStockId exchange symbol
     deriving Show
   User
     name Text
     email Text
     UniqueEmailId email
     deriving Show
   UserStock
    userid UserId
    stockid StockId
    Primary userid stockid
    deriving Show
   |]

createSchema :: (Monad m, MonadIO m) => ReaderT SqlBackend m ()
createSchema = runMigration migrateAll

insertData :: (Monad m, MonadIO m) => ReaderT SqlBackend m (Key User, Key User, Key Stock, Key Stock)
insertData = do
  johnid <- insert $ User "John Broker" "john@example.com"
  janeid <- insert $ User "Jane Investor" "jane@example.com"
-- Insert few stocks
  dbsid <- insert $ Stock "XSES" "D05"
  infyid <- insert $ Stock "XNSE" "INFY"
-- Associate the user with stock
  john_d05 <- insert $ UserStock johnid dbsid
  john_infy <- insert $ UserStock johnid infyid
  jane_d05 <- insert $ UserStock janeid dbsid
  return (johnid, janeid, dbsid, infyid)

queryUserStockCount :: MonadIO m => Key User -> ReaderT SqlBackend m Int
queryUserStockCount user = do
  S.count [UserStockUserid ==. user]

deleteUserStock :: MonadIO m => UserId -> StockId -> ReaderT SqlBackend m ()
deleteUserStock user stock = do
  S.delete (UserStockKey user stock)

updateUserName :: MonadIO m => UserId -> Text -> ReaderT SqlBackend m ()
updateUserName user newname = S.update user [UserName =. newname]

main :: IO ()
main = runSqlite ":memory:" $ do
  createSchema
  johnid <- insert $ User "John Broker" "john@example.com"
  liftIO $ putStrLn $ "OOOOO" ++ show johnid
  janeid <- insert $ User "Jane Investor" "jane@example.com"
-- Insert few stocks
  dbsid <- insert $ Stock "XSES" "D05"
  infyid <- insert $ Stock "XNSE" "INFY"
-- Associate the user with stock
  john_d05 <- insert $ UserStock johnid dbsid
  john_infy <- insert $ UserStock johnid infyid
  jane_d05 <- insert $ UserStock janeid dbsid

  count <- S.count [UserStockUserid ==. johnid]
  liftIO $ putStrLn $ "John has " ++ show count ++ " stocks"
  liftIO $ putStrLn $ "Delete John's DBS stock"
  deleteUserStock johnid dbsid
  count1 <- queryUserStockCount johnid
  liftIO $ putStrLn $ "Now John has " ++ show count1 ++ "stocks"
  liftIO $ putStrLn $ "Change Jane's name"
  updateUserName janeid "Jane Quant"
   -- Retrieve new name
  jane <- get janeid
  liftIO $ putStrLn $ "Jane's name is now " ++ show jane
  return ()
