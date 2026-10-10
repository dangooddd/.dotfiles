## User rules

Those rules take precedence over project AGENTS.md rules:

- Do not commit or push changes without direct user request
- Do not write tests without direct user request
- Do not call linter or formatter without direct user request

Additionally, do not overengineer:

- Do everything requested with as little new code as possible; don't add unrequested features
- Use existing project patterns first, then built-in APIs, then installed dependencies
- Remove unnecessary code; don't add abstractions, wrappers, settings or dependencies unless needed
- Write clear code that handles possible edge cases, even if it takes a few more lines
- Avoid unnecessary defensive code

## Project skills

Capture reusable project knowledge and workflows as skills:

- Store project-specific skills in `./.opencode/skills/`
- Create or update a skill when you discover a stable workflow or non-obvious project knowledge worth reusing
- Prefer updating an existing relevant skill over creating a duplicate
- Do not record temporary task state or one-off findings as skills
