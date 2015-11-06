/*
Generic functions to match a sequence of characters.
Consumes matching characters.
*/

import std.json;
import std.stdio;

bool
matchSequence(FILE* src, in string seq, in int first) {
  int[] nextChars;
  bool broke;
  int i;

  if(first != seq[0]) { return false; }
  if(seq.length == 1) { return true; } // Dealt with one character cases.

  // Check the next 2 to n characters of the sequence.
  nextChars = new int[seq.length-1];
  for(i=0; i<nextChars.length; i++) {
    nextChars[i] = getc(src);
    if(nextChars[i] != seq[i+1]) { // Mismatch.
      broke = true;
      break;
    }
  }

  if(broke) { // Have to put every character back.
    for(;i>=0;i--) {
      if(nextChars[i] !=_F_EOF) { ungetc(nextChars[i], src); }
    }
    return false;
  }
  return true; // Match!
}

bool
matchAnySequence(FILE* src, in JSONValue[] seqs, in int c) {
  foreach(JSONValue j; seqs) {
    if(matchSequence(src, j.str(), c)) {
      return true;
    }
  }
  return false;
}