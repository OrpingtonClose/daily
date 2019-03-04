import "sqlite3";
import * as path from 'path';
const remote = require("electron").remote;
const app = remote.app;
const knex = require("knex");

const database = knex({
    client: "sqlite3",
    connection: {
        filename: path.join(
            app.getPath("userData"), 
            "jetsetter-items.sqlite"
        )
    },
    useNullAsDefault: true
});

database.schema.hasTable("items").then(exists => {
    if (!exists) {
        return database.schema.createTable("items", t => {
            t.increments("id").primary();
            t.string("value", 100);
            t.boolean("packed");
        });
    }
});

export default database;