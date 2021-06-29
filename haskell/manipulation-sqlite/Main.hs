{-# LANGUAGE OverloadedStrings #-}
--https://hackage.haskell.org/package/sqlite-simple-0.4.18.0/docs/Database-SQLite-Simple.html

import System.Directory
import Control.Applicative
import Control.Monad
import Database.SQLite.Simple
import Database.SQLite.Simple.FromRow
import qualified Data.Text as T

data TestField = TestField Int String deriving (Show)

instance FromRow TestField where
    fromRow = TestField <$> field <*> field

instance ToRow TestField where
    toRow (TestField id_ str) = toRow (id_, str)

main :: IO ()
main = do
    doesFileExist "test.db" >>= (\x -> when x (removeFile "test.db"))
    writeFile "test.db" ""    
    conn <- open "test.db"
    execute_ conn "CREATE TABLE IF NOT EXISTS test (id INTEGER PRIMARY KEY, str TEXT)"
    execute conn "INSERT INTO test (str) VALUES (?)" (Only ("test string 2" :: String))
    execute conn "INSERT INTO test (id, str) VALUES (?,?)" (TestField 13 "test string 3")
    rowId <- lastInsertRowId conn
    executeNamed conn "UPDATE test SET str = :str WHERE id = :id" [":str" := ("updated str" :: T.Text), ":id" := rowId]    
    r <- (query_ conn "SELECT * from test") :: IO [TestField]
    mapM_ print r
    [[x]] <- query_ conn "select 2 + 2" :: IO [[Int]]
    print $ show x    
    close conn
