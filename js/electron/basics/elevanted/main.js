var electron = require("electron");
var sudo = require("sudo-prompt");
var isElevated = require("is-elevanted");
var path = require("path");
let win;
electron.app.on("ready", () => {
    sudo.exec("apt-get update", {name: "herp"}, (er, stdout, stderr) => {
        if (er) throw error;
        console.log(stdout);
    });
});
electron.app.on("window-all-closed", electron.app.quit);