"""
Purpose: B2 Flask App
Author:  Ken Youens-Clark <kyclark@email.arizona.edu>
"""

from bson.json_util import dumps
from flask import Flask
from pymongo import MongoClient
from flask_cors import CORS

app = Flask(__name__)
CORS(app)
url = 'mongodb://localhost:27017/'
db = 'b2_project'
client = MongoClient(url)
mongo_db = client[db]


@app.route('/experiments')
def experiments_list():
    """List experiments"""

    # experiment_date_time
    flds = ('sample_id sample_type run_name experiment_type level '
            'operator protocol_id').split()
    proj = {f: 1 for f in flds}
    return dumps(list(mongo_db['experiment'].find({}, proj)))


@app.route('/experiment/<sample_id>')
def experiment_view(sample_id):
    """View a single experiment"""
    # experiment_date_time
    flds = ('sample_id sample_type run_name experiment_type level '
            'operator protocol_id').split()
    proj = {f: 1 for f in flds}

    res = mongo_db['experiment'].find_one({'sample_id': sample_id}, proj)

    return dumps(res or {})
