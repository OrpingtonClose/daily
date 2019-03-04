Chapter 11. Using transpilers and frameworks 

https://learning.oreilly.com/library/view/electron-in-action/9781617294143/kindle_split_021.html

package.json copy pasted from "https://github.com/electron-in-action/jetsetter". the eact compbination to make both scss and jade work is elusive...


electron-rebuild
Electron ships with its own Node runtime, which may or may not be the same version as the Node running on your computer

sqlite3 didn't want to work:
https://stackoverflow.com/questions/38716594/electron-app-cant-find-sqlite3-module#39463304
./node_modules/.bin/electron-rebuild -w sqlite3 -p