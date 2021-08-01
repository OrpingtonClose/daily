{-# LANGUAGE RankNTypes #-}
--https://scrapbox.io/haskell-and-crypto/RankNTypes

--foo :: ([a] -> Int) -> Int
--foo f = f [1,2,3] + f "string"  -- error
{- In this case, ([a] -> Int) 
seems like it's a polymorphic function since it 
takes type variable a as an argument. 
But when you run it in standard Haskell, 
a will be infered as Int or Char therefore 
will not be polymorphic
-}
data Herp = Merp | Twerp | Muueheherp

foo' :: (forall a . [a] -> Int) -> Int
foo' f = f [1,2,3] + f "string" + f [Merp,Merp,Muueheherp]

--ghci> foo' length
--9
{- This will compile since we're explicitly 
telling Haskell that function ([a] -> Int) 
is polymorphic
-}

main = do
    print $ foo' length
    print $ foo' length