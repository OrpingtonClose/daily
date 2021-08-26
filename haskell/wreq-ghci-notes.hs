import Network.Wreq
r <- get "http://httpbin.org/get"
:set -XOverloadedStrings
import Control.Lens
import Data.Aeson.Lens
import Data.Aeson
r ^. responseStatus
r ^. responseStatus . statusCode
--https://www.snoyman.com/blog/2017/05/playing-with-lens-aeson/
import Data.Aeson.Lens (_String, key)
let opts = defaults & param "foo" .~ ["bar", "quux"]
r <- getWith opts "http://httpbin.org/get"
r ^. responseBody . key "url" . _String

r <- get "https://jsonplaceholder.typicode.com/users"
r ^. responseBody
r ^. responseBody^..values.key "id"
r ^. responseBody^..values.key "name"._String

r ^? responseBody . key "fnord"

(view responseBody r) ^..(values.key "id"._Number)


((view responseBody r) ^.. (values)) ^.. ix 2
((view responseBody r) ^.. (values)) ^.. ifolded . asIndex

((view responseBody r) ^.. (values)) ^.. key "id"

(((view responseBody r) ^.. (values)) ^.. folded) ^.. over . key "id"

((view responseBody r) ^.. (values)) ^.. (folding . key "id")

((r ^. responseBody)^..)(values.key "id"._Number)

(r ^. responseBody) 

((r ^. responseBody)^..)(values.key "id"._Number)

((r ^. responseBody)^..)(values.key "id"._Number)

zip (((rr)^..)(values.key "id"._Number)) (((rr)^..)(values.key "name"._String))

import Control.Lens
pair = ("hello, world", '!')
view _1 pair
view _2 pair
pair ^. _1
pair ^. _2

set _1 "bye" pair
_1 .~ "bye" $ pair
pair & _1 .~ "bye"

over _1 length pair
_1 %~ length $ pair
pair & _1 %~ length

view (_2._1) (False, pair)
(False, pair) ^. _2 . _1

points = ("points", [(1, 1), (0, 1), (1, 0)]) :: (String, [(Int, Int)])

toListOf (_2 . folded . _1) points
points ^.. _2 . folded . _1

