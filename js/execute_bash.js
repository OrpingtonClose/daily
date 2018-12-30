const {exec} = require("child_process");

const standardExecCallback = (error, stdout, stderr) => {
    if (error) {
        console.log(`error: ${error}`);
    }
    console.log(`${stdout}\n${stderr}`);
};

exec("lsof", standardExecCallback);
exec("echo race condition", standardExecCallback);

const execPromise = (command) => {
    return new Promise((resolve, reject) => {
        exec(command, (error, stdout, stderr) => {
            if (error) {
                console.log(`error: ${error}`);
                return reject(error);
            }
            return resolve(`${stdout}\n${stderr}`);
        });
    });
}

execPromise("netstat --listening").then(data=>{
    console.log(data);
    return execPromise("ls");
}).then(console.log);