'use strict';

var express = require('express');
var router = express.Router();
const assert = require('assert');
const Promise = require('promise');
const config = require('../config.json')
const MongoClient = require('mongodb').MongoClient;

function mongo() {
    return new Promise(function (resolve, reject) {
        MongoClient.connect(config.mongo.url, (err, db) => {
          if (err)
            reject(err)
          else
            resolve(db)
        });
    });
}

router.get('/', function (req, res) {
  mongo().then(function (db) {
    console.log(db);
    db.collection('experiment').find().toArray(function (err, results) {
      if (err) {
        console.log('error with find');
      } else {
        console.log(results);
      }
      db.close()
    });
    console.log('got collection');
  });

  res.send('Biosphere2 Drought Project - Hey');
});

//router.get('/', function (req, res) {
//  mongo().then(function(db) {
//    console.log('Connected!');
//    var coll = db.collection('experiment');
//    console.log(db);
//    coll.findOne({}, function (err, doc) {
//      if (err) {
//        console.log('error: ' + err)
//      } else {
//        console.log(doc);
//        db.close();
//        //console.log('experiment_type = ' + x.experiment_type);
//        //client.close();
//        //console.log('done');
//        //res.send('experiment_type = ' + res.experiment_type);
//        //res.send(doc)
//      }
//    })
//  });

//  res.send('Biosphere2 Drought Project');
//})

module.exports = router;
