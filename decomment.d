/*
Main function.
*/

import std.algorithm.searching;
import std.exception;
import std.file;
import std.json;
import std.path;
import std.stdio;

import comments;
import quotes;

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

struct DelegatePair {
  bool delegate(int) key;
  void delegate(int) value;
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

/*
Print a source file without its comments.
*/
void
outputSource(FILE* source, JSONValue[string] language,
    FILE* dst = core.stdc.stdio.stdout) {

  DelegatePair[] actions;

  if("quotes" in language) { // The language has typical quotes.
    auto k = (int c)=>startOfQuote(source, language, c);
    auto v = (int c)=>outputQuote(source, language, c, dst);
    actions ~= DelegatePair(k, v);
  }
  if("line" in language) { // The language has line comments.
    auto k = (int c)=>startOfComment(source, language["line"].str(), c);
    auto v = (int c)=>skipLineComment(source, dst);
    actions ~= DelegatePair(k, v);
  }
  if("block_start" in language) { // The language has block comments.
    auto k = (int c)=>startOfComment(source, language["block_start"].str(), c);
    auto v = (int c)=>skipBlockComment(source, language["block_end"].str(), dst);
    actions ~= DelegatePair(k, v);
  }
  // By default, print the character.
  actions ~= DelegatePair((int c)=>true, (int c)=> cast(void)putc(c, dst));

  while(true) {
    int c = getc(source);
    if(c == -1) {
      return;
    }
    foreach(DelegatePair d; actions) {
      if(d.key(c)) {
        d.value(c);
        break;
      }
    }
  }
}

void
main(string[] args) {

  enforce(args.length > 1, "Too few arguments.");

  File f = File(args[1], "r");
  JSONValue j = parseJSON(readText("language.json"));

  outputSource(f.getFP(), j[sourceLanguage(args[1])].object());
}
