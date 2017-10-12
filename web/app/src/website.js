const fs = require('fs-extra');
const path = require('path');
const Realm = require('realm');
const util = require('util');
const moment = require('moment');

const Handlebars = require('handlebars');

const { EventData } = require('./entities/event-data');
const { Speaker } = require('./entities/speaker');
const { Session } = require('./entities/session');
const { Location } = require('./entities/location');
const { Track } = require('./entities/track');
const { ContentPage } = require('./entities/content-page');
const { ContentElement } = require('./entities/content-element');

//
// Entity extensions
//
Speaker.getAll = function (realm) {
  return realm.objects('Speaker').filtered('visible = true').sorted('name');
}
Track.getAll = function (realm) {
  return realm.objects('Track').sorted('track');
}
Session.getAll = function (realm) {
  return realm.objects('Session').filtered('visible = true').sorted('beginTime');
}
Session.prototype.beginTimeReadable = function() {
  return moment(this.beginTime).format("MMM Do HH:mm");
}
Location.getAll = function (realm) {
  return realm.objects('Location').sorted('location');
}
EventData.defaultEvent = function(realm) {
  return realm.objects('EventData')[0];
}
ContentPage.getAll = function (realm) {
  return realm.objects('ContentPage').sorted([['priority', true], 'title']);
}
ContentPage.prototype.__wrapUrl = function (text, url) {
    if (!!url && url.length > 0) {
      return '<a href="'+url+'">' + text + '</a>';
    } else {
      return text;
    }
}
ContentPage.prototype.renderElements = function () {
    var res = '';
    for (var index in this.elements) {
      const el = this.elements[index];

      switch (el.type) {
        case 'h1': case 'h2': case 'h3': case 'h4': case 'p':
          res += this.__wrapUrl('<'+el.type+'>'+el.content+'</'+el.type+'>', el.url);
          break;
        case 'img':
          res += this.__wrapUrl('<'+el.type+' src="'+el.content+'"/>', el.url);
          break;
      }
    }
    return res;
}
//
// /Entity extensions
//
 
Handlebars.registerHelper('beginTimeReadable', function() {
    return this.beginTimeReadable();
});

Handlebars.registerHelper('renderElements', function() {
    return this.renderElements();
});

class Website {
    
    constructor(realm, user, params, tokens) {
        this.realm = realm;
        this.user = user;
        this.params = params;
        this.tokens = tokens;
        this.indexFileName = "index.html";
    }

    save(outputPath) {
        print('saving to: '+outputPath);

        const filterFunc = (src, dest) => {
            return !path.basename(src).startsWith('.');
        }

        try {
            // copy template over + overwrite index file
            fs.copySync(this.params.templatepath, outputPath, { filter: filterFunc });

            const data = this.__data();

            ['index.html', 'css/style.css'].forEach( (file)=> {
                const template = Handlebars.compile(this.__loadHtml(file));
                const output = template(data)
                fs.writeFileSync(outputPath+'/'+file, output);
            });
        } catch (err) {
            console.error(err)
        }
    }

    __loadHtml(file) {
        return fs.readFileSync(this.params.templatepath + '/' + file, 'utf-8').toString().trim();
    }

    __data() {
        const realm = this.realm;

        const event = EventData.defaultEvent(realm);
        const speakers = Speaker.getAll(realm);
        const sessions = Session.getAll(realm);
        const pages = ContentPage.getAll(realm);

        return {
            event: event,
            speakers: speakers,
            sessions: sessions,
            pages: pages
        }
    }

    run(outputPath) {
        this.save(outputPath);

        this.outputPath = outputPath;

        const adminUser = Realm.Sync.User.adminUser(this.tokens.get('admin'));
        const path = '^/.*/eventblank$';

        Realm.Sync.addListener('realm://'+this.params.host+':'+this.params.port, adminUser, path, 'change', this.__changeCallback.bind(this));
    }

    __changeCallback(event) {
        const path = event.path;
        if (event.path == '/'+this.user.identity+'/eventblank') {
            this.save(this.outputPath);
        }
    }
}

exports.Website = Website;
