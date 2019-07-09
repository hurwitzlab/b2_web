from bson.json_util import dumps
from flask import Flask
from pymongo import MongoClient

app = Flask(__name__)
url = 'mongodb://localhost:27017/'
db = 'b2_project'
client = MongoClient(url)
mongo_db = client[db]

@app.route('/experiments')
def experiments():
    return dumps(list(mongo_db['experiment'].find()))
