~/.npm-global/bin/vue init simulatedgreg/electron-vue simple-contract-usage
cd simple-contract-usage
yarn
yarn add electron-rebuild --dev #https://dev.to/onmyway133/dealing-with-nodemoduleversion-in-electron
yarn add web3
yarn add ganache-core
./node_modules/.bin/electron-rebuild
yarn run dev


# simple-contract-usage

> An electron-vue project

#### Build Setup

``` bash
# install dependencies
npm install

# serve with hot reload at localhost:9080
npm run dev

# build electron application for production
npm run build


```

---

This project was generated with [electron-vue](https://github.com/SimulatedGREG/electron-vue)@[8fae476](https://github.com/SimulatedGREG/electron-vue/tree/8fae4763e9d225d3691b627e83b9e09b56f6c935) using [vue-cli](https://github.com/vuejs/vue-cli). Documentation about the original structure can be found [here](https://simulatedgreg.gitbooks.io/electron-vue/content/index.html).
