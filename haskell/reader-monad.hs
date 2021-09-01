--https://blog.ssanj.net/posts/2014-09-23-A-Simple-Reader-Monad-Example.html
import Control.Monad.Reader

tom :: Reader String String
tom = do
    env <- ask -- gives you the environment which in this case is a String
    return (env ++ " This is Tom.")

jerry :: Reader String String
jerry = do
  env <- ask
  return (env ++ " This is Jerry.")

tomAndJerry :: Reader String String
tomAndJerry = do
    t <- tom
    j <- jerry
    return (t ++ "\n" ++ j)

runJerryRun :: String
runJerryRun = (runReader tomAndJerry) "Who is this?"

noJerryRun :: String
noJerryRun = (runReader tomAndJerry) " Herp "
