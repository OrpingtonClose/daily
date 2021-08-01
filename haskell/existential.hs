{-# LANGUAGE ExistentialQuantification, StandaloneDeriving #-}

--https://learning.oreilly.com/library/view/haskell-cookbook/9781786461353/75cb39b1-fb4a-4719-84ad-ffe0f7cc3679.xhtml

module Main where
--ExistentialQuantification
data Display = forall a . Show a => Display a
--data Display = forall a. Display a

--StandaloneDeriving
deriving instance Show Display 

displayList :: [Display]
displayList = [ Display 10
              , Display ["One","Two","Three"]
              , Display 10.0
              , Display (Just "Something")
              , Display True ]

main :: IO ()
main = do
   putStrLn "Printing heterogenous showable list"
   mapM_ print displayList