const {dialog, app, BrowserWindow, Menu, globalShortcut, ipcMain, clipboard} = require("electron");
var path = require("path");

let mainWindow;

app.on("ready", () => {
    mainWindow = new BrowserWindow({
        width: 900,
        height: 900,
        minWidth: 300,
        minHeight: 300,
        show: false,
        icon: path.join(__dirname, "assets", "img", "solidity.jpeg"),
        // webPreferences: { nodeIntegration: false }
    });
    mainWindow.loadURL("file://" + path.join(__dirname, 'index.html'));

    globalShortcut.register('F5', () => {
        mainWindow.webContents.reload();
    });    

    ipcMain.on("put-to-clipboard", (event, arg) => {
        clipboard.writeText(arg);
    });

    mainWindow.once('ready-to-show', () => {
        Menu.setApplicationMenu(Menu.buildFromTemplate([
            {
                label: "menu",
                type: "submenu",
                submenu: [
                    {
                        type: "normal", 
                        label: "open devtools",
                        click: () => {
                            mainWindow.webContents.openDevTools();
                        }
                    },{
                        type: "normal", 
                        label: "reload",
                        click: () => {
                            mainWindow.webContents.reload();
                        }
                    }
                ]
            }
        ]));
        mainWindow.show();
       // mainWindow.webContents.openDevTools();
        
    });
});

