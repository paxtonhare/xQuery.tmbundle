# xQuery.tmbundle #

A MarkLogic XQuery bundle for Textmate.

# Install with Git: #
    mkdir -p ~/Library/Application\ Support/TextMate/Bundles
    cd ~/Library/Application\ Support/TextMate/Bundles
    git clone git://github.com/paxtonhare/xQuery.tmbundle
    osascript -e 'tell app "TextMate" to reload bundles'

# Features: #
* MarkLogic xquery extensions support "1.0-ml"
* Syntax highlighting for MarkLogic builtins
* Code completion for functions

## Snippets for writing code faster (activated with tab) ##
  * func  => inserts a function declaration
  * cp => inserts the codepoint collation "http://marklogic.com/collation/codepoint"
  * type => creates a typeswitch statement
  * import => creates a module import statement
  * ns => creates a namespace declaration
  * main => creates a stubbed main module
  * lib => creates a stubbed library module

## Commands ##
### Function completion  ⌥⎋
  Will complete built-ins as well as functions in modules have imported
  *Doesn't currently support xquery 0.9 synxtax*

### Run Xquery via XCC server ⌘R
  You must set the environment variables ML_SERVER and ML_USER in TextMate

### Wrap selected text with fn:data() ⌃⌥⌘D
  Highlight some text then press ⌃⌥⌘D to wrap the highlighted text with fn:data()

### Wrap selected text with fn:string() ⌃⌥⌘D
  Highlight some text then press ⌃⌥⌘D to wrap the highlighted text with fn:string()

Known Issues:
===
* Nested xml syntax highlighting is funky
* Bug in function completion. It mostly works though