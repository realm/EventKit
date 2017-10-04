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

// entities
const { EventData } = require('./entities/event-data');
const { Speaker } = require('./entities/speaker');
const { Session } = require('./entities/session');
const { Location } = require('./entities/location');
const { Track } = require('./entities/track');
const { ContentPage } = require('./entities/content-page');
const { ContentElement } = require('./entities/content-element');


const params = require('optimist')
  .usage("Usage: $0 --host [string] --port [num] --username [string] --password [string] --delete [yes|no] --amount [minimal|plenty]\n\n"
  )
  .demand(['host', 'port', 'username', 'password', 'amount'])
  .default('port', 9080)
  .argv;

const scriptPath = process.argv.slice(1);

Realm.Sync.setLogLevel('error');

print('Creating test data...');

Realm.Sync.User.login('http://'+params.host+':'+params.port, params.username, params.password)
  .then((user)=>{
    print("Connected.");

    Realm.open({
      sync: {
          user: user,
          url: 'realm://'+params.host+':'+params.port+'/~/eventblank',
      },
      schema: [EventData, Speaker, Session, Location, Track, ContentPage, ContentElement],
      schemaVersion: 1
      })
      .then(realm => {
        print('Opened realm file');
        createTestData(realm, user);
      });
  });

function createTestData(realm, user) {
  const hours = 60*60*1000;
  const today = new Date(new Date().getTime() + 10*24*hours);
  today.setHours(0,0,0,0);

  realm.write(()=> {
    if (params.delete == 'yes') {
      realm.deleteAll();
    }
    var event = realm.create('EventData', {title: 'A Test Conference!', subtitle: 'Paris, France', organizer: 'Awesome Host Company', logoUrl: 'https://raw.githubusercontent.com/realm-demos/EventBlank/master/assets/test-main-screen.jpg', _mainColor: '#152d46', timeZone: 'CET'});

    var location1 = realm.create('Location', {location: 'Web Room', locationDescription: ''})
    var track1 = realm.create('Track', {track: 'iOS', trackDescription: ''});

    if (params.amount == 'plenty') {
      var location2 = realm.create('Location', {location: 'Realm Room', locationDescription: ''})
      var track2 = realm.create('Track', {track: 'Android', trackDescription: ''});

      for (var d=0;d<3;d++) { // days
        var dayStartTime = today.getTime() + d * 24 * hours;
  
        for (var t=0;t<2;t++) { // track/location
          var track = [track1, track2][t];
          var location = [location1, location2][t];
    
          for (var i=0;i<6;i++) { // session/speaker
            var speakerData = getSpeaker();
            var speaker = realm.create('Speaker', {uuid: uuidV1({nsecs: random(10000)}), visible: true, name: speakerData.name, bio: speakerData.bio, twitter: speakerData.twitter, url: null, photoUrl: 'https://api.adorable.io/avatars/200/'+encodeURI(speakerData.name)});
            var sessionData = getSession();
            var session = realm.create('Session', {uuid: uuidV1({nsecs: random(10000)}), visible: true, title: sessionData.name, sessionDescription: sessionData.description, beginTime: new Date(dayStartTime + (8 + i) * hours), lengthInMinutes: 45, track: track, location: location, speaker: speaker});
          }
        }
      }
    } else {
      var speakerData = getSpeaker();
      var speaker = realm.create('Speaker', {uuid: uuidV1({nsecs: random(10000)}), visible: true, name: speakerData.name, bio: speakerData.bio, twitter: speakerData.twitter, url: null, photoUrl: 'https://api.adorable.io/avatars/200/'+encodeURI(speakerData.name)});
      var sessionData = getSession();
      var session = realm.create('Session', {uuid: uuidV1({nsecs: random(10000)}), visible: true, title: sessionData.name, sessionDescription: sessionData.description, beginTime: new Date(today.getTime() + 8 * hours), lengthInMinutes: 45, track: track1, location: location1, speaker: speaker});      
    }

    var about = realm.create('ContentPage', {title: 'About', priority: 100, tag: 'more', uuid: uuidV1({nsecs: random(10000)}), elements: [
      realm.create('ContentElement', {type: 'h2', content: 'About the event', url: null}),
      realm.create('ContentElement', {type: 'h3', content: randEl("Comparative Asynchronous Programming Modern Structural Architecture Data Real-time Symbiotic Synergy".split(" "), 2), url: null}),
      realm.create('ContentElement', {type: 'p', content: lorem(10), url: null})
    ]});

    if (params.amount == 'plenty') {
      var sponsors = realm.create('ContentPage', {title: 'Sponsors', priority: 10, tag: 'more', uuid: uuidV1({nsecs: random(10000)}), elements: [
        realm.create('ContentElement', {type: 'h2', content: 'Sponsors & Partners', url: null}),
        realm.create('ContentElement', {type: 'p', content: 'Meet the sponsors that are making this event possible.', url: null}),
        realm.create('ContentElement', {type: 'h3', content: 'DIAMOND SPONSORS', url: null}),
        realm.create('ContentElement', {type: 'img', content: 'https://raw.githubusercontent.com/realm-demos/EventBlank/master/assets/realm.png', url: 'https://realm.io'}),
        realm.create('ContentElement', {type: 'h3', content: 'GOLD SPONSORS', url: null}),
        realm.create('ContentElement', {type: 'img', content: 'https://raw.githubusercontent.com/realm-demos/EventBlank/master/assets/realm.png', url: 'https://realm.io'}),
        realm.create('ContentElement', {type: 'h3', content: 'SILVER SPONSORS', url: null}),
        realm.create('ContentElement', {type: 'img', content: 'https://raw.githubusercontent.com/realm-demos/EventBlank/master/assets/realm.png', url: 'https://realm.io'})
    ]});
    }
  })
  print('Completed.');
  setTimeout(process.exit, 5000);
}

function lorem(max) {
  return randEl("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse sit amet lacus condimentum, eleifend ante a, consectetur enim. Interdum et malesuada fames ac ante ipsum primis in faucibus. Aenean et lobortis est, nec congue sapien. Maecenas lectus libero, viverra sed vehicula ac, laoreet eget mi. Cras vitae libero ex. Donec feugiat lacus vel nunc convallis vestibulum et a erat. In pharetra libero vel bibendum laoreet. Sed congue arcu dolor, ac auctor quam ultricies a. Phasellus in lacinia augue. Phasellus tristique volutpat lobortis.".split("."), max);
}

function getSpeaker() {
  return {
    name: randEl(["John", "Ash", "Kristian", "Martin", "Matthijs", "Ara", "Maya", "Nadya"]) + " " + randEl(["Johnson", "Ivanov", "Seeth", "Djiihng", "Torrez", "Haffner"]),
    bio: lorem(2),
    twitter: randEl(["best", "good", "most", "very"]) + randEl(["best", "good", "most", "very"]) + randEl(["73", "35", "32", "19", "007"])
  }
}

function getSession() {
  return {
    name: randEl("Comparative Asynchronous Programming Modern Structural Architecture Data Real-time Symbiotic Synergy".split(" "), 2),
    description: lorem(5)
  }
}

function random(max) {
  return Math.floor(Math.random() * max);
}

function randEl(array) {
  var nr = parseInt(arguments[1]);
  if (!nr) nr = 1;

  var res = '';
  for (var i=0;i<nr;i++) {
    res += ' ' + array[random(array.length)];
  }
  return chomp(res);
}

function chomp(s)
{
  return s.replace(/[\n\r\s]+$/, '').replace(/^[\n\r\s]+/, '');
}