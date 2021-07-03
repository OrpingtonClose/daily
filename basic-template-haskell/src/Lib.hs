{-# LANGUAGE TemplateHaskell #-}
module Lib  where

import Language.Haskell.TH

myExp :: Exp
myExp = LitE (IntegerL 1)

-- Declaration: n = 1
-- myDec :: Dec
-- myDec = ValD (VarP (mkName"n")) (NormalBmyExp) []

-- Pattern: (1, 2)
myPat :: Pat
myPat = TupP [LitP (IntegerL 1), LitP (IntegerL 2)]

-- Type: Maybe Int
myType :: Type
myType = AppT (ConT (mkName"Maybe")) (ConT (mkName"Int"))

someFunc :: IO ()
someFunc = print "hello"
