/*
Main function.
*/

import std.file;
import std.stdio;

void main(string[] args) {

  if(args.length < 2) {
    throw new Exception("Too few arguments.");
  }

  File f = File(args[1], "r");
  FILE* source = f.getFP();

  while(!f.eof()) {
    int c = getc(source);
    putchar(c);
  }

}