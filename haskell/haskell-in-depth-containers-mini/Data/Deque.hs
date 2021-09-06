{-# LANGUAGE NoImplicitPrelude #-}
module Data.Deque (Deque, 
                    empty, 
                    isEmpty, 
                    front, 
                    back, 
                    push_back, 
                    push_front, 
                    pop_back, 
                    pop_front) where

import Data.Sequence hiding (empty)
import qualified Data.Sequence as Seq
import Data.Bool (Bool)
import Data.Maybe (Maybe(..))
import qualified Prelude (Show, show)
import Data.List ((++))

newtype Deque a = Deque (Seq a)
instance (Prelude.Show a) => Prelude.Show (Deque a) where
    show (Deque Empty) = "Nothing!"
    show (Deque (x :<| s)) = (Prelude.show x) ++ " ooo " ++ (Prelude.show s) 

empty :: Deque a
empty = Deque Seq.empty

isEmpty :: Deque a -> Bool
isEmpty (Deque s) = null s

front :: Deque a -> Maybe a
front (Deque s) = case viewl s of
                    EmptyL -> Nothing
                    (a :< s) -> Just a

back :: Deque a -> Maybe a
back (Deque s) = case viewr s of
                    EmptyR -> Nothing
                    (s :> a) -> Just a

push_front :: a -> Deque a -> Deque a
push_front x (Deque s) = (Deque (x <| s))

push_back :: a -> Deque a -> Deque a
push_back x (Deque s) = (Deque (s |> x))

pop_front :: Deque a -> Deque a
pop_front (Deque (x :<| s)) = Deque s 

pop_back :: Deque a -> Deque a
pop_back (Deque (s :|> x)) = Deque s