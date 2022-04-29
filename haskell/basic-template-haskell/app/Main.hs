{-# LANGUAGE TemplateHaskell #-}

module Main where

import Lib
import Language.Haskell.TH

two :: Int
two = $(pure myExp) + $(pure myExp)

-- n = 1
-- $(pure [myDec])

f :: (Int, Int) -> String
f $(pure myPat) = "1 and 1"
f _        = "something else"

mint :: $(pure myType)
mint = Just two

main :: IO ()
main = print $ show mint
