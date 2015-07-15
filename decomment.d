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
  File f;

  // clang
  f = File("test/in.c", "r");
  outputSource(f.getFP(), j["clang"].object(), t);
  assert(startsWith(readText("test/temp"), readText("test/out.c")));
  tmp.rewind();

  // python
  f = File("test/in.py", "r");
  outputSource(f.getFP(), j["python"].object(), t);
  assert(startsWith(readText("test/temp"), readText("test/out.py")));
  tmp.rewind();

  tmp.close();
  std.file.remove("test/temp");
}

/*
Map extensions to languages.
*/
string
sourceLanguage(string filename) {
  string ext = extension(filename);
  JSONValue j = parseJSON(readText("extensions.json"));
  if(ext in j.object()) {
    return j[ext].str();
  }
  return "clang";
}

void
main(string[] args) {
  enforce(args.length > 1, "Too few arguments.");

  File f = File(args[1], "r");
  JSONValue j = parseJSON(readText("language.json"));

  outputSource(f.getFP(), j[sourceLanguage(args[1])].object());
}
