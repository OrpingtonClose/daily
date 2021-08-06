{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE InstanceSigs #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}

class VarArgs r s where
  type F r s
  f :: r -> s -> F r s

instance VarArgs r s => VarArgs (Int -> r) s where
  type F (Int -> r) s = Int -> F r s
  f :: (Int -> r) -> s -> Int -> F r s
  f a b x = f (a x) b

instance VarArgs Int s => VarArgs Int (Int -> s) where
  type F Int (Int -> s) = Int -> F Int s
  f :: Int -> (Int -> s) -> Int -> F Int s
  f a b x = f a (b x)

instance VarArgs Int Int where
  type F Int Int = Int
  f :: Int -> Int -> Int
  f a b = a + b

times2 :: Int -> Int -> Int
times2 x y = x * y
times3 :: Int -> Int -> Int -> Int
times3 x y z = x * y * z

foo :: [Int]
foo = [ f times2 times2 1 2 3 4
      , f times2 times3 1 2 3 4 5
      , f times3 times2 1 2 3 4 5
      , f times3 times3 1 2 3 4 5 6]

main = print foo