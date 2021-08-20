{-# LANGUAGE Arrows #-}

import Control.Arrow
import Control.Category
import Prelude hiding (id,(.))

--https://tuttlem.github.io/2014/07/26/practical-arrow-usage.html
main = do
    let a1 = arr (+5)
        a2 = arr (*2)
    print $ "a1 (+5) >>> a2 (*2) $ 3 =>> " ++ (show $ a1 >>> a2 $ 3)
    print $ "a1 (+5) <<< a2 (*2) $ 3 =>> " ++ (show $ a1 <<< a2 $ 3)
    print $ "a1 (+5) &&& a2 (*2) $ 3 =>> " ++ (show $ a1 &&& a2 $ 3)
    print $ "a1 (+5) *** a2 (*2) $ (1,2) =>> " ++ (show $ a1 *** a2 $ (1,2))  
    print $ "first a1 (+5) (1,2) =>> " ++ (show $ first a1 (1,2))
    print $ "second a1 (+5) (1,2) =>> " ++ (show $ second a1 (1,2))
    let a3 = a1 &&& a2
        a4 = a3 *** a3
        a5 = a4 *** a4
        a6 = a5 *** a5
    print $ "a6 $ a5 $ a4 $ a3 3 =>> " ++ (show $ a6 $ a5 $ a4 $ a3 3)