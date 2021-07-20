{-|
main = putStrLn "hello what is your name?" >> 
       getLine >>= \name ->
       (putStrLn $ concat $ ["Hey ", name, ", you rock"]) >>
       getLine >>= \n1 ->
       getLine >>= \n2 ->
       putStrLn $ concat $ ["<<<", n1, n2, ">>>"]
-}
{-|
main = do putStrLn "hello what is your name?"
          name <- getLine
          let message = concat ["Hey ", name, ", you rock"]
          putStrLn message
          n1 <- getLine
          n2 <- getLine
          putStrLn (concat $ ["<<<", n1, n2, ">>>"])
-}
main = putStrLn "hello what is your name?" >> getLine >>= \name -> (putStrLn $ concat $ ["Hey ", name, ", you rock"]) >> getLine >>= \n1 -> getLine >>= \n2 -> putStrLn $ concat $ ["<<<", n1, n2, ">>>"]