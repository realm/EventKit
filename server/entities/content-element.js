function ContentElement() { }

ContentElement.schema = {
  name: 'ContentElement',
  properties: {
      type: {type: 'string', default: 'p'},
      content: {type: 'string', default: ''},
      url: {type: 'string', optional: true}
  }
};

exports.ContentElement = ContentElement;
