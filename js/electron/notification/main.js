var electron = require("electron");
var path = require("path");
let win = null;
let ipcRenderer;
electron.app.on("ready", () => {
    win = new electron.BrowserWindow({width: 400, height: 400});
    
    electron.ipcMain.on("register-ipcrenderer", (event, arg) =>{
        ipcRenderer = event.sender;
    });
    
    win.loadURL("file://" + path.join(__dirname, "index.html"));
    win.on("move", () =>{
        ipcRenderer.send("window-moved", "moved");
    });
});
electron.app.on("window-all-closed", electron.app.quit);