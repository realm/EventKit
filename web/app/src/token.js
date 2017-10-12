//
// Configuration files
//

var fs = require('fs');

/**
 * Class to read tokens and confuration saved in files
 */ 
function Token() {
  this.contents = { };
}

// loads file's contents
Token.prototype.load = function(name, filePath) {
    this.contents[name] = fs.readFileSync(filePath, 'utf-8').toString().replace(/[\s\r\n\t]/g, '');
}

// returns file's contents
Token.prototype.get = function(name) {
    return this.contents[name];
}

exports.Token = Token;
