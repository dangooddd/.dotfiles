---
name: websearch
description: Web search and content extraction via `ddgs` search tool. Use for searching documentation, facts, or any web content. Lightweight, no browser required.
compatibility: Requires shell access and a working `ddgs` executable on PATH.
---

# Web Search

## Overview

Use this skill when you need to search the web from the shell.

This skill is for **direct CLI usage only**. For normal tasks, do **not** use the Python API, API server, or MCP server. Use the executable directly unless the user explicitly asks for one of those integrations.

Use `ddgs` for:

- general web search
- recent news search
- image lookup
- video lookup
- extracting readable content from a URL

## Setup

Before first use, confirm that the executable exists and is runnable:

```bash
command -v ddgs

ddgs --help
```

If `ddgs` is missing and package installation is allowed in the environment:

```bash
# or python -m pip install -U ddgs
uv tool install ddgs
```

## Usage

### Core rules for agents

- Prefer `ddgs text` for general web search.
- Prefer `ddgs news` when the user asks for recent developments.
- Prefer `ddgs images` or `ddgs videos` only when those media types are specifically needed.
- Prefer `ddgs extract` after you find a promising URL and need the page content in readable form.
- Add `-nc` / `--no-color` for clean terminal output.
- Start with `-m 5` to `-m 10`, then expand only if needed.
- Use `-t d|w|m|y` when recency matters.
- Use `-r <region>` when locality matters.
- Use `-o <file>.json` when you need structured output for later parsing.
- Quote queries carefully so shells do not split or reinterpret them.

### General web search

```bash
ddgs text -q "latest Rust async patterns" -m 5 -nc

ddgs text -q "site:docs.python.org asyncio TaskGroup" -m 10 -nc

ddgs text -q "filetype:pdf transformer interpretability" -t y -m 10 -nc
```

Use `text` for:

- documentation lookup
- broad factual web search
- targeted queries with operators like `site:` and `filetype:`

### Recent news search

```bash
ddgs news -q "EU AI Act" -t w -m 10 -nc

ddgs news -q "OpenAI API updates" -t d -m 5 -r us-en -nc
```

Use `news` when the user explicitly wants recent developments, announcements, or breaking updates.

### Image search

```bash
ddgs images -q "saturn rings" -m 8 -nc

ddgs images -q "butterfly" -c Blue -l Wide -m 10 -nc
```

Useful image filters:

- `--size Small|Medium|Large|Wallpaper`
- `--color color|Monochrome|Red|Orange|Yellow|Green|Blue|Purple|Pink|Brown|Black|Gray|Teal|White`
- `--type_image photo|clipart|gif|transparent|line`
- `--layout Square|Tall|Wide`
- `--license_image any|Public|Share|ShareCommercially|Modify|ModifyCommercially`

### Video search

```bash
ddgs videos -q "postgres indexing tutorial" -d medium -m 5 -nc

ddgs videos -q "cars" -res high -m 10 -nc
```

Useful video filters:

- `--resolution high|standart`
- `--duration short|medium|long`
- `--license_videos creativeCommon|youtube`

### Extract page content from a URL

```bash
ddgs extract -u "https://example.com"

ddgs extract -u "https://example.com" -f text_plain

ddgs extract -u "https://example.com/article" -f text_markdown -o /tmp/page.json
```

`extract` formats:

- `text_markdown` — default; best when you want readable structured text
- `text_plain` — plain text only
- `text_rich` — rich text without raw link URLs
- `text` — raw HTML
- `content` — raw bytes

## Common options

### Shared options

Most search subcommands support these flags:

- `-q, --query` — query string
- `-m, --max_results` — maximum number of results
- `-p, --page` — page number
- `-o, --output` — write results to JSON or CSV
- `-pr, --proxy` — proxy URL such as `socks5h://127.0.0.1:9150`
- `-nc, --no-color` — disable colored terminal output

### Search-specific options

For `text`, `images`, `videos`, and `news`:

- `-r, --region` — region such as `us-en`, `uk-en`, `ru-ru`
- `-s, --safesearch` — `on`, `moderate`, or `off`
- `-t, --timelimit` — recency window

Timelimit values:

- `text`: `d`, `w`, `m`, `y`
- `images`: `d`, `w`, `m`, `y`
- `news`: `d`, `w`, `m`, `y`
- `videos`: `d`, `w`, `m`

## Help

Discover current CLI options directly from the executable:

```bash
ddgs --help
ddgs text --help
ddgs news --help
ddgs images --help
ddgs videos --help
ddgs extract --help
```
