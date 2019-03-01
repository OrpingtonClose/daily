const electron = require("electron");
const path = require("path");

let win = null;

electron.app.on("ready", () => {
    //msgbox(curWin, opts, (response, checkboxChecked) => {});
    win = new electron.BrowserWindow({height: 600, width: 720});
    const myMenu = electron.Menu.buildFromTemplate([
        {
            label: "my first menu",
            type: "submenu",
            submenu: [
                {
                    type: "normal", 
                    label: "this is a label",
                    accelerator: "CmdOrCtrl+Shift+A",
                    click: () => {
                        electron.dialog.showMessageBox(win, {
                            message: "menu item pressed",
                            buttons: ["OK"]
                        });
                    }
                },
                {type: "separator"},
                {type: "checkbox", label: "this is a second label", checked: true}
            ]
        },{
            label: "my second menu",
            type: "submenu",
            enabled: true,
            visible: true,
            submenu: [
                {
                    type: "submenu", 
                    label: "nesting proceeds",
                    submenu: [{type: "normal", label: "Nested item"}]
                },{
                    type: "submenu", 
                    label: "radios",
                    submenu: [
                        {type: "radio", label: "one radio"},
                        {type: "radio", label: "two radio", checked: true},
                        {type: "radio", label: "three radio"},
                    ]                    
                }
            ]                        
        }
    ]);
    electron.Menu.setApplicationMenu(myMenu);
    //win.addEventListener("contextmenu", () =>{
    //    myMenu.popup(win);
    //});
    const file = path.join(__dirname, "index.html");
    win.loadURL("file://" + file);
});

electron.app.on("window-all-closed", electron.app.quit);