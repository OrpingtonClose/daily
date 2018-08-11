#https://www.safaribooksonline.com/library/view/daniel-arbuckles-mastering/9781787283695/bc97ee75-7735-4861-9233-7bed8f5226a9.xhtml
import flask.views
from flask import Flask
import json
method_not_allowed = 405
app = Flask(__name__)

#A class-based view that dispatches request methods to the corresponding
#class methods. For example, if you implement a ``get`` method, it will be
#used to handle ``GET`` requests. ::
class Endpoint(flask.views.MethodView):
    #405 Method Not Allowed
    #The method received in the request-line is known by the origin server but not supported by the target resource.
    #The origin server MUST generate an Allow header field in a 405 response containing a list of the target resource's currently supported methods.
  def post(self):
    flask.abort(method_not_allowed)

  def get(self, id):
    flask.abort(method_not_allowed)

  def put(self, id):
    flask.abort(method_not_allowed)

  def delete(self, id):
    flask.abort(method_not_allowed)

#  @classmethod
#  def register(class_, app, base):
#as_view(name, *class_args, **class_kwargs) from flask.views.MethodViewType
#Converts the class into an actual view function that can be used
#with the routing system.  Internally this generates a function on the
#    view = class_.as_view(class_.__name__)
#    res_name = class_.__name__.lower()
#    post_uri = '{}'.format(res_name)
#    other_uri = '{}/<int:id>'.format(post_uri)
#    print(post_uri)
#    print(other_uri)
#    app.add_url_rule(post_uri, view_func = view, methods=['POST'])
#    app.add_url_rule(other_uri, view_func = view, methods=['GET', 'PUT', 'DELETE'])

class Hello(Endpoint):
  def get(self, id):
    return json.dumps("hello"), 200, {'Content-Type': 'application/json'}

if __name__ == '__main__':
#https://flask-docs-ja.readthedocs.io/en/latest/views/
  res_name = Hello.__name__.lower()
  view = Hello.as_view(res_name)
  post_uri = '/{}'.format(res_name)
  other_uri = '{}/<int:id>'.format(post_uri)
  print(post_uri)
  print(other_uri)
  app.add_url_rule(post_uri, view_func = view, methods=['POST'])
  app.add_url_rule(other_uri, view_func = view, methods=['GET', 'PUT', 'DELETE'])
  app.run(debug=True)
