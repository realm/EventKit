function EventData() { }

EventData.schema = {
  name: 'EventData',
  properties: {
    title: {type: 'string'},
    subtitle: {type: 'string'},
    organizer: {type: 'string'},
    logoUrl: {type: 'string', optional: true},
    _mainColor: {type: 'string'},
    timeZone: {type: 'string'}
  }
};

EventData.defaultEvent = function(realm) {
  return realm.objects('EventData')[0];
}

exports.EventData = EventData;
