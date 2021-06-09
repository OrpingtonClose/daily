module Lib
    ( isPalindrome
    , preprocess
    ) where

import Data.Char (isPunctuation)
import qualified Data.Text as T

--preprocess :: String -> String
preprocess :: T.Text -> T.Text
preprocess = T.filter (not . isPunctuation)

--isPalindrome :: String -> Bool
isPalindrome :: T.Text -> Bool
isPalindrome text = cleanText == T.reverse cleanText
  where cleanText = preprocess text
