/*
Functions to check and process quotes.
*/

import std.json;
import std.stdio;

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
Print to the end of a quote.
Assumes escape and quote sequences are one character long and
quotes begin and end with the same character.
*/
void
outputQuote(FILE* source, in JSONValue[string] language, in int start, FILE* dst) {
  bool escaped = false;

  putchar(start);
  while(true) {
    int c = getc(source);
    if(c == -1) {
      return;
    }
    putc(c, dst);
    if(c == language["escape"].str()[0]) {
      escaped = true;
    } else if(c == start && !escaped) {
      return;
    } else {
      escaped = false;
    }
  }
}