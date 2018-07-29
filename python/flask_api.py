from flask import Flask, request, jsonify, abort
from http import HTTPStatus
from random import randint
import json

dealer = Flask('Numbers')
@dealer.route('/')
def root():
  return jsonify('/random')

@dealer.route('/random')
def root_random():
  return jsonify('/random/integer')

@dealer.route('/random/integer/')
def deal():
  try:
    print(request.args)
    numbers = int(request.args.get('amount', 1))
  except Exception as ex:
    abort(HTTPStatus.BAD_REQUEST)
  response = jsonify({ 
    "args": { 'amount': request.args.get('amount', 1) }, 
    'numbers': [randint(0, 1000000) for _ in range(numbers)]})
  return response

if __name__ == "__main__":
  dealer.run(use_reloader=True, debug=True, threaded=True)
