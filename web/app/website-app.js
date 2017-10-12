'use strict';

const fs = require('fs');
const path = require('path');
const Realm = require('realm');
const util = require('util');

const { Website } = require('./src/website.js');

const { EventData } = require('./src/entities/event-data');
const { Speaker } = require('./src/entities/speaker');
const { Session } = require('./src/entities/session');
const { Location } = require('./src/entities/location');
const { Track } = require('./src/entities/track');
const { ContentPage } = require('./src/entities/content-page');
const { ContentElement } = require('./src/entities/content-element');
const { Token } = require('./src/token.js');

//
// global functions
//
global.print = function (line) { 
  if (typeof line === 'string' || line instanceof String) {
    console.log('[app] ' + line);
  } else {
    console.log(util.inspect(line, false, null));
  }
}

global.fatalError = function (error, message) {
  console.log('Error: ['+error.errorCode+'] '+error.message + '; '+message);
  process.exit();
}

const params = require('optimist')
.usage("Usage: $0 --host [string] --port [num] --username [string] --password [string] \n\n" +
  "  --tokenpath [string] --outputpath [string] \n\n" +
  "  --templatepath [string] --admintokenpath [string]\n"
)
.demand(['host', 'port', 'username', 'password', 'tokenpath', 'outputpath', 'templatepath', 'admintokenpath'])
.default('port', 9080)
.argv;

// read admin, access, and credential tokens
const tokens = new Token();
tokens.load('access', params.tokenpath);
tokens.load('admin', params.admintokenpath);

// Authorize Realm Object Server
Realm.Sync.setAccessToken(tokens.get('access'));
Realm.Sync.setLogLevel('error');

// login to ROS
var currentUser;
Realm.Sync.User.login('http://'+params.host+':'+params.port, params.username, params.password)
  .then((user) => {
    print('Logged in as '+params.username);
    currentUser = user;
    
    return Realm.open({
      sync: {
        user: user,
        url: 'realm://'+params.host+':'+params.port+'/~/eventblank',
      },
      schema: [EventData, Speaker, Session, Location, Track, ContentPage, ContentElement],
      schemaVersion: 1
    })
  })
  .then((realm) => {
    const web = new Website(realm, currentUser, params, tokens);
    web.run(params.outputpath);
  })
  .catch( error => {
    print(error);
  });
