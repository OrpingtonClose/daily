import System.Directory (doesDirectoryExist, getDirectoryContents)
import System.FilePath ((</>))
import Control.Monad
import Control.Monad.Trans
import Control.Monad.Writer
import qualified Control.Monad.Trans.Writer
import Data.Monoid

listDirectory :: FilePath -> IO [String]
listDirectory = liftM (filter notDots) . getDirectoryContents
    where notDots p = p /= "." && p /= ".."

countEntriesTrad :: FilePath -> IO [(FilePath,Int)]
countEntriesTrad path = do
    contents <- listDirectory path
    rest <- forM contents $ \name -> do
        let newName = path </> name
        isDir <- doesDirectoryExist newName
        if isDir then countEntriesTrad newName else return []
    return $ (path, length contents): concat rest

countEntries :: FilePath -> WriterT [(FilePath, Int)] IO ()
countEntries path = do
    c <- liftIO . listDirectory $ path
    tell [(path, length c)]
    forM_ c $ \name -> do
        let newName = path </> name
        isDir <-liftIO . doesDirectoryExist $ newName
        when isDir $ countEntries newName

simple :: Int -> Writer [Int] Int
simple w = do
    Control.Monad.Trans.Writer.tell [10]
    return w

simpleAdd :: Int -> Writer [Int] Int
simpleAdd w = do
    Control.Monad.Trans.Writer.tell [w]
    return w

aCoupleOfSimples :: Writer [Int] Int
aCoupleOfSimples = do
    r1 <- simple 4
    r2 <- simpleAdd r1
    simple 10000


simpleLonger :: Writer [Int] ()
simpleLonger = do
    mapM_ Control.Monad.Trans.Writer.tell $ map (\n -> [n]) [0..10] 

main = do
    c <- countEntriesTrad "."
    print c
    print $ concat $ replicate 10 "="
    c2 <- take 4 `liftM` execWriterT (countEntries "..")
    print c2
    print $ concat $ replicate 10 "="    
    print $ execWriter $ aCoupleOfSimples
    print $ execWriter $ simpleLonger