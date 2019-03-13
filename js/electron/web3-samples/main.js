const {app, BrowserWindow, Menu} = require("electron");
var path = require("path");

let mainWindow;

app.on("ready", () => {
    mainWindow = new BrowserWindow({
        width: 300,
        height: 600,
        minWidth: 300,
        minHeight: 300,
        show: false
    });
    mainWindow.loadURL("file://" + path.join(__dirname, 'just-compile.html'));
    mainWindow.once('ready-to-show', () => {
        Menu.setApplicationMenu(Menu.buildFromTemplate([
            {
                label: "menu",
                type: "submenu",
                submenu: [
                    {
                        type: "normal", 
                        label: "clear database",
                        click: () => {
                            mainWindow.webContents.send("delete-database", "");
                        },
                    },{
                        type: "normal", 
                        label: "open devtools",
                        click: () => {
                            mainWindow.webContents.openDevTools();
                        }
                    }
                ]
            }
        ]));
        mainWindow.show();
       // mainWindow.webContents.openDevTools();
        
    });
});

