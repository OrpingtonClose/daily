var {app, BrowserWindow} = require("electron");
let win;
app.on("ready", () => {
    win = new BrowserWindow({width: 800, height: 600});
    //win.setProgressBar(0.5);
    let n = 0;
    setInterval(() =>{
        n = n === -1 ? 0 : n === 10 ? -1 : n + 1;
        //doesn't work with linux?
        win.setProgressBar( n / 10 );
    }, 1000);
});

app.on("window-all-closed", app.quit);