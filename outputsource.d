/*
The functions that do the heavy lifting.
*/

import std.json;
import std.stdio;

import comments;
import quotes;

/*
Print a source file without its comments.
*/
void
outputSource(FILE* source, JSONValue[string] language,
    FILE* dst = core.stdc.stdio.stdout) {

  struct DelegatePair {
    bool delegate(int) key;
    void delegate(int) value;
  }
  DelegatePair[] actions;

  void
  possiblyAddAction(string feature, bool delegate(int) k, void delegate(int) v) {
    if(feature in language) {
      actions ~= DelegatePair(k, v);
    }
  }

  possiblyAddAction("trip", // The language has Pythonic triple quotes.
    (int c)=>startOfTrip(source, language, c),
    (int c)=>outputTrip(source, language, c, dst));
  possiblyAddAction("quotes", // The language has typical quotes.
    (int c)=>startOfQuote(source, language, c),
    (int c)=>outputQuote(source, language, c, dst));
  possiblyAddAction("line", // The language has line comments.
    (int c)=>startOfComment(source, language["line"].str(), c),
    (int c)=>skipLineComment(source, dst));
  possiblyAddAction("block_start", // The language has block comments.
    (int c)=>startOfComment(source, language["block_start"].str(), c),
    (int c)=>skipBlockComment(source, language["block_end"].str(), dst));
  // By default, print the character.
  actions ~= DelegatePair((int c)=>true, (int c)=> cast(void)putc(c, dst));

  while(true) {
    int c = getc(source);
    if(c == -1) {
      return;
    }
    foreach(DelegatePair d; actions) {
      if(d.key(c)) {
        d.value(c);
        break;
      }
    }
  }
}
