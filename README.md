# B2 Drought Web Interface

* Backend: Node/JS, Mongo
* Frontend: Elm

# Mongo

Mongo per https://docs.mongodb.com/manual/tutorial/install-mongodb-on-os-x/:

````
$ brew tap mongodb/brew
$ brew install mongodb-community@4.0
$ mongod --config /usr/local/etc/mongod.conf (foreground)
or
$ brew services start mongodb-community@4.0 (background)
$ mongo b2
````

Export collections on lytic:

````
$ for coll in experiment specimen; do mongoexport --db b2_project --collection $coll --out b2_${coll}.json; done
$ tar cvzf b2.tgz b2_*.json
````

Import locally:

````
$ for coll in experiment specimen; do mongoimport --db b2_project --collection $coll b2_${coll}.json; done
````

# Backend

````
$ cd backend
$ npm install
$ DEBUG=backend:* npm start
````

# Author

Ken Youens-Clark <kyclark@email.arizona.edu>
