const { app, BrowserWindow, ipcMain } = require("electron");
const axios = require("axios");

const Web3 = require("web3")
const ganache = require("ganache-core");
//const web3 = new Web3();
//const web3 = new Web3("http://localhost:8545");
const web3 = new Web3(ganache.provider());
//web3.setProvider(new Web3.providers.HttpProvider('http://localhost:8545'));
//web3.setProvider(ganache.provider());

ipcMain.on("web3", (event, arg) => {
    //event.source.send("web3", web3);
    //console.log(JSON.stringify(Object.keys(web3)));
    //event.sender.webContents.send("web3-resp", web3);
    //console.log(JSON.stringify(web3));
    //event.returnValue = JSON.stringify(Object.keys(web3));
    
    if (arg === "accounts") {
        // axios.post("http://localhost:8545", {
        //     "jsonrpc": "2.0","id": 1,"method": "eth_accounts","params": []
        // }).then(resp =>{
        //     //event.returnValue = JSON.stringify(resp.data.result);
        //     //console.log(resp);
        // }).catch(err=>{
        //     //console.log(err);
        // });
        //web3.eth.getAccounts().then(console.log); //error
        //web3.eth.getAccounts(console.log);
        //console.log(Object.keys(web3.eth.accounts));
        //event.returnValue = Object.keys(ganache);
        console.log(web3.version.api);
        event.returnValue = [web3.version, ...Object.keys(web3)];//"hello";//web3.version.api //.eth.accounts[0];
    }
    //console.log(arg)
    //event.returnValue = arg(web3);
    //event.returnValue = "dddd".repeat(2000);
});

if (process.env.NODE_ENV !== 'development') {
  global.__static = require('path').join(__dirname, '/static').replace(/\\/g, '\\\\')
}

let mainWindow
const winURL = process.env.NODE_ENV === 'development'
  ? `http://localhost:9080`
  : `file://${__dirname}/index.html`

function createWindow () {
  /**
   * Initial window options
   */
  mainWindow = new BrowserWindow({
    height: 563,
    useContentSize: true,
    width: 1000
  })

  mainWindow.loadURL(winURL)

  mainWindow.on('closed', () => {
    mainWindow = null
  })
}

app.on('ready', createWindow)

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit()
  }
})

app.on('activate', () => {
  if (mainWindow === null) {
    createWindow()
  }
})

/**
 * Auto Updater
 *
 * Uncomment the following code below and install `electron-updater` to
 * support auto updating. Code Signing with a valid certificate is required.
 * https://simulatedgreg.gitbooks.io/electron-vue/content/en/using-electron-builder.html#auto-updating
 */

/*
import { autoUpdater } from 'electron-updater'

autoUpdater.on('update-downloaded', () => {
  autoUpdater.quitAndInstall()
})

app.on('ready', () => {
  if (process.env.NODE_ENV === 'production') autoUpdater.checkForUpdates()
})
 */
