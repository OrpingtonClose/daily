const electron = require("electron");
const path = require("path");

const applicationWindows = {};

electron.ipcMain.on("open-settings", (event, argument) => {
    applicationWindows.settings.show();
});
//unsafe websties!
electron.ipcMain.on("open-unsafe", (event, argument) => {
    applicationWindows.unsafe.loadURL("https://ddg.gg");
    applicationWindows.unsafe.show();
});


electron.app.on("ready", () => {
    const make = opts => new electron.BrowserWindow(opts);
    const cleanup = win => {applicationWindows[win].on("closed", () => { delete applicationWindows[win];});};
    const load = file => `file://${path.join(__dirname, file)}`;
    applicationWindows.main = make({width: 800, height: 600});
    applicationWindows.main.loadURL(load("index.html"));
    
    //applicationWindows.settings = make({parent: applicationWindows.main});
    applicationWindows.settings = make({width: 800, height: 600, show: false});
    applicationWindows.settings.loadURL(load("settings.html"));
    
    applicationWindows.unsafe = make({
        width: 800, height: 600, show: false, 
        webPreferences: {
            nodeIntegration: false,
            javascript: false
        }
    });

    ["main", "settings", "unsafe"].forEach(cleanup);
});

electron.app.on("window-all-closed", electron.app.quit);
