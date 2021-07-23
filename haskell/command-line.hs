import System.Environment
import System.Directory
import System.IO
import Data.List
import Data.Function
import Data.List
import Text.Read

dispatch :: [(String, [String] -> IO ())]
dispatch = [("add", add)
           ,("view", view)
           ,("bump", bump)
           ,("remove", remove)]

--add s = print  $ ["add"] ++ s
add :: [String] -> IO ()
add (fileName:todoItem) =  appendFile fileName (intercalate " " todoItem & (++) "\n")
--view s = print $ ["view"] ++ s
view :: [String] -> IO ()
view [fileName] = do
        fileContent <- readFile fileName 
        let todos = lines fileContent 
        putStrLn $ unlines $ zipWith (++) ([show i ++ " - " | i <- [1..(length todos)]]) todos
        
bump :: [String] -> IO ()
bump (fileName:i:_) = case readMaybe i :: Maybe Int of (Just index) -> do
                                                         fileContents <- readFile' fileName
                                                         let todos = lines fileContents
                                                         let todosWithout = unlines $ take (index - 1) todos ++ drop index todos
                                              --print todosWithout
                                                         let todoNew = take index todos & last
                                                         let todosNew = todoNew ++ "\n" ++ todosWithout
                                                         writeFile fileName todosNew

remove :: [String] -> IO () 
remove [fileName, item] = do
        fileContents <- readFile' fileName
        let todos = lines fileContents
        let i = read item :: Int
        let todosWithout = unlines $ take (i - 1) todos ++ drop i todos
        let removedItem = take i todos & last
        putStrLn $ "removed item: " ++ removedItem
        writeFile fileName todosWithout
	
        

main = do
        (command:args) <- getArgs
        case lookup command dispatch of Just action -> action args
                                        Nothing -> putStrLn "WRONG ARGS"
	
