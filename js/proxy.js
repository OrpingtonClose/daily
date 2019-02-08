//https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Proxy
var handler = {
    get: (obj, prop) => {
        console.log("=====================");
        console.log(`obj ${JSON.stringify(obj)}`);
        console.log(`prop ${prop}`);
        return prop in obj ? obj[prop] : 37
    },
    set: function(obj, prop, value) {
        if (prop === 'age') {
            throw new RangeError("Don't ask for age please");
        }
    }
};

var p = new Proxy({}, handler);
p.a = 1;
p.b = undefined;

console.log(p.a, p.b); // 1, undefined
console.log('c' in p, p.c); // false, 37
try {
    p.age = "herp";
} catch(e) {
    console.log("====error:")
    console.log(e);
}

//chained proxies?
var chainedHandler = {
    get: (obj, prop) => {
        console.log("double proxy get")
        return obj[prop];
    },
    set: function(obj, prop, value) {
        console.log("double proxy set")
        obj[prop] = value;
    }
};
for (let n = 0; n < 10; n+= 1) {
    p = new Proxy(p, chainedHandler);
}

console.log(`p.a ${p.a}`);
console.log(`p.b ${p.b}`);
console.log(`p.c ${p.c}`);
