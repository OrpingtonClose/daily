#pip3 install flask
#pip3 install SQLAlchemy
#sudo -H pip3 install SQLAlchemy
#sudo -H pip3 install flask-sqlalchemy
import urllib.parse
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
#from sqlalchemy import create_engine

Server = 'xxxxxxxxxxxxxxx'
Database = 'xxxxxxxxxxxx'
Uid = 'xxxxxxxxxxxxxxxx'
Pwd = 'xxxxxxxxxxx'
con_string = 'Driver={ODBC Driver 17 for SQL Server};Server={};Database={};Uid={};Pwd={};Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;'.format(Server, Database, Uid, Pwd)
params = urllib.parse.quote_plus(con_string)

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = "mssql+pyodbc:///?odbc_connect={}".format(params)
db = SQLAlchemy(app)

from sqlalchemy import Column, Integer, String
class Chair(db.Model):
  __tablename__ = 'chairs'

  id = db.Column(db.Integer, primary_key=True)
  name = db.Column(db.String)
  excellence = db.Column(db.String)
  id_material = db.Column(db.Integer, db.ForeignKey('materials.id'))
#  material = db.relationship('Material', db.backref('chair'))

  def __repr__(self):
    return "<Chair(name={}, excellence={})>".format(self.name, self.excellence)

class Material(db.Model):
  __tablename__ = 'materials'
  id = db.Column(db.Integer, primary_key=True)
  name = db.Column(db.String(20), nullable=False)
  created_on = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
  #chairs = db.relationship('Chair', db.backref('materials'))

  def __repr__(self):
    return "<Material(name={})".format(self.name)

db.drop_all()
db.create_all()

from random import choice
from itertools import permutations
perms = [''.join(w) for w in permutations(['uh', 'zin', 'teler', 'buh', 'edd'])]
excellence_grading=['excellent', 'incredible', 'unearthly', 'delightful', 'bad']

wood = Material(name='wood')
db.session.add(wood)
db.session.commit()
for name in perms:
  record = {"name":name, "excellence":choice(excellence_grading)}
  db.session.add(Chair(id_material=wood.id, **record))
db.session.commit()

