var electron = require("electron");
// var keypress = require("keypress");
// keypress(process.stdin);
// process.stdin.on('keypress', function(ch, key) {
//     console.log('got "keypress"', key);
//     if (key && key.ctrl && key.name == 'c') {
//         process.exit();
//     }
// });
// process.stdin.setRawMode(true);
// process.stdin.resume();
let win;
electron.app.on("ready", () => {
    electron.globalShortcut.register("CmdOrCtrl+i", () => {
        electron.dialog.showErrorBox("msg", "command was executed and will never be executed again");
        electron.globalShortcut.unregister("CmdOrCtrl+i");
    });
    win = new electron.BrowserWindow({width: 200, height: 200, title: "press control + i"});
});

electron.app.on("window-all-closed", electron.app.quit);