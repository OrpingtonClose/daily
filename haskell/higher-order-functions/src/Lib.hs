{-# LANGUAGE TemplateHaskell #-}
-- http://learnyouahaskell.com/higher-order-functions

module Lib
    ( someFunc
    ) where

import Debug.Trace
--import Language.Haskell.TH

fib :: Int -> Int 
fib 0 = trace ("n: 0") 0
fib 1 = trace ("n: 1") 1
fib n = trace ("n: " ++ show n) $ fib (n - 1) + fib (n - 2)


factorial :: Int -> Int
factorial n | n == 0    = trace ("branch 1") 1
            | otherwise = trace ("branch 2") $ n * (factorial $ n - 1)

factorial' :: Int -> Int
factorial' n | n == 0    = 1
            | otherwise = n * (factorial' $ n - 1)

mulThree :: (Show a, Num a) => a -> a -> a -> a
mulThree a b c = trace (show a ++ " " ++ show b ++ " " ++ show c) $ a * b * c
mulTwo :: Integer -> Integer -> Integer
mulTwo = mulThree 3
mulOne = mulTwo 7

applyTwice :: (a -> a) -> a -> a
applyTwice f a = f $ f a

zipWith' :: (a -> b -> c) -> [a] -> [b] -> [c]
zipWith' _ _ [] = []
zipWith' _ [] _ = []
zipWith' f (x:xs) (y:ys) = (f x y) : zipWith' f xs ys

flip :: (a -> b -> c) -> (b -> a -> c)
flip f = g
    where g x y = f y x

flip' :: (a -> b -> c) -> (b -> a -> c)
flip' f x y = f y x

chain :: (Integral a) => a -> [a]
chain 1 = [1]
chain n
     | even n = n:chain (n `div` 2)
     | odd n = n:chain (n*3 + 1)

elem' :: (Eq a) => a -> [a] -> Bool
elem' y ys = foldl (\acc x -> if acc || x == y then True else False) False ys


elemIndex :: (Eq a) => a -> [a] -> Int
elemIndex i xs = (length $ filter (\x -> not x) $ ( scanl (\acc x -> acc || x == i) False xs )) - 1

map' :: (a -> b) -> [a] -> [b]
map' f xs = foldr (\x acc -> f x:acc) [] xs

oddSquareSum = sum (takeWhile (<10000) (filter odd (map (^2) [1..])))
oddSquareSum' = sum . takeWhile (<10000) . filter odd . map (^2) $ [1..]
oddSquareSum'' = let oddSquares = filter odd $ map (^2) [1..]
                     belowStandard = takeWhile (<10000) oddSquares
                 in sum belowStandard

someFunc :: IO ()
someFunc = do
    putStrLn $ "factorial 6: " ++ show (factorial 6)
    putStrLn $ replicate 10 '='
    putStrLn $ "factorial 6: " ++ show (factorial' 6)
    putStrLn $ replicate 10 '='
    putStrLn $ show (fib 6)
    putStrLn $ replicate 10 '='
    putStrLn $ trace ("mulOne") show (mulOne 6)
    putStrLn $ trace ("applyTwice") show (applyTwice (+3) 0)
    putStrLn $ applyTwice ("dddd" ++) "DDD"
    putStrLn $ show $ applyTwice (3:) (1:[])
    putStrLn $ show $ zipWith' (*) [1, 5, 4] [6, 6, 6]
    putStrLn $ show $ zipWith' max [1..10] (reverse [1..10])
    putStrLn $ replicate 10 '='
    putStrLn $ show $ map (+3) [1..4]
    putStrLn $ show $ map ((++ "d") . (\c -> [c])) (['a'..'n'])
    putStrLn $ show $ map (replicate 4) [1..4]
    putStrLn $ show $ map (map (^2)) [[1..4], [1..5], [1..9]]
    putStrLn $ show $ map fst [(1, 4), (5, 3), (4, 5)]
    putStrLn $ show $ filter (`elem` ['a'..'z']) "AbCdEfGh"
    putStrLn $ show $ filter (`elem` ['A'..'Z']) "AbCdEfGh"
    putStrLn $ show $ filter (not . null) [[], [3, 4], []]
    putStrLn $ show $ filter even [1..10]
    putStrLn $ show $ sum $ takeWhile (<10000) $ filter odd $ map (^2) [1..1000]
    putStrLn $ show $ take 4 $ filter (\x -> x `mod` 3829 == 0) [100000,99999..0]
    putStrLn $ replicate 10 '='
    putStrLn $ show $ chain 10
    putStrLn $ show $ chain 1
    putStrLn $ show $ chain 30
    print "loner than 15"
    putStrLn $ show $ length $ filter (\xs -> length xs > 15 ) $ map chain [1..100]
    putStrLn $ show $ (map (*) [0..10] !! 6) 4
    putStrLn $ show $ foldl (\acc y -> acc + y) 0 [1..10]
    putStrLn $ show $ foldl (\x y -> if x > y then x else y) 0 [1..100]
    print "function application"
    putStrLn $ show $ map ($ 3) [(4+), (10*), (^2), sqrt]
