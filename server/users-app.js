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

const fs = require('fs');
const path = require('path');
const Realm = require('realm');
const util = require('util');
const uuidV1 = require('uuid/v1');

const params = require('optimist')
  .usage("Usage: $0 --host [string] --port [num] --username [string] --password [string] \n\n" +
    "  --command readonly --to [user_id] : gives the user read-only access to the event realm\n"
  )
  .demand(['host', 'port', 'username', 'password', 'command'])
  .default('port', 9080)
  .argv;

const scriptPath = process.argv.slice(1);

Realm.Sync.setLogLevel('error');

print('Granting read permission to '+params.to);

Realm.Sync.User.login('http://'+params.host+':'+params.port, params.username, params.password)
  .then((user)=>{
      print('Logged in as '+params.username);

      const condition = {userId: params.to};
      const realmUrl = 'realm://'+params.host+':'+params.port+'/'+user.identity+'/eventblank';
    
      print('Grant read to '+params.to+ ' file '+realmUrl);

      user.applyPermissions(condition, realmUrl, 'write')
        .then( (permission) => {
            print('permission granted on '+realmUrl);
            print(permission);
            setTimeout(process.exit, 5000);
        })
        .catch( error => {
          print(error);
        });
  }).catch( error => {
    print(error);
  });
