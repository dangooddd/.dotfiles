---
name: markitdown
description: Convert documents like PDF, DOCX, XLSX, and PPTX to Markdown with the `markitdown` Python utility.
compatibility: Requires shell access and a working `markitdown` executable on PATH.
---

# MarkItDown

## Overview

Use this skill when you need to convert documents to Markdown for reading or further analysis.

Supported common formats include:
- PDF
- DOCX
- XLSX
- PPTX
- HTML
- CSV, JSON, XML
- EPUB

## Setup

Before first use, confirm that the executable exists and is runnable:

```bash
command -v markitdown
```

If `markitdown` is missing and package installation is allowed in the environment:

```bash
uv tool install "markitdown[all]"
```

## Usage

### Core rules

- Prefer writing converted output to stdout for temporary work.
- Use `-o <file>.md` only when you need to inspect the result in multiple passes.
- Use `markitdown` as the default converter for office documents and PDFs.
- If conversion quality is poor for a specific file, consider a format-specific fallback separately.

### Write to stdout

```bash
markitdown document.pdf
markitdown report.docx > report.md
```

### Convert a file to Markdown

```bash
markitdown document.pdf -o document.md
markitdown report.docx -o report.md
markitdown sheet.xlsx -o sheet.md
markitdown slides.pptx -o slides.md
```

### Help

```bash
markitdown --help
```
