const assert = require("assert")
//Symbols represent a unique value and at its heart, 
//a symbol is a unique token that is guaranteed to never clash with any other Symbol.

//https://learning.oreilly.com/library/view/es6-for-humans/9781484226230/A431489_1_En_7_Chapter.html
var something = Symbol()
assert(typeof something === "symbol");
assert(something.toString() === "Symbol()");
assert(Symbol("ddddd").toString() === "Symbol(ddddd)");
assert(Symbol() !== Symbol());
assert(Symbol() != Symbol());

var o = {};
var s = Symbol();
o[s] = function() {
    return 43;
}
o.herp = "merp";

assert(Object.getOwnPropertyNames(o).pop() === "herp");
assert(Object.getOwnPropertySymbols(o).pop() === s);

//global symbol registry
assert(Symbol.for("ffff") === Symbol.for("ffff"));
assert(Symbol.keyFor(Symbol.for("ffff")) === "ffff");
//Symbol.hasInstance
//Symbol.iterator

var itr = [3, 44, 555, 6666][Symbol.iterator]();
for (let n = 0; n < 4; n += 1 ){
    assert(itr.next().done === false);
}
assert(itr.next().done === true);

assert((a => [0, 3].map((v, i) => a[i] === v))([3, 44, 555, 6666].entries().next().value).reduce((prev, cur) => prev && cur, true));

