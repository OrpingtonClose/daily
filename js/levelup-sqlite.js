//https://github.com/Level/levelup

//sudo npm i levelup
//sudo npm i sqlite3
//sudo npm i sqldown
//sudo add-apt-repository -y ppa:linuxgndu/sqlitebrowser
//sudo apt-get update -y
//sudo apt-get -y install sqlitebrowser

const levelup = require('levelup');
const sqldown = require('sqldown');
const SQLite = require('sqlite3');
const sqlite = new SQLite.Database('/home/orpington/Desktop/daily/data.db');
//sqlite.close()
//how does it know to use sqlite? Recognizes file format?
var db = levelup(sqldown('/home/orpington/Desktop/daily/data.db'))
db.put("zzzzzz", "merp")
db.put("herp", "merp").then(db.put("herp1", "merp")).then(db.put("herp2", "merp")).then(db.put("zzz", "merp"))
db.get("herp").then(r=>console.log(r.toString()))
db.del("herp")
db.get("herp").then(r=>console.log(r.toString()))