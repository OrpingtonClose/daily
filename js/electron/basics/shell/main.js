var electron = require("electron");
var path = require("path");
let win;
electron.app.on("ready", ()=>{
    var tray = new electron.Tray(path.join(__dirname, "myapp.png"));
    tray.setToolTip("my application");
    var sites = {
        "ddg": "https://ddg.gg",
        "google": "https://google.com",
        "cnn": "https://cnn.com"
    };
    var labels = [];
    for (key in sites) {
        labels.push({
            type:"normal", 
            label: key, 
            click: () => {electron.shell.openExternal(sites[key])}});
    }
    var trayMenu = electron.Menu.buildFromTemplate(labels);
    win = new electron.BrowserWindow({height:200, width: 200});
    win.loadURL("file://" + path.join(__dirname, "index.html"));
    tray.setContextMenu(trayMenu);
    electron.ipcMain.on("ready-manual", () => {
        electron.dialog.showErrorBox("file", path.join(__dirname, "mouse.png"));
        win.webContents.send("file-to-operate-on", path.join(__dirname, "mouse.png"))
    });
    electron.ipcMain.on("status", (event, arg) => {
        win.setTitle(arg || "shell");
    });
});
electron.app.on("window-all-closed", electron.app.quit);