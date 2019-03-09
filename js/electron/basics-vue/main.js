var electron = require("electron");
var path = require("path");
var fs = require("fs");
var win;

electron.app.on("ready", ()=>{
    win = new electron.BrowserWindow({
        width: 600, 
        height:800, 
        icon: path.join(__dirname, 'assets/img/vue.png'),
        backgroundColor: '#9579A0'
    });
    var filesWithTimes = [];

    const screen = chapter => name => {
        var title = name.replace(".html", "").replace(/[0-9]{2} /, "");
        var filePath = path.join(__dirname, "code", chapter, `${name}`);
        var click = () => {
            win.loadURL("file://" + filePath);
            win.setTitle(`${chapter}: ${title}`);
        };
        click.time = fs.statSync(filePath).mtimeMs;
        filesWithTimes.push(click);
        return {type: "normal", label: title, click}
    };
    const loadPages = name => {
        var directory = path.join(__dirname, "code", name);
        var cleanLabel = name.replace(/\d{2} /, "");
        var filesOfConsideration = fs.readdirSync(directory).filter(f=>f.endsWith("html"));
        return {
            label: cleanLabel,
            type: "submenu",
            submenu: filesOfConsideration.map(screen(name))
        }
    };
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
        },{
            label: "reload",
            type: "normal",
            click: () => win.webContents.reload()
        }]
    };
    var codeGroups = fs.readdirSync(path.join(__dirname, "code"));
    const myMenu = [...codeGroups.map(loadPages), devMenu];
    electron.Menu.setApplicationMenu(electron.Menu.buildFromTemplate(myMenu));  
    filesWithTimes.reduce((prv, cur) => {
        if (prv) {
            return cur.time > prv.time ? cur : prv;
        } else {
            return cur;
        }
    }, undefined)();
    //myMenu[0].submenu[0].click();
});
electron.app.on("window-all-closed", electron.app.quit);