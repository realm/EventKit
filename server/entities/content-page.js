const Realm = require('realm');
const { ContentElement } = require('./content-element');

function ContentPage() { }

ContentPage.schema = {
  name: 'ContentPage',
  primaryKey: 'uuid',
  properties: {
    title: {type: 'string', optional: true},
    elements: {type: 'list', objectType: 'ContentElement'},
    priority: {type: 'int', default: 0, indexed: true},
    mainColor: {type: 'string', optional: true},
    lang: {type: 'string', optional: true},
    tag: {type: 'string', indexed: true},
    uuid: {type: 'string'}
  }
};

exports.ContentPage = ContentPage;
