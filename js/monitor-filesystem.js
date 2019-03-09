var fs = require("fs");

var path = process.env.HOME + "/some-file.txt";

fs.writeFileSync(path, "data");

fs.watch(path, {recursive: true}, function(eventName, filename) {
    console.log(`eventName ${eventName}`);
    console.log(`filename ${filename}`);
});
//Error: ENOSPC: System limit for number of file watchers reached

fs.writeFileSync(path, "some data");