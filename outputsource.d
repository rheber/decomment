/*
The functions that do the heavy lifting.
*/

import std.json;
import std.stdio;

import comments;
import matchseq;
import quotes;

/*
Print a source file without its comments.
*/
void
outputSource(FILE* src, JSONValue[string] language,
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
    (int c)=>matchAnySequence(src, language["trip"].array(), c),
    (int c)=>outputTrip(src, language, c, dst));
  possiblyAddAction("quotes", // The language has typical quotes.
    (int c)=>matchAnySequence(src, language["quotes"].array(), c),
    (int c)=>outputQuote(src, language, c, dst));
  possiblyAddAction("line", // The language has line comments.
    (int c)=>matchSequence(src, language["line"].str(), c),
    (int c)=>skipLineComment(src, dst));
  possiblyAddAction("block_start", // The language has block comments.
    (int c)=>matchSequence(src, language["block_start"].str(), c),
    (int c)=>skipBlockComment(src, language["block_end"].str(), dst));
  // By default, print the character.
  actions ~= DelegatePair((int c)=>true, (int c)=> cast(void)putc(c, dst));

  while(true) {
    int c = getc(src);
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
