const electron = require("electron");
const path = require("path");
var win = null;
electron.app.on("ready", () => {
    win = new electron.BrowserWindow({height: 445, width: 745, title: "https://p5js.org/examples/simulate-spirograph.html"});
    var file = path.join(__dirname, "index.html");
    win.loadURL(`file://${file}`);
});

electron.app.on("window-all-close", electron.app.quit)