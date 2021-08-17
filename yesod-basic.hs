--https://www.schoolofhaskell.com/school/starting-with-haskell/libraries-and-frameworks/basics-of-yesod/yesod-1
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE OverloadedStrings #-}

import Yesod
import Text.Hamlet (HtmlUrl, hamlet)

data Piggies = Piggies

instance Yesod Piggies

someNumbers :: [String]
someNumbers = ["hellp", "is it me", "your looking for"]

mkYesod "Piggies" [parseRoutes|
  / HomeR GET
  /merp Merp GET
  /about AboutR GET
  /more More GET
|]

getHomeR = defaultLayout [whamlet|
  Welcome to the Pigsty!
  <br>
  <a href=@{AboutR}>About Us.
  <br>
  <a href=@{Merp}>About Us. Merp
  <br>
  <a href=@{More}>About Us. More
  ^{footer}
  |]

--https://www.yesodweb.com/book/shakespearean-templates
--footer :: HtmlUrl Piggies
footer = [whamlet|
<footer>
    <a href=@{HomeR}>Homepage.
|]
{-
myWidget1 = do
    toWidget [hamlet|<h1>My Title|]
    toWidget [lucius|h1 { color: green } |]
-}
{-
footer = do
    toWidget [lucius| footer { font-weight: bold; text-align: center} |]
    toWidget [whamlet|
            <footer>Return to #<a href=@{HomeR}>Homepage.</a>
        |]
-}
getMerp = defaultLayout [whamlet|
  <html>
    <head>
        <title>Hamlet Demo
    <body>
        <h1>Information on John Doe
        $forall person <- someNumbers
            <p>#{person}      
        ^{footer}  
|] 

getAboutR = defaultLayout [whamlet|
  Enough about us!
  <br>
  <a href=@{HomeR}>Back Home.
  ^{footer}
|]

getMore = defaultLayout $ do
    setTitle "My Page Title"
    toWidget [lucius| h1 { color: green; } |]
    addScriptRemote
     "https://ajax.googleapis.com/ajax/libs/jquery/1.6.2/jquery.min.js"
    toWidget
        [julius|
            $(function() {
                $("h1").click(function(){
                    alert("You clicked on the heading!");
                });
            });
        |]
    toWidgetHead
        [hamlet|
            <meta name=keywords content="some sample keywords">
        |]
    toWidget
        [hamlet|
            <h1>Here's one way of including content
        |]
    [whamlet|<h2>Here's another |]
    toWidgetBody
        [julius|
            alert("This is included in the body itself");
        |]

-- main = warpEnv Piggies
main = warpDebug 3000 Piggies