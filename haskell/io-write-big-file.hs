import System.IO
import Control.Monad

main = do
    withFile "herp.txt" WriteMode (\handle -> 
--        mapM_ (hPutStrLn handle (concat $ map (concat . (replicate 145) . show) [1..9]))) [1..1000]
        forM [1..1000] (\_ -> 
            mapM_ (hPutStrLn handle) (map (concat . (replicate 145) . show) [1..999])))