module Main where

import Data.List

createBoard :: Int -> Int -> [[Int]]
createBoard y x = replicate y $ replicate x 0

addAliveStripe :: [Int] -> [[Int]] -> [[Int]]
addAliveStripe [] board = board
addAliveStripe (n:ns) board = addAliveStripe ns 
                            $ (take n board) ++ [( map (const (1 :: Int)) (board !! n) )] ++ (drop (n+1) board)

addAliveAlternatingStripe :: [Int] -> [[Int]] -> [[Int]]
addAliveAlternatingStripe [] board = board
addAliveAlternatingStripe (n:ns) board = addAliveAlternatingStripe ns 
                            $ (take n board) ++ [( take (length (board !! n)) $ map ((flip mod) 2) $ iterate (+1) 0 )] ++ (drop (n+1) board)

printBoard :: [[Int]] -> IO ()
printBoard board = putStrLn $ foldl (\x y -> x ++ (foldl (\z n -> z ++ (show n)) "" y) ++ "\n") "" board

indexOverflow l n = if n < 0 then l - 1 else 
                    if n >= l then 0 else n  
boardIndexed board = map (\(x,y) -> (x, [0..((length y)-1)])) $ zip (take ((length (board !! 0)) ) $ iterate (+1) 0) board

transformBoard surviveRules bornRules 
               boardStart = boardCollapsed boardStart $ boardIndexed boardStart
                where indexRowOverflow = indexOverflow $ length boardStart
                      indexColumnOverflow = indexOverflow $ length $ head boardStart                                              
                      boardCollapsed board boardIndex = map (\(x,y) -> 
                                                        map (\z -> ( 
                                                          let neighbourhoodSum = board !! (indexRowOverflow (x + 1)) !! (indexColumnOverflow (z + 1)) + 
                                                                                 board !! (indexRowOverflow (x + 1)) !! (indexColumnOverflow (z - 1)) + 
                                                                                 board !! (indexRowOverflow (x + 1)) !! (indexColumnOverflow z) + 
                                                                                 board !! (indexRowOverflow (x - 1)) !! (indexColumnOverflow (z + 1)) + 
                                                                                 board !! (indexRowOverflow (x - 1)) !! (indexColumnOverflow (z - 1)) + 
                                                                                 board !! (indexRowOverflow (x - 1)) !! (indexColumnOverflow z) + 
                                                                                 board !! (indexRowOverflow x) !! (indexColumnOverflow (z + 1)) +                                                                                                                                                                                                                                                                                                                                                             
                                                                                 board !! (indexRowOverflow x) !! (indexColumnOverflow (z - 1)) 
                                                              initState = board !! x !! z 
                                                              in if (initState == 1) && (elem neighbourhoodSum surviveRules) 
                                                                 then 1
                                                                 else if (initState == 0) && (elem neighbourhoodSum bornRules)
                                                                      then 1
                                                                      else 0
                                                          )) y) $ boardIndexed board

process :: [[Int]] -> IO ()
process boardStart = do
  printBoard boardStart
  putStrLn "continue by pressing enter"
  line <- getLine
  if null line
  then do
    let board = transformBoard [1, 3, 6] [1, 2, 3] boardStart
    printBoard board
    process board
  else return ()

main :: IO ()
main = process $ addAliveStripe [13,14] $ addAliveAlternatingStripe [10,11,12,15] $ createBoard 30 80

