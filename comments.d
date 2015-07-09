/*
Functions to check and process quotes.
*/

import std.stdio;

/*
Check for the start of a comment.
Currently assumes sequences are two characters long.
*/
bool
startOfComment(FILE* source, in string commentSequence, in int first) {
  if(first != commentSequence[0]) {
    return false;
  }
  int c = getc(source);
  if(c == commentSequence[1]) {
    return true;
  }
  // At this point we know it's not a comment.
  if(c != _F_EOF) {
    ungetc(c, source);
  }
  return false;
}

/*
Skip to the end of the line.
*/
void
skipLineComment(FILE* source, FILE* dst) {
  while(true) {
    int c = getc(source);
    if(c == '\n') {
      putc('\n', dst);
      return;
    }
    if(c == -1) {
      return;
    }
  }
}

/*
Skip to the end of the block comment.
*/
void
skipBlockComment(FILE* source, in string endCommentSequence, FILE* dst) {
  while(true) {
    int c = getc(source);
    if(c == -1) {
      return;
    }
    if(c == endCommentSequence[0]) {
      c = getc(source);
      if(c == endCommentSequence[1]) {
        putc(' ', dst); // Allows block comments to separate tokens.
        return;
      } else if(c != -1) {
        ungetc(c, source);
      }
    }
  }
}