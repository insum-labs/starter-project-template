/**
 * Fills in the auto generated release items (views and packages now)
 *
 * Run: node release.js <release file>
 * Note: Run in the releases folder
 *
 * Parameters
 *  release file: File to replace the auto generated list
 *
 * Ensure that code has a block at end labeled:
 *
 * -- AUTOREPLACE_START
 * -- AUTOREPLACE_END
 *
 */
var fs = require('fs');
var path = require('path');

// Find index at end of param string (not at start)
String.prototype.indexOfEnd = function(string) {
  var io = this.indexOf(string);
  return io == -1 ? -1 : io + string.length;
}

// Returns the prompt and compile directives
function getCompileObjStr(fileName, path, type){
  var returnStr = '';
  returnStr = 'PROMPT ' + fileName + '\n';

  if (type === 'view'){
    // Views need to be dropped before being re-created
    // This is due to some dependency issues when we apply some of the DBA support role grants on views
    returnStr += 'drop view ' + fileName.replace(/\.[^/.]+$/, "") + ";\n";
  }

  returnStr += '@../' + path + '/' + fileName + '\n';
  return returnStr;
}


var
  args = process.argv.slice(2), // Array of arguments
  arguments = {
    releaseFileName : args[0]
  },
  releaseFile = {
    fullPath : path.resolve('../' + arguments.releaseFileName),
    contents : ''
  }
  views = {
    path : path.resolve('../views/'),
    fileList : [],
    subStr : '\nPROMPT *** Views ***\n\nset sqlblanklines on\n\n',
    type : 'view'
  },
  packages = {
    path : path.resolve('../packages/'),
    fileList : [],
    subStr : '\nPROMPT *** Packages ***\n\n'
  },
  triggers = {
    path : path.resolve('../triggers/'),
    fileList : [],
    subStr : '\nPROMPT *** Triggers ***\n\n'
  },
  constants = {
    autoreplaceStart : '-- AUTOREPLACE_START',
    autoreplaceEnd : '-- AUTOREPLACE_END'
  }
;

// Views
views.fileList = fs.readdirSync(views.path);
views.fileList.forEach(function (val, i){
  // Ignore mac files
  if (['.svn','.DS_Store'].indexOf(val) === -1){
    views.subStr += getCompileObjStr(val, 'views', views.type);
  }
});
views.subStr += '\nset sqlblanklines off'

// Packages
packages.fileList = fs.readdirSync(packages.path);
//Compile Package Specs
packages.fileList.forEach(function(val, i){
  if (path.extname(val) === '.pls'){
    packages.subStr += getCompileObjStr(val, 'packages');
  }
});

//Compile Package body
packages.fileList.forEach(function(val, i){
  if (path.extname(val) === '.plb'){
    packages.subStr += getCompileObjStr(val, 'packages');
  }
});


// Triggers
triggers.fileList = fs.readdirSync(triggers.path);
triggers.fileList.forEach(function (val, i) {
  // Ignore mac files
  if (['.svn', '.DS_Store'].indexOf(val) === -1) {
    triggers.subStr += getCompileObjStr(val, 'triggers');
  }
});
triggers.subStr += '\nset sqlblanklines off'


//Replace file
releaseFile.contents = fs.readFileSync(releaseFile.fullPath, 'utf8');

//Validations
if(releaseFile.contents.indexOf(constants.autoreplaceStart) < 0){
  console.log('Missing', constants.autoreplaceStart);
  process.exit(1);
}
else if (releaseFile.contents.indexOf(constants.autoreplaceEnd) < 0 ){
  console.log('Missing', constants.autoreplaceEnd);
  process.exit(1);
}


//Remove everything in between auto generated code
releaseFile.contents =
  releaseFile.contents.slice(0,releaseFile.contents.indexOfEnd(constants.autoreplaceStart)) +
  '\n' +
  views.subStr + '\n' + packages.subStr + '\n' + triggers.subStr + '\n\n\n' +
  'PROMPT Compile invalid objects\n' +
  'begin\n dbms_utility.compile_schema(schema => user, compile_all => false); \n end; \n/\n' +
  releaseFile.contents.slice(releaseFile.contents.indexOf(constants.autoreplaceEnd));

fs.writeFileSync(releaseFile.fullPath, releaseFile.contents, 'utf8');
