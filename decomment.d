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

/*
Print a source file without its comments.
*/
void
outputSource(FILE* source, JSONValue[string] language,
    FILE* dst = core.stdc.stdio.stdout) {
  while(true) {
    int c = getc(source);
    if(c == -1) {
      return;
    }
    if(startOfQuote(source, language, c)) {
      debug(quotes) { printf("\n--Start of quote: %c--\n", c); }
      outputQuote(source, language, c, dst);
      debug(quotes) { writeln("\n--End of quote--"); }
    } else if(startOfComment(source, language["line"].str(), c)) {
      skipLineComment(source, dst);
    } else if(startOfComment(source, language["block_start"].str(), c)) {
      skipBlockComment(source, language["block_end"].str(), dst);
    } else {
      putc(c, dst);
    }
  }
}

void
main(string[] args) {

  enforce(args.length > 1, "Too few arguments.");

  File f = File(args[1], "r");
  JSONValue j = parseJSON(readText("language.json"));

  // TODO: Pick language based on extension.
  outputSource(f.getFP(), j["clang"].object());
}
