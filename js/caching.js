var sha256 = require("sha256");
var Fun = function(fun) {
    if (!Fun.reg) {
        Fun.reg = [];
    }
    var digest = sha256(this.toString());
    if (!Fun.reg[digest]) {
        Fun.reg[digest] = fun;
        global[fun.name] = fun;
    }    
}

new Fun(function somethingFun(arg1, arg2) {
    console.log("one");
});