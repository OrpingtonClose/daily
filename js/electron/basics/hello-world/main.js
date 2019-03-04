const electron = require("electron");
const path = require("path");

let win = null;

electron.app.on("ready", () => {
    var opts = {width: 800, height: 600, minWidth: 200, minHeight: 400, maxWidth: 1000, maxHeight: 800};
    var ables = ["resize", "mov", "minimiz", "maximiz", "clos", "focus", "fullscreen"].map(p=>p + "able");
    opts = Object.assign(opts, ables.reduce((prev, cur) => Object.assign(prev, JSON.parse(`{"${cur}": true}`)), {}));
    //most options dont work on linux
    opts = Object.assign(opts, { 
        title: "My app", 
        fullscreen: false, 
        frame: true, 
        backgroundColor: "#eeeeee",
        icon: path.join(__dirname, "myapp.png"),
        show: false
    });
    console.log(path.join(__dirname, "myapp.png"));
    win = new electron.BrowserWindow(opts);
    win.loadURL(`file://${path.join(__dirname, "index.html")}`);
    win.on("ready-to-show", () => {
        win.show();
        //hide
        //focus
        //close
    });
    win.on("closed", () => {
        win = null;
    });
});

electron.app.on("window-all-closed", electron.app.quit);
