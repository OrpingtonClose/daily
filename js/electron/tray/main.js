const electron = require("electron");
const path = require("path");
let win = null;
electron.app.on("ready", ()=>{
    let tray = new electron.Tray(path.join(__dirname, "myapp.png"));
    tray.setToolTip("my application");
    var labels = Object.getOwnPropertyNames(electron).map(name=>({type:"normal", label: name, click: () => win.isVisible() ? win.hide() : win.show()}));
    var trayMenu = electron.Menu.buildFromTemplate(labels);
    win = new electron.BrowserWindow({height:200, width: 200});
    //https://learning.oreilly.com/library/view/electron-in-action/9781617294143/kindle_split_019.html
    if (process.platform === "win32") {
        tray.on("click", () => tray.popUpContextMenu);
    }
    tray.setContextMenu(trayMenu);    
});
electron.app.on("window-all-closed", electron.app.quit);