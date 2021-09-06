import Data.Queue
 
main = do
    let st = push 15 $ push 10 $ push 5 $ push 0 empty
        st' = pop $ pop st -- 0, 5 <<-- top
        st'' = push 100 st' -- 0, 5, 100 <<-- top
    print $ "top st' == Just 15 -> " ++ show (top st' == Just 15)
    print $ "top st'' == Just 100 -> " ++ show (top st'' == Just 100)
    print $ "isEmpty $ pop $ pop st' -> " ++ show (isEmpty $ pop $ pop st')    
