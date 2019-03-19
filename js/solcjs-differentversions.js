var solc = require("solc");
var axios = require("axios");
var hash = require("sha256");
var semver = require("semver");
var path = require("path");
var fs = require("fs");
var solcWrapper = require("solc/wrapper");

var fetchList = () => axios.get("https://solc-bin.ethereum.org/bin/list.js").then(result => new Promise((resolve, reject) => {
    resolve(eval(result.data))
}).catch(err=>{
    reject(err);
}));
var fetchListMock = () => Promise.resolve({
    allVersions: [],
    releases: {
        "0.5.1": "soljson-v0.5.1+commit.c8a2cb62.js",
        "0.5.0": "soljson-v0.5.0+commit.1d4f565a.js"
    }
});

// fetchListMock().then(console.log)
// fetchList().then(console.log)

var nonCaching = releases => new Promise((resolve, reject) => {
    let solcs = {};
    let solcsCached = {};
    let compilationResults = {};
    var fetchSolcAndCompile = (release, version) => new Promise((resolveInner, rejectInner)=>{
        console.log(`${version} starting download`); 
        solc.loadRemoteVersion(version, function (err, solcSnapshot) {
            console.log(`${version} done downloading`); 
            if (err) {
                rejectInner(err);
                console.log(`${version}: nope`);
            } else {
                solcs[release] = solcSnapshot;
                try {
                    compilationResults[release] = solcSnapshot.compile(simpleSolidity);
                } catch {}
                resolveInner();
            }
        });
    });
    var promiseChain;
    for (release in releases.releases) {
        var versionLong = releases.releases[release];
        var version = versionLong.replace(/(^soljson\-)|(\.js$)/g, "");
        if (promiseChain) {
            promiseChain = promiseChain.then(fetchSolcAndCompile(release, version));
        } else {
            promiseChain = fetchSolcAndCompile(release, version);
        }
    }
    promiseChain.then(() => resolve({solcs, solcsCached, compilationResults}));
});


var caching = (cache, compiler) => releases => new Promise((resolve, reject) => {
    let solcs = {};
    let solcsCached = {};
    let compilationResults = {};
    try {
        fs.mkdirSync(cache);
    } catch { } //more checking

    var fetchSolcAndCompile = (release, version) => new Promise(function(resolveInner, rejectInner) {
        
        let alreadyDownloaded;
        var absPathCompiler = path.join(cache, version);
        try {
            fs.statSync(absPathCompiler);
            alreadyDownloaded = true;
        }
        catch {
            alreadyDownloaded = false;
        }

        var process = () => {
            var solc = solcWrapper(require(absPathCompiler))
            solcs[release] = solc;
            try {
                compilationResults[release] = compiler(solc);
            } catch {}
            resolveInner();
        };

        if (alreadyDownloaded) {
            console.log(`${version} using cached`);             
            process()
        } else {
            var solJsonUrl = `https://solc-bin.ethereum.org/bin/soljson-${version}.js`;
            console.log(`${version} starting download ${solJsonUrl}`); 
            promiseChain = axios.request({
                responseType: 'arraybuffer',
                url: solJsonUrl,
                method: 'get'
            }).then((result) => {
                console.log(`${version} finished download`); 
                fs.writeFileSync(absPathCompiler, result.data);
                process()
            });
        }
    });
    var promiseChain;
    Object.keys(releases.releases).forEach(release => {
        var _release = release;
        var versionLong = releases.releases[_release];
        var version = versionLong.replace(/(^soljson\-)|(\.js$)/g, "");
        if (promiseChain) {
            promiseChain = promiseChain.then((__release => () => fetchSolcAndCompile(_release, version))(_release));
        } else {
            promiseChain = fetchSolcAndCompile(_release, version);
        }
    });
    promiseChain.then(() => resolve({solcs, solcsCached, compilationResults}));
});

var process = ({solcs, solcsCached, compilationResults}) => new Promise((resolve, reject)=>{
    var hashCompiles = what => hash(what).slice(0, 7);
    compilationDifferences = Object.keys(compilationResults).reduce( (prv, cur) => {
        var hashed = hashCompiles(compilationResults[cur]);
        if(!prv[hashed]) {
            prv[hashed] = [];
        }
        prv[hashed].push(cur);
        prv[hashed].sort((a, b) => semver.compare(a, b));
        return prv;
    }, {});
    
    compilationHashMap = Object.keys(compilationResults).reduce( (prv, cur) => {
        prv[hashCompiles(compilationResults[cur])] = compilationResults[cur];
        return prv;
    }, {});
    
    compilationDifferencesVerbose = Object.keys(compilationDifferences).reduce((prv, cur)=>{
        prv[compilationHashMap[cur]] = compilationDifferences[cur];
        return prv;
    }, {});

    //console.log(JSON.stringify(compilationDifferencesVerbose, null, 2));
    console.log(JSON.stringify(compilationDifferences, null, 2));
})

if (!__dirname) {
    __dirname = process.cwd();
}
var solcCache = path.join(__dirname, ".cache-solc");
var simpleSolidity = "contract C { function f() public { } }";
var compile = solc => solc.compile(simpleSolidity);
var compileWithJsonDecorator = solc => {
    var input = {
        language: 'Solidity',
        sources: { '': { content: simpleSolidity } },
        settings: { outputSelection: { '*': { '*': [ '*' ] } } }
    }
    //return JSON.parse(solc.compile(JSON.stringify(input)))
    return solc.compile(JSON.stringify(input));
};
var compileHeadersOnly = solc => Object.keys(compileWithJsonDecorator(solc)).join(";");

//fetchListMock().then(nonCaching).then(process)
//fetchListMock().then(caching(solcCache, compile)).then(process)
//fetchList().then(caching(solcCache, compile)).then(process)
//fetchListMock().then(caching(solcCache, compileWithJsonDecorator)).then(process)
//fetchList().then(caching(solcCache, compileWithJsonDecorator)).then(process)
fetchList().then(caching(solcCache, compileHeadersOnly)).then(process)


