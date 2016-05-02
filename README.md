# Natural autoflow #

Natural autoflow is an Atom package that provides a more natural autoflow
than the official packge.
It ensures that no line is longer than the user defined line length by breaking
at periods, semicolons, question marks or exclamation marks.
It also breaks at commas when the comma is close to max line length.
This makes it easier to diff and merge files and makes the package suitable
for writes who are collaborating on LaTeX, Markdown, Doconce and other files.

The default keybinding is `ctrl+alt+q` on Linux and Windows and `ctrl+cmd+q` on
Mac. 
This will however conflict with the official autoflow package, which needs to
be disabled for natural-autoflow to enable its bindings.
Another option is to bind `natural-autoflow:reflow-selection` to something else,
like `ctrl+i` or `cmd+i`.
