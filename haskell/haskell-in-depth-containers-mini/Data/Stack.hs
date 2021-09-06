module Data.Stack (Stack, empty, isEmpty, push, pop, top) where

newtype Stack a = Stack [a] deriving (Show)

empty :: Stack a
empty = Stack []

push :: a -> Stack a -> Stack a
push y (Stack []) = Stack (y:[]) 
push y (Stack (x:xs)) = Stack (y:x:xs) 

isEmpty :: Stack a -> Bool
isEmpty (Stack x) = null x

pop :: Stack a -> Stack a
pop (Stack (x:xs)) = Stack xs

top :: Stack a -> Maybe a
top (Stack []) = Nothing
top (Stack (x:_)) = Just x