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
        var title = name.replace("/index.html", "").replace(".html", "").replace(/[0-9]{2} /, "");
        var filePath = path.join(__dirname, "code", chapter, `${name}`);
        var click = () => {
            win.loadURL("file://" + filePath);
            console.log(`${chapter}: ${title}`)
            win.webContents.once('dom-ready', () => {
                win.setTitle(`${chapter}: ${title}`);
            });
        };
        click.time = fs.statSync(filePath).mtimeMs;
        click.path = filePath;
        filesWithTimes.push(click);
        return {type: "normal", label: title, click}
    };
    const loadPages = name => {
        var directory = path.join(__dirname, "code", name);
        var cleanLabel = name.replace(/\d{2} /, "");
        var allNodes = fs.readdirSync(directory);
        var filesOfConsideration = allNodes.filter(f=>f.endsWith("html"));
        var isDirectory = n => fs.statSync(path.join(directory, n)).isDirectory();
        var hasIndexHtml = n => fs.existsSync(path.join(directory, n, "index.html"));
        var isAlright = n => isDirectory(n) && hasIndexHtml(n);
        var filesOfConsiderationInFolders = allNodes.filter(isAlright).map(d => path.join(d, "index.html"));
        var nodesOfConsideration = filesOfConsideration.concat(filesOfConsiderationInFolders);
        return {
            label: cleanLabel,
            type: "submenu",
            submenu: nodesOfConsideration.map(screen(name))
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
            click: () => win.webContents.reloadIgnoringCache()
        }]
    };
    const codeGroups = () => fs.readdirSync(path.join(__dirname, "code"));
    const myMenu = () => electron.Menu.buildFromTemplate([...codeGroups().map(loadPages), devMenu]);
    electron.Menu.setApplicationMenu(myMenu());
    filesWithTimes.reduce((prv, cur) => {
        if (prv) {
            return cur.time > prv.time ? cur : prv;
        } else {
            return cur;
        }
    }, undefined)();
    setInterval(()=>{
        electron.Menu.setApplicationMenu(myMenu());
    }, 2000);
    win.webContents.openDevTools()
    //myMenu[0].submenu[0].click();
});
electron.app.on("window-all-closed", electron.app.quit);