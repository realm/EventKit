function Track() { }

Track.schema = {
  name: 'Track',
  properties: {
    track: {type: 'string'},
    trackDescription: {type: 'string'}
  }
};

Track.getAll = function (realm) {
    return realm.objects('Track').sorted('track');
}

exports.Track = Track;