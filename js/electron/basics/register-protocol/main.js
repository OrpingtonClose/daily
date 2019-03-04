var {app, BrowserWindow, protocol, dialog} = require("electron");
let win;
var successCallback = (request, callback) => {
    var script = `<script>electron.remote.dialog.showErrorBox("Loaded this script", "be worried");</script>`;
    callback({mimeType:"application/javascript", data: Buffer.from(script)})
};
var errorCallback = error => {
    dialog.showErrorBox("failure", "failed to load dialog");
};
for (o in require("electron").protocol) {
    console.log(o)
}

//Doesn't work. Documentation says it should. Odd
//https://glebbahmutov.com/blog/electron-app-with-custom-protocol/
//https://electronjs.org/docs/api/protocol
//https://learning.oreilly.com/videos/building-electron-applications/9781788391542/9781788391542-video3_2

protocol.registerBufferProtocol("message", successCallback, errorCallback);

app.on("ready", () => {
    win = new BrowserWindow({width: 800, height: 600});
    win.loadURL("message://herp");
});

app.on("window-all-closed", app.quit);