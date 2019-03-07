var electron = require("electron");
var path = require("path");
var fs = require("fs");
var win;

electron.app.on("ready", ()=>{
    win = new electron.BrowserWindow({width: 600, height:800});
    const screen = chapter => name => ({
        type: "normal", label: name, 
        click: () => {
            win.loadURL("file://" + path.join(__dirname, path.join(chapter, `${name}`)));
            win.setTitle(`${chapter}:${name.replace(".html", "")}`);
        }
    });
    const loadPages = name => ({
        label: name,
        type: "submenu",
        submenu: fs.readdirSync(name).filter(f=>f.endsWith("html")).map(screen(name))
    });
    const devMenu = {
        label: "dev",
        type: "submenu",
        submenu: [{
            label: "open dev tools",
            type: "normal",
            click: () => win.webContents.openDevTools()
        },{
            label: "close dev tools",
            type: "normal",
            click: () => win.webContents.closeDevTools()
        }]
    };
    const myMenu = [loadPages("chapter1"), devMenu];
    electron.Menu.setApplicationMenu(electron.Menu.buildFromTemplate(myMenu));  
    myMenu[0].submenu[0].click();
});
electron.app.on("window-all-closed", electron.app.quit);