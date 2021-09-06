--https://learning.oreilly.com/library/view/haskell-in-depth/9781617295409/OEBPS/Text/04.htm#heading_id_9
import Data.List
import Data.Deque as D
import Data.Stack as S
import System.TimeIt

fill :: (Num a, Enum a) => a -> (a -> b -> b) -> b -> b
fill n insert s = foldl (flip insert) s [1..n]

--sumAll :: Num a => b -> Maybe a -> (b -> b) -> a
sumAll s view remove = sum $ unfoldr iter s
    where iter s = (view s) >>= \x -> Just (x, remove s)

main :: IO ()
main = do
    let n = 10^7
    timeItNamed "Stack" $ print $ sumAll (fill n push S.empty) top pop
    timeItNamed "Deque" $ print $ sumAll (fill n push_front D.empty) front pop_front