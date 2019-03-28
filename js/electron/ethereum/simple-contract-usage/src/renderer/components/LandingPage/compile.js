const path = require("path");
const fs = require("fs");
const solc = require("solc");

const compile = () => {

  //const filename = path.join("solc", "PingPong.sol");
  const filename = path.join("src", "renderer", "components", "LandingPage", "solc", "SimpleStorage.sol");
  let base;
  if (typeof __dirname !== "undefined") {
      base = __dirname;
  } else {
      base = process.cwd();
  }
  const sourcePath = path.join(base, filename);

  const input = {
    sources: {
      [sourcePath]: {
        content: fs.readFileSync(sourcePath, { encoding: "utf8" }),
      },
    },
    language: "Solidity",
    settings: {
      outputSelection: {
        "*": {
          "*": ["*"],
        },
      },
    },
  };

  const output = JSON.parse(solc.compile(JSON.stringify(input)));
  const artifact = output.contracts[sourcePath];
  const bytecode = "0x" + artifact.evm.bytecode.object;
  const { abi } = artifact;
  return { bytecode, abi };
};

module.exports = compile();