var electron = require("electron");
var path = require("path");
let win;
electron.app.on("ready", () => {
    win = new electron.BrowserWindow({height:200, width: 200});
    win.loadURL("file://" + path.join(__dirname, "index.html"));
});
electron.app.on("window-all-closed", electron.app.quit);