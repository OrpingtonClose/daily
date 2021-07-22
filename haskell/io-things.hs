import Control.Monad

main = forever $ do 
          putStr "A___"
          getChar 
          {-|when (2 < 1) (putStr "B____" )
          when (2 > 1) (putStr "C______")
          putChar 'a' 
          putChar 'b'
          putChar 'c'
          sequence (map (putStr . show) [1,2,3,4,5])
          mapM (putStr . show) [1,2,3]  
          mapM_ (putStr . show) [1,2,3]
          getChar   
          forM [1..10] (\a -> do
                       print a
                       print a)-}
                   