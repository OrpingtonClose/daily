const electron = require("electron");
const path = require("path");
electron.dialog.showErrorBox("Not ok", "Something happened - one");

var win = null;

electron.app.on("ready", () => {
    electron.dialog.showErrorBox("Not ok", "Something happened - two");
    win = new electron.BrowserWindow({width: 200, height: 400});
    win.loadURL(`file://${path.join(__dirname, "index.html")}`);
});

electron.app.on("window-all-closed", electron.app.quit);