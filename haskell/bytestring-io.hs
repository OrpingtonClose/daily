import System.Environment
import qualified Data.ByteStringLazy as B

main = do
    (filename1:filename2:_) <- getArgs
    contents <- B.readFile filename1
    B.writeFile filename2 contents