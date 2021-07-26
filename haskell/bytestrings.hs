import qualified Data.ByteString.Lazy as L
import qualified Data.ByteString as S
import Data.Function
import Data.List

main = do
    print $ L.pack [99,100,101]
    print $ S.unpack $ S.pack [99,100,101]
    print $ S.pack [300..400]
    print $ L.fromChunks [S.pack [39,40,41], S.pack [42,43,44], S.pack [45,46,47]] 
    print $ L.fromChunks $ S.pack <$> groupBy ((==) `on` flip div 3) [39..47]
    print $ L.cons 85 $ L.pack [80,81,82,84] 
    print $ S.cons 85 $ S.pack [80,81,82,84] 