#https://docs.microsoft.com/en-us/azure/virtual-machines/linux/tutorial-mean-stack
#15c - Create MEAN stack
RES=meangroup
ADMIN=shaker
PASS=$(apg -M SNCL -a1 -m 15 -n 1)
PORT=3000
VMNAME=meanvm
az login
az group create --name $RES --location eastus
RESULT=$(az vm create --resource-group $RES \
             --name $VMNAME \
             --image UbuntuLTS \
             --admin-username $ADMIN \
             --admin-password $PASS \
             --generate-ssh-keys)
IP=$(echo $RESULT | jq -r '.publicIpAddress')
RESULT_1=$(az vm open-port --port $PORT --resource-group $RES --name $VMNAME)
#password for ssh into clipboard
echo $PASS | xsel -b
ssh $ADMIN@$IP

sudo apt-get install -y nodejs
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6
echo "deb [ arch=amd64 ] http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.4.list
sudo apt-get update
sudo apt-get install -y mongodb
sudo service mongodb start
sudo apt-get install npm -y
sudo npm install body-parser
mkdir books
cat > server.js <<EOF
var express = require('express');
var bodyParser = require('body-parser');
var app = express();
app.use(express.static(__dirname + '/public'));
app.use(bodyParser.json());
require('./apps/routes')(app);
app.set('port', 3000);
app.listen(app.get('port'), function() {
    console.log('Server up: http://localhost:' + app.get('port'));
});
EOF
sudo npm install express mongoose
mkdir apps
cat > apps/routes.js <<EOF
var Book = require('./models/book');
module.exports = function(app) {
  app.get('/book', function(req, res) {
    Book.find({}, function(err, result) {
      if ( err ) throw err;
      res.json(result);
    });
  }); 
  app.post('/book', function(req, res) {
    var book = new Book( {
      name:req.body.name,
      isbn:req.body.isbn,
      author:req.body.author,
      pages:req.body.pages
    });
    book.save(function(err, result) {
      if ( err ) throw err;
      res.json( {
        message:"Successfully added book",
        book:result
      });
    });
  });
  app.delete("/book/:isbn", function(req, res) {
    Book.findOneAndRemove(req.query, function(err, result) {
      if ( err ) throw err;
      res.json( {
        message: "Successfully deleted the book",
        book: result
      });
    });
  });
  var path = require('path');
  app.get('*', function(req, res) {
    res.sendfile(path.join(__dirname + '/public', 'index.html'));
  });
};
EOF
mkdir apps/models
cat > apps/models/book.js <<EOF
var mongoose = require('mongoose');
var dbHost = 'mongodb://localhost:27017/test';
mongoose.connect(dbHost);
mongoose.connection;
mongoose.set('debug', true);
var bookSchema = mongoose.Schema( {
  name: String,
  isbn: {type: String, index: true},
  author: String,
  pages: Number
});
var Book = mongoose.model('Book', bookSchema);
module.exports = mongoose.model('Book', bookSchema); 
EOF

cd ..
mkdir public
cat > public/script.js <<EOF
var app = angular.module('myApp', []);
app.controller('myCtrl', function(\$scope, \$http) {
  \$http( {
    method: 'GET',
    url: '/book'
  }).then(function successCallback(response) {
    \$scope.books = response.data;
  }, function errorCallback(response) {
    console.log('Error: ' + response);
  });
  \$scope.del_book = function(book) {
    \$http( {
      method: 'DELETE',
      url: '/book/:isbn',
      params: {'isbn': book.isbn}
    }).then(function successCallback(response) {
      console.log(response);
    }, function errorCallback(response) {
      console.log('Error: ' + response);
    }).then(
        \$http( {
            method: 'GET',
            url: '/book'
        }).then(function successCallback(response) {
            \$scope.books = response.data;
        }, function errorCallback(response) {
            console.log('Error: ' + response);
        })        
    );
  };
  \$scope.add_book = function() {
    var body = '{ "name": "' + \$scope.Name + 
    '", "isbn": "' + \$scope.Isbn +
    '", "author": "' + \$scope.Author + 
    '", "pages": "' + \$scope.Pages + '" }';
    \$http({
      method: 'POST',
      url: '/book',
      data: body
    }).then(function successCallback(response) {
      console.log(response);
    }, function errorCallback(response) {
      console.log('Error: ' + response);
    }).then(
        \$http( {
            method: 'GET',
            url: '/book'
        }).then(function successCallback(response) {
            \$scope.books = response.data;
        }, function errorCallback(response) {
            console.log('Error: ' + response);
        })        
    );
  };
});
EOF
cd ~
cat > public/index.html <<EOF
<!doctype html>
<html ng-app="myApp" ng-controller="myCtrl">
  <head>
    <link rel="stylesheet" href="https://unpkg.com/tachyons@4.10.0/css/tachyons.min.css"/>
    <script src="https://ajax.googleapis.com/ajax/libs/angularjs/1.6.4/angular.min.js"></script>
    <script src="script.js"></script>
  </head>
  <body class="pa4-l normal" bgcolor="#E6E6FA">
    <div class="bg-white h-100 midnight-blue pa3 ph0-l pv6-l">
      <div class="center mw7">
      <form class="pa4 black-80">
        <div class="measure">
          <label class="f6 b db mb2">Name:</label>
          <input class="input-reset ba b--black-20 pa2 mb2 db w-100" type="text" ng-model="Name">
        </div>
        <div class="measure">
          <label class="f6 b db mb2">Isbn:</label>
          <input class="input-reset ba b--black-20 pa2 mb2 db w-100" type="text" ng-model="Isbn">
        </div>
        <div class="measure">
          <label class="f6 b db mb2">Author:</label>
          <input class="input-reset ba b--black-20 pa2 mb2 db w-100" type="text" ng-model="Author">
        </div>
        <div class="measure">
          <label class="f6 b db mb2">Pages:</label>
          <input class="input-reset ba b--black-20 pa2 mb2 db w-100" type="number" ng-model="Pages">
        </div>                                      
      </form>
      <button  class="f6 link dim br3 ph3 pv2 mb2 dib white bg-black" ng-click="add_book()">Add</button>
    </div>
    <hr>
    <div>
      <table class="f6 w-100 mw8 center" cellspacing="0">
        <thead>
          <tr>
            <th class="fw6 bb b--black-20 tl pb3 pr3 bg-white">Name</th>
            <th class="fw6 bb b--black-20 tl pb3 pr3 bg-white">Isbn</th>
            <th class="fw6 bb b--black-20 tl pb3 pr3 bg-white">Author</th>
            <th class="fw6 bb b--black-20 tl pb3 pr3 bg-white">Pages</th>
          </tr>
        </thead>
        <tbody class="lh-copy">
          <tr ng-repeat="book in books">
            <td><input class="f6 link dim br3 ph3 pv2 mb2 dib white bg-black" type="button" value="Delete" data-ng-click="del_book(book)"></td>
            <td>{{book.name}}</td>
            <td>{{book.isbn}}</td>
            <td>{{book.author}}</td>
            <td>{{book.pages}}</td>
          </tr>
        </tbody>
      </table>
    </div>
    </div>
  </body>
</html>
EOF
cd books
nohup nodejs server.js &
exit

#delete
#az group delete --name $RES --yes