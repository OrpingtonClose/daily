import qualified Data.Map

data Point = Point Float Float deriving (Show)
data Shape = Circle Point Float | Rectangle Point Point deriving (Show)
surface :: Shape -> Float
surface (Circle (Point x1 y1) r) = 3.14 * r ^ 2
surface (Rectangle (Point x1 y1) (Point x2 y2)) = (abs $ x2 - x1) * (abs $ y2 - y1)

nudge :: Shape -> Float -> Float -> Shape
nudge (Circle (Point x1 y1) r) x2 y2 = Circle (Point (x1+x2) (y1+y2) ) r
nudge (Rectangle (Point x1 y1) p) x3 y3 = Rectangle (Point (x1+x3) (y1+y3)) p 

data Herp = Merp | Twerp | Srerp deriving (Show, Eq, Ord)
data Day = Monday | Tuesday | Wednesday | Thursday | Friday | Saturday | Sunday  deriving (Eq, Ord, Show, Read, Bounded, Enum)

type PhoneNumber = String
type Name = String
type Phonebook = [(Name, PhoneNumber)]
phoneBook :: Phonebook
phoneBook =      
    [("betty","555-2938")     
    ,("bonnie","452-2928")     
    ,("patsy","493-2928")     
    ,("lucille","205-2928")     
    ,("wendy","939-8282")     
    ,("penny","853-2492")     
    ]

inPhoneBook :: Name -> PhoneNumber -> Phonebook -> Bool
inPhoneBook name pnumber pbook = (name,pnumber) `elem` pbook
type AssocList k v = [(k,v)]

type IntMap = Data.Map.Map Int

data LockerState = Taken | Free deriving (Show, Eq)
type Code = String
type LockerMap = Data.Map.Map Int (LockerState, Code)

lockerLookup :: Int -> LockerMap -> Either String Code
lockerLookup n lockerMap = case Data.Map.lookup n lockerMap of
                           Nothing -> Left $ "Locker number " ++ show n ++ " doesn't exist!"
                           Just (state, code) -> if state /= Taken then Right code else Left $ "Locker " ++ show n ++ " is taken"
lockers :: LockerMap
lockers = Data.Map.fromList 
    [(100,(Taken,"ZD39I"))  
    ,(101,(Free,"JAH3I"))  
    ,(103,(Free,"IQSA9"))  
    ,(105,(Free,"QOTSA"))  
    ,(109,(Taken,"893JJ"))  
    ,(110,(Taken,"99292"))  
    ]  
ll :: Int -> Either String Code
ll n = lockerLookup n lockers

--infixr 5 :-:
data List a = EmptyList | Cons a (List a) deriving (Show, Read, Eq, Ord)

infixr 5 :-:
data List' a = EmptyList' | a :-: (List' a) deriving (Show, Read, Eq, Ord)

infixr 5 .++
(.++) :: List' a -> List' a -> List' a
EmptyList' .++ ys = ys
(x :-: xs) .++ ys = x :-: (xs .++ ys)

main = do
--    putStrLn $ ([(*7),(+9)] <*> [1..8])
    let rec = nudge (Rectangle (Point 0.0 0.0) (Point 100.0 100.0))
        
    putStrLn $ show $ nudge (Rectangle (Point 0.0 0.0) (Point 100.0 100.0)) (100::Float) (100::Float)
    putStrLn $ show $ nudge (Circle (Point 0 0) 24) (100::Float) (100::Float)
    putStrLn $ show (Merp > Srerp) 
    putStrLn $ show (Merp `compare` Srerp)
    putStrLn $ show (minBound :: Day)
    putStrLn $ show (maxBound :: Day)
    putStrLn $ show $ succ Monday
    putStrLn $ show $ pred Saturday
    putStrLn $ show [Thursday .. Sunday]
    putStrLn $ show ([minBound .. maxBound] :: [Day])
    putStrLn $ show $ ll 101
    putStrLn $ show $ ll 100
    putStrLn $ show $ ll 102
    putStrLn $ show $ ll 110
    putStrLn $ show $ ll 105
    --print EmptyList
    putStrLn $ show $ Cons 5 EmptyList
    putStrLn $ show $ 4 `Cons` (5 `Cons` EmptyList)
    putStrLn $ show $ Cons 40111 $ Cons 4 $ Cons 43 $ Cons 44 $ Cons 40 $ Cons 4 (5 `Cons` EmptyList)
    putStrLn $ show $ 40111 :-: 4 :-: 43 :-:  44 :-:  40 :-:  4 :-: 5 :-:  EmptyList'
    putStrLn $ show $ (5 :-:  EmptyList') .++ (5 :-:  EmptyList')
