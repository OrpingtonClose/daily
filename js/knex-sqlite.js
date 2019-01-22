//https://knexjs.org/
//sudo npm i knex
//sudo npm i sqlite3

const SQLite = require('sqlite3');
var knex = require('knex')({
    client: 'sqlite3',
    connection: {
       filename: "mydb.sqlite"
    },
    useNullAsDefault: true
});

["select 2+2 aaas sum", "select 2+2 as sum"].forEach( sql => {
    knex.raw(sql).catch((err) => {
        console.log("==================")
        console.log(err.message)
    }).then(([res]) => {
        console.log('connected: ', res)
    });    
});

knex.schema.createTable('table_one', function(table) {
    table.increments();
    table.string('name', 128);
    table.string('username', 128);
    table.string('password');
    table.integer('integer_col');
    table.bigInteger('big_integer_col');
    table.float('float_col');
    table.datetime('datetime_col');
    table.boolean("is_it?");
    //table.string('email', 128);
    //table.string('role').defaultTo('admin');    
    table.timestamps();
}).catch(err=>{
    console.log("error");
}).then(res=>{
    console.log("success");
});

knex('table_one').delete().then(console.log)
knex('table_one').insert([
    {'id': 1,'is_it?': false}, 
    {'id': 2,'is_it?': true},
    {'username': 'someone'}
]).catch(err=>{
    console.log("error");
    console.log(err);
}).then(res=>{
    console.log("success");
});

