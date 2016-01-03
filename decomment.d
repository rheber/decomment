/*
Main function.
*/

import std.algorithm.searching;
import std.datetime;
import std.exception;
import std.file;
import std.getopt;
import std.json;
import std.path;
import std.stdio;

import outputsource;

unittest {
  JSONValue j = parseJSON(readText("language.json"));
  File tmp = File("test/temp", "w+");
  tmp.setvbuf(0, _IONBF); // No need to flush after every write.
  FILE* t = tmp.getFP();
  StopWatch sw;

  void
  testLanguage(in string ext) {
    File f = File(setExtension("test/in", ext), "r");
    outputSource(f.getFP(), j[sourceLanguage(ext)].object(), t);
    assert(startsWith(readText("test/temp"),
        readText(setExtension("test/out", ext))));
    tmp.rewind();
  }
  sw.start();
  testLanguage(".c");  // clang
  testLanguage(".hs"); // haskell
  testLanguage(".py"); // python
  sw.stop();
  printf("Tests completed in %dms\n", sw.peek().msecs);

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
  string lang = "";
  auto getoptData = getopt(
      args,
      "language|lang", "The source file's programming language", &lang
  );

  enforce(args.length > 1, "Too few arguments.");

  File f = File(args[1], "r");
  JSONValue j = parseJSON(readText("language.json"));

  try {
    outputSource(f.getFP(), j[lang].object());
  } catch(JSONException e) {
    if(lang != "") {
      stderr.writef("decomment: Language %s is not defined\n", lang);
    }
    string ext = extension(args[1]);
    outputSource(f.getFP(), j[sourceLanguage(ext)].object());
  }
}
