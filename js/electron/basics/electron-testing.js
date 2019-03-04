var electron = require("electron");
var assert = require("assert");

describe("Clipboard", function() {
    it("Should be able to copy text to clipboard", function() {
        electron.clipboard.writeText("Hello!");
        assert.equal(electron.clipboard.readText(), "Hello!");
    });
});