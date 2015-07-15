/*
Main function.
*/

import std.algorithm.searching;
import std.exception;
import std.file;
import std.json;
import std.path;
import std.stdio;

import outputsource;

unittest {
  JSONValue j = parseJSON(readText("language.json"));
  File tmp = File("test/temp", "w+");
  tmp.setvbuf(0, _IONBF); // No need to flush after every write.
  FILE* t = tmp.getFP();

  void
  testLanguage(in string ext) {
    File f = File(setExtension("test/in", ext), "r");
    outputSource(f.getFP(), j[sourceLanguage(ext)].object(), t);
    assert(startsWith(readText("test/temp"),
        readText(setExtension("test/out", ext))));
    tmp.rewind();
  }
  testLanguage(".c"); // clang
  testLanguage(".py"); // python

  tmp.close();
  std.file.remove("test/temp");
}

/*
Map extensions to languages.
*/
string
sourceLanguage(in string ext) {
  JSONValue j = parseJSON(readText("extensions.json"));
  if(ext in j.object()) {
    return j[ext].str();
  }
  return "clang"; // Assume part of C family by default.
}

void
main(string[] args) {
  enforce(args.length > 1, "Too few arguments.");

  File f = File(args[1], "r");
  JSONValue j = parseJSON(readText("language.json"));

  string ext = extension(args[1]);
  outputSource(f.getFP(), j[sourceLanguage(ext)].object());
}
