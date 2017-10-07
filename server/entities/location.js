function Location() { }

Location.schema = {
  name: 'Location',
  properties: {
    location: {type: 'string'},
    locationDescription: {type: 'string'}
  }
};

Location.getAll = function (realm) {
    return realm.objects('Location').sorted('location');
}

exports.Location = Location;
