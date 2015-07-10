# README

Decomment removes comments from source files.

## Building

If you've installed D you can run `rdmd --build-only decomment`.

## Usage

For some source file "blorb.foo", run `decomment blorb.foo`.

## Workflow

To add a new language:

1. Add the language's details to language.json and its extension
(oh, let's call it ".foo") to extensions.json.

1. Modify the program logic if necessary to accommodate the new language,
then run `rdmd -unittest decomment` to ensure previous languages work correctly.

1. Add a test file test/in.foo, run `decomment test/in.foo > test/out.foo`
and add the corresponding unit test.