/*
Functions to process comments.
*/

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
    if(c == -1) {
      return;
    }
  }
}

/*
Skip to the end of the block comment.
*/
void
skipBlockComment(FILE* src, in string endCommentSequence, FILE* dst) {
  while(true) {
    int c = getc(src);
    if(c == -1) {
      return;
    }
    if(c == endCommentSequence[0]) {
      c = getc(src);
      if(c == endCommentSequence[1]) {
        putc(' ', dst); // Allows block comments to separate tokens.
        return;
      } else if(c != -1) {
        ungetc(c, src);
      }
    }
  }
}