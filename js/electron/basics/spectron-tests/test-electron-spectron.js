/*
/home/orpington/node_modules/mocha/bin/mocha test-electron-spectron.js --timeout 5000
*/
const spectron = require("spectron");
const assert = require("assert");
beforeEach(function() {
    this.app = new spectron.Application({
        path: "/home/orpington/.npm-global/lib/node_modules/electron/dist/electron",
        args: ["/home/orpington/Desktop/daily/js/electron/spectron-tests/main.js"]
    });
    return this.app.start();
});

it("should have a specific div with value 'two'", function() {
    return this.app.client.getText("#div-with-two").then(value => {
        assert.equal(value, "2");
    });
});

it("should increment the counter", function() {
    return this.app.client.click("#incrementor").getText("#to-increment").then(value =>{
        assert.equal(value, "1");
    });
});

it("should decrement the counter", function() {
    return this.app.client.click("#decrementor").getText("#to-increment").then(value =>{
        assert.equal(value, "-1");
    });
});

afterEach(function() {
    if (this.app && this.app.isRunning()) {
        return this.app.stop();
    }
});