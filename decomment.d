/*
Main function.
*/

import std.exception;
import std.file;
import std.json;
import std.stdio;

void main(string[] args) {
/*
  enforce(args.length > 1, "Too few arguments.");

  File f = File(args[1], "r");
  FILE* source = f.getFP();

  while(!f.eof()) {
    int c = getc(source);
    putchar(c);
  }
*/

  JSONValue j = parseJSON(readText("language.json"));
  writeln(j);
}