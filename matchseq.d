/*
Generic functions to match a sequence of characters.
*/

import std.json;
import std.stdio;

bool
matchSequence(FILE* src, in string seq) {
  int[] nextChars;
  bool mismatch = false;
  int i;

  nextChars = new int[seq.length];
  for(i=0; i<nextChars.length; i++) {
    nextChars[i] = getc(src);
    if(nextChars[i] != seq[i]) {
      mismatch = true;
      i++;
      break;
    }
  }

  for(i--;i>=0;i--) {  // Put every character back.
    if(nextChars[i] != -1) { ungetc(nextChars[i], src); }
  }

  return !mismatch;
}

bool
matchAnySequence(FILE* src, in JSONValue[] seqs) {
  foreach(JSONValue j; seqs) {
    if(matchSequence(src, j.str())) {
      return true;
    }
  }
  return false;
}