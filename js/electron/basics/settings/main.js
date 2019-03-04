var electron = require("electron");
var userDataPath = electron.app.getPath("userData");
var storage = require("electron-json-storage");

electron.app.on("ready", ()=>{
    storage.set("user", {
        name: {
            first: "John", 
            second:"Doe"
        }, 
        nickname: "Johnny"
    }, error => {
        if (error) {
            throw error;
        }
        storage.get("user", (error, user)=>{
            if (error) throw error;
            console.log(user);
            storage.remove("user", error=>{
                if (error) {
                    throw error;
                }
                console.log("removed user");
                storage.has("user", (error, hasUser) => {
                    console.log("hasUser: " + hasUser);
                });
            });
        })
    });
});
electron.app.on("windows-all-closed", electron.app.quit);