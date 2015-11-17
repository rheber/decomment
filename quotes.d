/*
Functions to process quotes.
*/

import std.json;
import std.stdio;

/*
Print to the end of a quote.
Assumes escape and quote sequences are one character long and
quotes begin and end with the same character.
*/
void
outputQuote(FILE* source, in JSONValue[string] language, in int start, FILE* dst) {
  bool escaped = false;

  putc(start, dst);
  while(true) {
    int c = getc(source);
    if(c == -1) {
      return;
    }
    putc(c, dst);
    if(c == language["escape"].str()[0]) {
      escaped = !escaped;
    } else if(c == start && !escaped) {
      return;
    } else {
      escaped = false;
    }
  }
}

/*
Print to the end of a triple quote.
Assumes escape sequences are one character long.
Assumes all three characters in the quote sequence are equal.
*/
void
outputTrip(FILE* src, in JSONValue[string] language, in int start, FILE* dst) {
  bool escaped = false;
  putc(start, dst);
  putc(start, dst);
  putc(start, dst);

  while(true) {
    int c = getc(src);
    if(c == -1) {
      return;
    }
    putc(c, dst);
    if(c == language["escape"].str()[0]) {
      escaped = !escaped;
    } else if(c == start && !escaped) {
      // Check next two characters.
      int c2 = getc(src);
      int c3 = getc(src);
      if(c == c2 && c == c3) {
        putc(c, dst);
        putc(c, dst);
        return;
      }
      if(c3 != _F_EOF) {
        ungetc(c3, src);
      }
      if(c2 != _F_EOF) {
        ungetc(c2, src);
      }
    } else {
      escaped = false;
    }
  }
}