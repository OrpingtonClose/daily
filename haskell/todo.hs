import System.IO
import System.Directory
import Control.Monad
import Data.Char

createTodos = do 
        print "todo file not exists, creating"
        withFile "todo.txt" WriteMode (\h -> do 
            mapM_ (hPutStrLn h) ["do a herp", "merp around", "do the dishes"] 
            )

getTodosOrdered todos = map (\(a, b) -> concat [a," - ", b]) $ zip (map show [0..(length $ lines todos)]) (lines todos)

deleteTodo o todo = do
    let toWrite = unlines $ (\(f,s) -> init f ++ s) $ splitAt o todo
    when ((length todo) > o) (withFile "todo.txt" WriteMode (\h -> hPutStr h toWrite))

addTodo todo = do
    withFile "todo.txt" AppendMode (\h -> hPutStrLn h todo)

main = do
    does <- doesFileExist "todo.txt"
    when (not does) createTodos 
    todos <- readFile' "todo.txt"
    when (todos == "") createTodos
    todosAgain <- readFile' "todo.txt"
    putStrLn $ unlines $ getTodosOrdered todosAgain
    putStrLn "which one do you wish to delete? to add write text"
    p <- getLine
    putStrLn ""
    case p of "" -> putStrLn "doing Nothing"
              t -> do
                    if (all isDigit t) 
                        then (deleteTodo (read t :: Int) $ lines todosAgain)
                        else addTodo t
                    main
              
              

    -- handle <- openFile "todo.txt" ReadMode
    -- (tempName,tempHandle) <- openTempFile "." "temp"
    -- contents <- hGetContents handle
    -- withFile "todo.txt" (\h -> do
    --     hSetBuffering h $ BlockBuffering (Just 2048)
    --     c <- hGetContent h
    --     putStr c
    --     )
--    todoItem <- getLine
--    appendFile "todo.txt" (todoItem ++ "\n")
    