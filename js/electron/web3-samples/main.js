const {app, BrowserWindow, Menu, globalShortcut} = require("electron");
var path = require("path");

let mainWindow;

app.on("ready", () => {
    mainWindow = new BrowserWindow({
        width: 900,
        height: 900,
        minWidth: 300,
        minHeight: 300,
        show: false,
        icon: path.join(__dirname, "assets", "img", "solidity.jpeg")
    });
    mainWindow.loadURL("file://" + path.join(__dirname, 'just-compile.html'));

    globalShortcut.register('F5', () => {
        mainWindow.webContents.reload();
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

