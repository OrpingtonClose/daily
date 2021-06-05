-- http://learnyouahaskell.com/input-and-output
main = do
    putStrLn "hello what is your name"
    name <- getLine
    putStrLn ("hey " ++ name ++ ", you rock!")
