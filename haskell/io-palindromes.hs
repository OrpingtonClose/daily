main = interact respondPalindromes

respondPalindromes :: String -> String
respondPalindromes contents = unlines (map (\xs -> 
    if isPalindrome xs then "palindrome" else "not a palindrome" ) (lines contents))
    where isPalindrome xs = xs == reverse xs
