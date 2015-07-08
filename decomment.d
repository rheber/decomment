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
      debug(quotes) { printf("\n--Start of quote: %c--\n", c); }
      outputQuote(source, language, c);
      debug(quotes) { writeln("\n--End of quote--"); }
    } else if(startOfLineComment(source, language, c)) {
      skipLineComment(source);
    } else {
      putchar(c);
    }
  }

}

/*
Check if the given character starts a quote.
*/
bool
startOfQuote(FILE* source, in JSONValue[string] language, in int c) {
  foreach(JSONValue j; language["quotes"].array()) {
    if(c == j.str()[0]) { // Works if quote sequences are one character long.
      return true;
    }
  }
  return false;
}

/*
Check for the start of a line comment.
Currently assumes sequences are two characters long.
*/
bool
startOfLineComment(FILE* source, in JSONValue[string] language, in int first) {
  string commentSequence = language["line"].str();

  if(first != commentSequence[0]) {
    return false;
  }
  int c = getc(source);
  if(c == commentSequence[1]) {
    return true;
  }
  // At this point we know it's not a line comment.
  if(c != _F_EOF) {
    ungetc(c, source);
  }
  return false;
}

/*
Print to the end of a quote.
Assumes escape and quote sequences are one character long and
quotes begin and end with the same character.
*/
void
outputQuote(FILE* source, in JSONValue[string] language, in int start) {
  bool escaped = false;

  putchar(start);
  while(true) {
    int c = getc(source);
    if(c == -1) {
      return;
    }
    putchar(c);
    if(c == language["escape"].str()[0]) {
      escaped = true;
    } else if(c == start && !escaped) {
      return;
    } else {
      escaped = false;
    }
  }
}

/*
Skip to the end of the line.
*/
void
skipLineComment(FILE* source) {
  while(true) {
    int c = getc(source);
    if(c == '\n') {
      putchar('\n');
      return;
    }
    if(c == _F_EOF) {
      return;
    }
  }
}