function Speaker() { }

Speaker.schema = {
  name: 'Speaker',
  primaryKey: 'uuid',
  properties: {
    uuid: {type: 'string'},
    visible: {type: 'bool'},
    name: {type: 'string'},
    bio: {type: 'string', optional: true},
    url: {type: 'string', optional: true},
    twitter: {type: 'string', optional: true},
    photoUrl: {type: 'string', optional: true}
  }
};

exports.Speaker = Speaker;