module Data.Queue (Queue, empty, isEmpty, push, pop, top) where
import Data.Deque hiding (empty, isEmpty)
import qualified Data.Deque as D

newtype Queue a = Queue (Deque a) deriving (Show)

empty :: Queue a
empty = Queue D.empty

push :: a -> Queue a -> Queue a
push y (Queue d) = Queue (push_front y d) 

isEmpty :: Queue a -> Bool
isEmpty (Queue d) = D.isEmpty d

pop :: Queue a -> Queue a
pop (Queue d) = Queue (pop_back d)

top :: Queue a -> Maybe a
top (Queue d) = front d