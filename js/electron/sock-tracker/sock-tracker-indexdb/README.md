Chapter 12. Persisting

https://www.oreilly.com/library/view/electron-in-action/9781617294143/kindle_split_022.html

electron-rebuild
Electron ships with its own Node runtime, which may or may not be the same version as the Node running on your computer

sqlite3 didn't want to work:
https://stackoverflow.com/questions/38716594/electron-app-cant-find-sqlite3-module#39463304
./node_modules/.bin/electron-rebuild -w sqlite3 -p