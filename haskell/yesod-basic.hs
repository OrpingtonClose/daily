--https://www.schoolofhaskell.com/school/starting-with-haskell/libraries-and-frameworks/basics-of-yesod/yesod-1
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE OverloadedStrings #-}

import Yesod
import Text.Hamlet (HtmlUrl, hamlet)

data Piggies = Piggies

--instance Yesod Piggies

--myLayout :: Widget -> Handler Html
myLayout widget = do
    pc <- widgetToPageContent widget
    withUrlRenderer
        [hamlet|
            $doctype 5
            <html>
                <head>
                    <title>#{pageTitle pc}
                    <meta charset=utf-8>
                    <style>body { font-family: verdana }
                    ^{pageHead pc}
                <body>
                    <article>
                        <br>
                        ^{pageBody pc}
                        <img src="https://img.webmd.com/dtmcms/live/webmd/consumer_assets/site_images/article_thumbnails/slideshows/is_my_cat_normal_slideshow/1800x1200_is_my_cat_normal_slideshow.jpg" alt="Girl in a jacket" width="100" height="100">                         
        |]

instance Yesod Piggies where
    defaultLayout = myLayout

someNumbers :: [String]
someNumbers = ["hellp", "is it me", "your looking for"]

mkYesod "Piggies" [parseRoutes|
  / HomeR GET
  /merp Merp GET
  /about AboutR GET
  /more More GET
  /wid Wid GET
  /trad Trade GET
|]
{-
footer = [whamlet|
<footer>
    <a href=@{HomeR}>Homepage.
|]
-}
--https://www.tradingview.com/widget/advanced-chart/

tradingViewTest :: String -> WidgetFor Piggies ()
tradingViewTest what = do
    toWidget [whamlet|
        <div style="display: inline-block; width: 200px;" class="tradingview-widget-container">
            <div id="tradingview_81874">
            <!-- <div class="tradingview-widget-copyright">
                <a href="https://www.tradingview.com/symbols/XBTUSDT/?exchange=KRAKEN" rel="noopener" target="_blank">
                    <span class="blue-text">XBTUSDT Chart
                by TradingView -->
            <script type="text/javascript" src="https://s3.tradingview.com/tv.js">
            <script type="text/javascript">
                new TradingView.widget(
                {
                    "width": 200,
                    "height": 200,
                    "symbol": "#{what}",
                    "interval": "D",
                    "timezone": "Etc/UTC",
                    "theme": "light",
                    "style": "1",
                    "locale": "en",
                    "toolbar_bg": "#f1f3f6",
                    "enable_publishing": false,
                    "hide_top_toolbar": true,
                    "hide_legend": true,
                    "save_image": false,
                    "container_id": "tradingview_483d8"
                }
                );            
    |]

myWidget1 :: WidgetFor Piggies ()
myWidget1 = do
    toWidget [whamlet|
            <h1>WIDGET HERE HEHE
        |]
    toWidget [lucius|h1 { color: green } |]


footer :: WidgetFor Piggies ()
footer = do
    toWidget [lucius| footer { font-weight: bold; text-align: center} |]
    toWidget [whamlet|
            <footer>Return to #<a href=@{HomeR}>Homepage.</a>
        |]
    myWidget1

--https://api.kraken.com/0/public/Assets
tickers :: [String]
tickers = ["1INCH","XBT","ADA","LINK"] ++ [
  "1INCH",
  "AAVE",
  "ADA",
  "ALGO",
  "ANKR",
  "ANT",
  "ATOM",
  "AXS",
  "BADGER",
  "BAL",
  "BAND"]
charts :: [String]
charts = (\s -> "KRAKEN:" ++ s ++ "USD") <$> tickers

getTrade :: HandlerFor Piggies Html
getTrade = defaultLayout $ do
    mapM_ tradingViewTest charts


getWid :: HandlerFor Piggies Html
getWid = defaultLayout footer

getHomeR :: HandlerFor Piggies Html
getHomeR = defaultLayout [whamlet|
  Welcome to the Pigsty!
  <br>
  <a href=@{AboutR}>About Us.
  <br>
  <a href=@{Merp}>About Us. Merp
  <br>
  <a href=@{More}>About Us. More
  <br>
  <a href=@{Wid}>About Us. Wid
  <br>
  <a href=@{Trade}>About Us. Wid
  ^{footer}
  |]

--https://www.yesodweb.com/book/shakespearean-templates
--footer :: HtmlUrl Piggies


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
