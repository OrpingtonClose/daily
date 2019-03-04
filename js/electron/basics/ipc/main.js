var {app, BrowserWindow, ipcMain} = require("electron");
var {join} = require("path");
let mainWindow;
ipcMain.on("custom-time-send", (event, arg) => {
    mainWindow.setTitle(arg);
});
app.on("ready", () => {
    mainWindow = new BrowserWindow({width: 800, height: 600});//, title: "merp"});
    mainWindow.loadURL("file://" + join(__dirname, "index.html"));
});