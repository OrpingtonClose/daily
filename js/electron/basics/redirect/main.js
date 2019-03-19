var electron = require("electron");
var path = require("path");
var win;

electron.app.on("ready", ()=>{
    win = new electron.BrowserWindow({
        width:800, 
        height: 600,
        webSecurity: false,
        allowRunningInsecureContent: true
    });

    win.webContents.session.webRequest.onBeforeSendHeaders((details, callback) => {
        electron.dialog.showErrorBox("Not ok", "Something happened - two");
        //details.requestHeaders['User-Agent'] = 'MyAgent'
        callback({ requestHeaders: details.requestHeaders })
    });

    win.webContents.session.setPermissionRequestHandler((webContents, permission, callback) => {
        console.log("entered event");
        if (webContents.getURL() === 'some-host' && permission === 'notifications') {
          return callback(false) // denied.
        }
      
        callback(true)
    })

    win.loadURL(path.join(__dirname, "index.html"));
    const ses = win.webContents.session
    console.log(JSON.stringify(ses));
});

electron.app.on("window-all-closed", electron.app.quit);