#sudo -H pip3 install Flask-Restful
from flask import Flask, request
from flask_restful import Api, Resource
app = Flask(__name__)
api = Api(app)

class HelloWorld(Resource):
  def get(self):
    return {'hello': 'world'}

api.add_resource(HelloWorld, '/')

things = ['hello', 'there', 'friend']

class Thing(Resource):
  def get(self, thing_id):
    return things[thing_id]
  
  #curl 127.0.0.1:5000/thing/2
  #curl 127.0.0.1:5000/thing/2 -X PUT -d "NOT THIS"
  #curl 127.0.0.1:5000/thing/2
  def put(self, thing_id):
    from flask_restful import reqparse
    parser = reqparse.RequestParser()
    parser.add_argument('data', type=str, help="freeform string pleas")
    args = parser.parse_args()
    things[thing_id] = args['data']
    #things[thing_id] = request.form['data']
    return things[thing_id]

api.add_resource(Thing, '/thing', '/thing/<int:thing_id>')

from flask_restful import fields, marshal_with

resource_fields = { 
  'something': fields.String,
  'uri': fields.Url('herp')
}

class Merp():
  def __init__(self):
    self.something = "excellent"
    self.other = "incredible"

class Herp(Resource):
  @marshal_with(resource_fields)
  def get(self):
    return Merp()

api.add_resource(Herp, '/herp', endpoint='herp')

if __name__ == '__main__':
  app.run(debug=True)

