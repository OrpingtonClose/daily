//https://learning.oreilly.com/library/view/9-practical-nodejs/9781492071112/Text/node2-ch5.html
//npm install chalk clear clui figlet inquirer minimist configstore @octokit/rest lodash simple-git touch --save
["chalk", "clear", "figlet", "fs", "path", "inquirer", "configstore"].forEach(n =>{
    if (!global[n]) {
        global[n] = require(n);
    }
});
var conf = new configstore("ginit");

var getCurrentDirectoryBase = () => path.basename(process.cwd());
// var directoryExists = filePath => {
//     try {
//         return fs.statSync(filePath).isDirectory();
//     } catch (err) {
//         return false;
//     }
// }

clear();
var banner = figlet.textSync('Ginit', { horizontalLayout: 'full' });
var yellowBanner = chalk.yellow(banner);
console.log(yellowBanner);

try {
    var isDirectory = fs.statSync('.git').isDirectory();
}
catch (err) {
    var isDirectory = false;
}

if (isDirectory) {
    console.log(chalk.red('Already a git repository'));
    process.exit();
}

var questions = [{
    name: "username",
    type: "input",
    message: "Enter your GitHub username or e-mail address:",
    validate: v => v.length ? true : "please enter your username or e-mail address"
},{
    name: "password",
    type: "password",
    message: "Enter your password:",
    validate: v => v.length ? true : "please enter your password"
}];

const run = async () => {
    var octokit = require("@octokit/rest")();
    var pkg = require("./package.json");
    var _ = require("lodash");
    var CLI = require("clui");
    var Spinner = CLI.Spinner;
    var chalk = require("chalk");
    
    var token = conf.get('github.token');
    if (!token) {
        var credentials = await inquirer.prompt(questions);
        var status = new Spinner("Authenticating you, please wait");
        status.start();
        await octokit.authenticate(_.extend({type: "basic"}, credentials));
        try {
            var response = await octokit.authorization.create({
                scopes: ["user", "public_repo", "repo", "repo:status"],
                note: "ginits, the CLI for init'ing git repos"
            });
            token = response.data.token;
            if (token) {
                conf.set('github.token', token);
            } else {
                throw new Error("Missing Token", "GitHub toekn was not found in the response");
            }
        } catch (err) {
            throw err;
        } finally {
            status.stop();
        }
    }
}

run();

//to be continued

// var stat = new Spinner("authenticating, please wait");
// stat.start();
// stat.update("herp");
// stat.stop();

