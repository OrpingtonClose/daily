import {app, BrowserWindow, dialog} from 'electron';
var path = require("path");
//hot module reloading
//hot reload dosen't work...
//require("electron-compile").enableLiveReload({strategy: "react-hmr"});

let mainWindow;

app.on("ready", () => {
    mainWindow = new BrowserWindow({
        width: 300,
        height: 600,
        minWidth: 300,
        minHeight: 300,
        show: false
    });
    mainWindow.loadURL("file://" + path.join(__dirname, 'index.jade'));
    mainWindow.once('ready-to-show', () => {
        mainWindow.show();
    });
});