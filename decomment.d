/*
Main function.
*/

import std.exception;
import std.file;
import std.json;
import std.stdio;

void
main(string[] args) {

  enforce(args.length > 1, "Too few arguments.");

  File f = File(args[1], "r");
  FILE* source = f.getFP();

  JSONValue j = parseJSON(readText("language.json"));
  // TODO: Pick language based on extension.
  JSONValue[string] language = j["clang"].object();

  while(!f.eof()) {
    int c = getc(source);
    if(startOfQuote(source, language, c)) {
      outputQuote(source, language, c);
    } else {
      putchar(c);
    }
  }

}

bool
startOfQuote(FILE* source, in JSONValue[string] language, in int c) {
  return true;
}

void
outputQuote(FILE* source, in JSONValue[string] language, in int c) {
  putchar(c);
}