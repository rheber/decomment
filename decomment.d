/*
Main function.
*/

import std.exception;
import std.file;
import std.json;
import std.stdio;

import comments;
import quotes;

unittest {
  JSONValue j = parseJSON(readText("language.json"));
  File tmp = File("test/temp", "w+");
  FILE* t = tmp.getFP();

  // clang
  File f = File("test/in.c", "r");
  outputSource(f.getFP(), j["clang"].object(), t);
  tmp.flush();
  assert(readText("test/temp") == readText("test/out.c"));

  tmp.close();
  std.file.remove("test/temp");
}

struct DelegatePair {
  bool delegate(int) key;
  void delegate(int) value;
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

  // #TODO: Make "clang" default language".
  outputSource(f.getFP(), j["python"].object());
}
