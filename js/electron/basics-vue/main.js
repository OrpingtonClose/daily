var electron = require("electron");
var path = require("path");
var win;

electron.app.on("ready", ()=>{
    win = new electron.BrowserWindow({width: 600, height:800});
    win.loadURL("file://" + path.join(__dirname, "index.html"));
});
electron.app.on("window-all-closed", electron.app.quit);