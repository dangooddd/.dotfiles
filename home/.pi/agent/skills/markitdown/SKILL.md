---
name: markitdown
description: Convert documents like PDF, DOCX, XLSX, and PPTX to Markdown with the `markitdown` Python utility.
compatibility: Requires shell access and a working `markitdown` executable on PATH.
---

# Convert documents to Markdown format

## Usage

Examples of usage:

```bash
markitdown document.pdf  # write to stdout
markitdown document.pdf -o document.md  # write to file
markitdown --help  # other capabilities
```

- Prefer writing converted output to stdout for temporary work.
- Use `-o <file>.md` only when you need to inspect the result in multiple passes.
- Supported formats: PDF, DOCX, XLSX, PPTX, HTML, CSV, JSON, XML, EPUB.
