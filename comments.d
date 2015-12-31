/*
Functions to process comments.
*/

import std.json;
import std.stdio;

/*
Skip to the end of the line.
*/
void
skipLineComment(FILE* src, FILE* dst) {
  while(true) {
    int c = getc(src);
    if(c == '\n') {
      putc('\n', dst);
      return;
    }
    if(c == -1) { return; }
  }
}

/*
Skip to the end of the block comment.
*/
void
skipBlockComment(FILE* src, in JSONValue[string] lang, FILE* dst) {
  string start = lang["block_start"].str();
  string end   = lang["block_end"].str();

  int i = start.length;
  while(i--) { getc(src); } // Skip opening sequence.

  while(true) {
    int c = getc(src);
    if(c == -1) { return; }
    if(c == end[0]) {
      c = getc(src);
      if(c == end[1]) {
        putc(' ', dst); // Allows block comments to separate tokens.
        return;
      } else if(c != -1) {
        ungetc(c, src);
      }
    }
  }
}

/*
Skip to the end of a nesting comment.
Assumes sequences are two characters long.
*/
void
skipNestingComment(FILE* src, in JSONValue[string] lang, FILE* dst) {
  string start = lang["nest_start"].str();
  string end   = lang["nest_end"].str();

  void
  skip() {
    while(true) {
      int c = getc(src);
      if(c == -1) { return; }
      if(c == start[0]) {
        c = getc(src);
        if(c == start[1]) {
          skip();
        } else if(c != _F_EOF) {
          ungetc(c, src);
        }
      } else if(c == end[0]) {
        c = getc(src);
        if(c == end[1]) {
          return;
        } else if(c != _F_EOF) {
          ungetc(c, src);
        }
      }
    }
  }

  int i = start.length;
  while(i--) { getc(src); } // Skip first opening sequence.
  putc(' ', dst); // Allow comments to separate tokens.
  skip();
}