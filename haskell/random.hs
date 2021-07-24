import System.Random
import Text.Read

randomStream :: [Int]
randomStream = map (((flip mod) 2) . fst)  $ scanl (\(_,gen) y -> random gen ) (random (mkStdGen 100)) [1..]

threeCoins :: StdGen -> (Bool, Bool, Bool)
threeCoins gen =
    let (firstCoin, newGen) = random gen
        (secondCoin, newGen') = random newGen
        (thirdCoin, newGen'') = random newGen'
    in (firstCoin, secondCoin, thirdCoin)

askForNumber :: StdGen -> IO ()
askForNumber gen = do
    let (findThis, newGen) = randomR (1,10) gen
    let failure = do  
                     putStrLn "Nope, try Again"
                     askForNumber newGen
    putStrLn "Guess a number from 1 to 10"
    guess <- getLine
    case (readMaybe guess :: Maybe Int) of Nothing -> failure
                                           Just i ->  if i == findThis then putStrLn "You win!" else failure
    -- where failure = do  putStrLn "Nope, try Again"
    --                     askForNumber newGen


main = do
    print $ (random (mkStdGen 100) :: (Int, StdGen) )    
    print $ take 100 $ randomStream
    print $ threeCoins (mkStdGen 100)
    print $ (take 10 $ randoms (mkStdGen 100) :: [Int])
    print $ (take 10 $ randoms (mkStdGen 100) :: [Bool])
    print $ (take 10 $ randoms (mkStdGen 100) :: [Float])
    print $ (randomR (1 ::Int,6::Int) (mkStdGen 359353) )
    print $ take 10 $ (randomRs ('a', 'z') (mkStdGen 3) :: [Char])
    gen1 <- getStdGen
    print $ (take 10 $ randoms gen1 :: [Bool])
    gen2 <- getStdGen
    print $ (take 10 $ randoms gen2 :: [Bool])
    gen3 <- newStdGen
    print $ (take 10 $ randoms gen3 :: [Bool])
    print $ (take 10 $ randoms gen1 :: [Bool]) 
    askForNumber gen3
