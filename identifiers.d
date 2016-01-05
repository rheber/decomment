/*
Functions and structure for printing identifiers.
*/

import std.ascii;
import std.bitmanip;
import std.stdio;

struct CharTypes {
  mixin(bitfields!(
    bool, "letter", 1,
    bool, "underscore", 1,
    bool, "digit", 1,
    bool, "bang", 1,
    bool, "", 4 /* padding */
  ));
}

/*
True if next char belongs to one of a set of types.
*/
bool
matchchar(FILE* src, CharTypes ct) {
  bool matched = false;
  int c = getc(src);
  if(c == -1) { return false; }

  if(ct.letter)     { matched |= isAlpha(c); }
  if(ct.underscore) { matched |= (c == '_'); }
  if(ct.digit)      { matched |= isDigit(c); }
  if(ct.bang)       { matched |= (c == '!'); }

  ungetc(c, src);
  return matched;
}

void
printIdentifier(FILE* src, CharTypes ct, FILE* dst) {
  putc(getc(src), dst);
  while(true) {
    if(matchchar(src, ct)) {
      putc(getc(src), dst);
    } else {
      return;
    }
  }
}