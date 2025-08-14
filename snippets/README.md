# Snippets Directory

This directory contains configuration snippets that can be injected into settings.json and CLAUDE.md files during installation.

## Directory Structure

```
snippets/
├── settings/          # JSON snippets for settings.json
│   └── *.json        # Individual feature configurations
└── claude-md/        # Markdown snippets for CLAUDE.md
    └── *.md          # Individual documentation sections
```

## Snippet Format

### Settings Snippets (JSON)

Each settings snippet must include:
- `snippet_id`: Unique identifier for the snippet
- `snippet_version`: Version of the snippet
- `description`: Brief description of what it configures
- `settings`: The actual settings to inject

### CLAUDE.md Snippets (Markdown)

Each CLAUDE.md snippet must include:
- Start marker: `<!-- SNIPPET_START: [id] [version] -->`
- End marker: `<!-- SNIPPET_END: [id] -->`
- Content between markers will be injected

## Usage

Snippets are automatically processed during installation based on the manifest configuration.