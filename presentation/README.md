# Presentation for Programming Machine Learning Algorithms in Hardware, sanely, using Haskell and Rust!

Interactively editing the presentation
--------------------------------------

Inside this folder, you can run

```
nix-shell --pure --run "make watch"
```

from this folder to compile the presentation any time any changes are made to
the markdown file, or any file in `fig` is altered. If you are using a PDF
viewer for the resulting file (`SBTB-2020-Type-Safe-FPGA.pdf`), then the viewer
should update as soon as the compilation is finished.


Building the presentation
-------------------------

To build the presentation as it is done on the CI server, run `nix-build` from
this directory or `nix-build presentation` from the parent directory.
