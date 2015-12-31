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
outputSource(FILE* src, JSONValue[string] lang,
    FILE* dst = core.stdc.stdio.stdout) {

  struct DelegatePair {
    bool delegate() key;
    void delegate() value;
  }
  DelegatePair[] actions;

  void
  possiblyAddAction(string feature, bool delegate() k, void delegate() v) {
    if(feature in lang) {
      actions ~= DelegatePair(k, v);
    }
  }

  possiblyAddAction("trip", // The language has Pythonic triple quotes.
    ()=>matchAnySequence(src, lang["trip"].array()),
    ()=>outputTrip(src, lang, dst));
  possiblyAddAction("quotes", // The language has typical quotes.
    ()=>matchAnySequence(src, lang["quotes"].array()),
    ()=>outputQuote(src, lang, dst));
  possiblyAddAction("line", // The language has line comments.
    ()=>matchSequence(src, lang["line"].str()),
    ()=>skipLineComment(src, dst));
  possiblyAddAction("block_start", // The language has block comments.
    ()=>matchSequence(src, lang["block_start"].str()),
    ()=>skipBlockComment(src, lang, dst));
  possiblyAddAction("nest_start", //The language has nesting block comments.
    ()=>matchSequence(src, lang["nest_start"].str()),
    ()=>skipNestingComment(src, lang, dst));
  // By default, print the character.
  actions ~= DelegatePair(()=>true, ()=> cast(void)putc(getc(src), dst));

  while(true) {
    int c = getc(src);
    if(c == -1) { return; }
    ungetc(c, src);
    foreach(DelegatePair d; actions) {
      if(d.key()) {
        d.value();
        break;
      }
    }
  }
}
