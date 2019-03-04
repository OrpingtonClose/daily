var electron = require("electron");
var path = require("path");
var {app, BrowserWindow} = electron;
let win;
app.on("ready", ()=>{
    win = new BrowserWindow({width: 800, height: 600});
    const myMenu = electron.Menu.buildFromTemplate([{
        label: "put to clipboard",
        type: "submenu",
        submenu: [{
                type: "normal", 
                label: "this is a label",
                click: () => {
                    electron.clipboard.writeText("this is a label");
                    win.webContents.send("clipboard-content", electron.clipboard.readText());
                }
            },{
                type: "normal", 
                label: "what's in the clipboard",
                click: () => {
                    win.webContents.send("clipboard-content", electron.clipboard.readText());
                }
            },{
                type: "normal", 
                label: "electron native image",
                click: () => {
                    var img = electron.nativeImage.createFromPath(path.join(__dirname, "mouse.png"));
                    electron.clipboard.writeImage(img);
                    win.webContents.send("clipboard-content-image", electron.clipboard.readImage().toDataURL());
                }
            }]
    }]);    
    electron.Menu.setApplicationMenu(myMenu);
    electron.ipcMain.once("initiated", () =>{
        electron.dialog.showErrorBox("Not ok", electron.clipboard.readText());
        win.webContents.send("clipboard-content", electron.clipboard.readText());
    });
    win.loadURL("file://" + path.join(__dirname, "index.html"));
});
app.on("window-all-closed", app.quit);