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
const fs = require("fs");
const path = require("path");

const autoreplaceStart = "-- AUTOREPLACE_START";
const autoreplaceEnd = "-- AUTOREPLACE_END";

let generatedContent = "";

// Find index at end of param string (not at start)
String.prototype.indexOfEnd = function (string) {
  var io = this.indexOf(string);
  return io == -1 ? -1 : io + string.length;
};

// Returns the prompt and compile directives
const getGeneratedContent = (file, releaseObject) => {
  if (path.extname(file) === `.${releaseObject.extension}`) {
    let returnStr = `PROMPT ${file}\n`;

    if (releaseObject.type === "view") {
      // Views need to be dropped before being re-created
      // This is due to some dependency issues when we apply some of the DBA support role grants on views
      returnStr += `drop view ${file.replace(/\.[^/.]+$/, "")};\n`;
    }

    returnStr += `@${releaseObject.path}/${file};\n`;

    return returnStr;
  } else {
    return "";
  }
};

let args = process.argv.slice(2);

let releaseFile = {
  path: path.resolve(args[0]),
  contents: "",
};

let releaseObjects = [
  {
    type: "ddl",
    path: "./ddl",
    extension: "sql",
    pre: "\n\nPROMPT *** DDL ***\n\n",
  },
  {
    type: "views",
    path: "../views",
    extension: "sql",
    pre: "\n\nPROMPT *** Views ***\n\nset sqlblanklines on\n\n",
    post: "\n\nset sqlblanklines off\n\n",
  },
  {
    type: "packages",
    path: "../packages",
    extension: "pls",
    pre: "\n\nPROMPT *** Packages specs ***\n\n",
  },
  {
    type: "packages",
    path: "../packages",
    extension: "plb",
    pre: "\n\nPROMPT *** Packages body ***\n\n",
  },
  {
    type: "triggers",
    path: "../triggers",
    extension: "sql",
    pre: "\n\nPROMPT *** Triggers ***\n\nset sqlblanklines on\n\n",
    post: "\n\nset sqlblanklines off\n\n",
  },
  {
    type: "dml",
    path: "./dml",
    extension: "sql",
    pre: "\n\nPROMPT *** DML ***\n\n",
  },
];

releaseObjects.forEach((releaseObject) => {
  const files = fs.readdirSync(
    path.resolve(path.dirname(releaseFile.path), releaseObject.path)
  );

  if (releaseObject.pre) {
    generatedContent += releaseObject.pre;
  }

  files.forEach((file) => {
    generatedContent += getGeneratedContent(file, releaseObject);
  });

  if (releaseObject.post) {
    generatedContent += releaseObject.post;
  }
});

// Read release file
releaseFile.contents = fs.readFileSync(releaseFile.path, "utf8");

// Validations
if (releaseFile.contents.indexOf(autoreplaceStart) < 0) {
  console.log("Missing", autoreplaceStart);
  process.exit(1);
} else if (releaseFile.contents.indexOf(autoreplaceEnd) < 0) {
  console.log("Missing", autoreplaceEnd);
  process.exit(1);
}

// Replace everything in between autoreplaceStart and autoreplaceEnd
releaseFile.contents =
  releaseFile.contents.slice(
    0,
    releaseFile.contents.indexOfEnd(autoreplaceStart)
  ) +
  generatedContent +
  releaseFile.contents.slice(releaseFile.contents.indexOf(autoreplaceEnd));

// Write the file on disk
fs.writeFileSync(releaseFile.path, releaseFile.contents, "utf8");
