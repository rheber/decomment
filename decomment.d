/*
Main function.
*/

import std.exception;
import std.file;
import std.json;
import std.stdio;

import comments;
import quotes;

/*
Print a source file without its comments.
*/
void
outputSource(FILE* source, JSONValue[string] language) {
  while(true) {
    int c = getc(source);
    if(c == -1) {
      return;
    }
    if(startOfQuote(source, language, c)) {
      debug(quotes) { printf("\n--Start of quote: %c--\n", c); }
      outputQuote(source, language, c);
      debug(quotes) { writeln("\n--End of quote--"); }
    } else if(startOfComment(source, language["line"].str(), c)) {
      skipLineComment(source);
    } else if(startOfComment(source, language["block_start"].str(), c)) {
      skipBlockComment(source, language["block_end"].str());
    } else {
      putchar(c);
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
