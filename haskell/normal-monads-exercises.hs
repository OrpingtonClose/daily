module Main where

import Text.Read (readMaybe)
import Control.Monad

main :: IO ()
main = do
    putStrLn $ show $ foo "44" "44" "45" 
    putStrLn $ show $ foo' "44" "44" "4__5"  --bar --putStrLn "Hello, Haskell!"
    putStrLn $ show $ foo' "44" "44" "45"
    print $ (readEither "55" :: Either String Int)
    print $ (readEither "5__5" :: Either String Int)
    putStrLn $ show $ foo'' "44" "44" "45"
    putStrLn $ show $ foo'' "44" "44" "4__5"
    putStrLn $ show $ foo'' "4OOOOO4" "44" "4__5"    
    putStrLn $ show $ foo''' "44" "44" "45"
    putStrLn $ show $ foo''' "44" "44" "4__5"
    putStrLn $ show $ foo''' "4OOOOO4" "44" "4__5"    
    print $ wfoo (number 0) (number 1) (wfoo (number 3) (number 4) (number 5))
    print $ wfoo' (number 0) (number 1) (wfoo (number 3) (number 4) (number 5))
    print $ threeInts (number 0) (number 1) (threeInts (number 3) (number 4) (number 5))

bar :: IO ()
bar = getLine >>= \s -> getLine >>= \t -> putStrLn (s ++ t)

foo :: String -> String -> String -> Maybe Int
foo x y z = case readMaybe x of 
    Nothing -> Nothing
    Just k -> case readMaybe y of
        Nothing -> Nothing
        Just l -> case readMaybe z of
            Nothing -> Nothing
            Just m -> Just (k + l + m)

bindMaybe :: Maybe a -> (a -> Maybe b) -> Maybe b
bindMaybe Nothing _ = Nothing
bindMaybe (Just x) f = f x

foo' :: String -> String -> String -> Maybe Int
foo' x y z = readMaybe x `bindMaybe` \k -> 
             readMaybe y `bindMaybe` \l ->
             readMaybe z `bindMaybe` \m ->
             Just (k + l + m)

readEither :: Read a => String -> Either String a
readEither s = case readMaybe s of 
    Nothing -> Left $ "Can't parse :" ++ s
    Just a -> Right a

foo'' :: String -> String -> String -> Either String Int
foo'' x y z = case readEither x of 
    Left err -> Left err
    Right k -> case readEither y of
        Left err -> Left err
        Right l -> case readEither z of
            Left err -> Left err
            Right m -> Right (k + l + m)


bindEither :: Either String a -> (a -> Either String b) -> Either String b
bindEither (Left err) _ = Left err
bindEither (Right x) f = f x

foo''' :: String -> String -> String -> Either String Int
foo''' x y z = readEither x `bindEither` \k ->  
               readEither y `bindEither` \l ->
               readEither z `bindEither` \m ->
               Right (k + l + m)

data Writer a = Writer a [String] deriving Show

number :: Int -> Writer Int
number n = Writer n $ ["number: " ++ show n]

tell :: [String] -> Writer ()
tell = Writer ()

wfoo :: Writer Int -> Writer Int -> Writer Int -> Writer Int
wfoo (Writer k xs) (Writer l ys) (Writer m zs) = 
    let s = k + l + m
        Writer _ us = tell ["sum: " ++ show s]
    in Writer s $ xs ++ ys ++ zs ++ us

bindWriter :: Writer a -> (a -> Writer b) -> Writer b
bindWriter (Writer a xs) f = 
    let Writer b ys = f a
    in Writer b $ xs ++ ys

wfoo' :: Writer Int -> Writer Int -> Writer Int -> Writer Int
wfoo' x y z = x `bindWriter` \a ->
              y `bindWriter` \b ->
              z `bindWriter` \c -> 
              let s = a + b + c
              in tell ["sum: " ++ show s] `bindWriter` \_ -> 
                  Writer s []

--app :: (a -> a) -> [a] -> a
--app _ [] = []
--app f [a] = f a
--app f (x:xs) = app (f x) xs

instance Functor Writer where
    fmap = liftM

instance Applicative Writer where
    pure = return
    (<*>) = ap 

instance Monad Writer where
    return a = Writer a [] 
    (>>=) = bindWriter

threeInts :: Monad m => m Int -> m Int -> m Int -> m Int
threeInts mx my mz = 
    mx >>= \k -> 
    my >>= \l ->
    mz >>= \m ->
    let s = k + l + m in return s      