//import idb from 'idb';
const idb = require("idb");

const dbVersion = 1;
const database = idb.openDb("sock-organizer", dbVersion, upgradeDb => {
    upgradeDb.createObjectStore("items", {
        keyPath: "id",
        autoIncrement: true
    });
});

export default {
    getAll() {
        return database.then(db => db.transaction("items")
                                     .objectStore("items")
                                     .getAll());
    },
    add(item) {
        return database.then(db => {
            const tx = db.transaction("items", "readwrite");
            tx.objectStore("items").add(item);
            return tx.complete;
        });
    },
    update(item) {
        return database.then(db => {
            const tx = db.transaction("items", "readwrite");
            tx.objectStore("items").put(item);
            return tx.complete;
        });        
    },
    markAllAsUnpacked() {
        return this.getAll()
                   .then(items => items.map(item => ({...item, packed: false})))
                   .then(function(items) {
                       return database.then(db => {
                           const tx = db.transaction("items", "readwrite");
                           for (const item of items) {
                               tx.objectStore("items").put(item);
                           }
                           return tx.complete;
                       });
                   });
    },
    delete(item) {
        return database.then(db => {
            const tx = db.transaction("items", "readwrite");
            tx.objectStore("items").delete(item.id);
            return tx.complete;
        });
    },
    deleteAll() {
        return database.then(db => {
            const tx = db.transaction("items", "readwrite");
            tx.objectStore("items").clear();
            return tx.complete;
        });
    },
    deleteUnpackedItems() {
        return this.getAll()
                   .then(items => items.filter(item => !item.packed))
                   .then(items => {
                       return database.then(db => {
                           const tx = db.transaction("items", "readwrite");
                           for (const item of items) {
                               tx.objectStore("items").delete(item.id);
                           }
                           return tx.complete;
                       });
                   });        
    }
};