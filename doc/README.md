# Documentation for the source language

## How to prepare the documentation

The documentation is written in LaTeX. In order to compile the document you will need a TeX distribution. The recommended one is texlive. I suggest also using the latexmk tool, which eases the task of compiling LaTeX documents.

```
latexmk -pvc -pdf -output-directory=_build source-language
```

