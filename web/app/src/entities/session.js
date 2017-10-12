const moment = require('moment');

function Session() { }

Session.schema = {
  name: 'Session',
  primaryKey: 'uuid',
  properties: {
    uuid: {type: 'string'},
    visible: {type: 'bool'},
    title: {type: 'string'},
    sessionDescription: {type: 'string'},
    beginTime: {type: 'date', optional: true},
    lengthInMinutes: {type: 'int', default: 0},
    track: {type: 'Track', optional: true},
    location: {type: 'Location', optional: true},
    speaker: {type: 'Speaker', optional: true}
  }
};

exports.Session = Session;
