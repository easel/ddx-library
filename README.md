# DDx Library

This repository contains the DDx (Document-Driven Development eXperience) library of templates, patterns, prompts, and configurations for AI-assisted development.

## Installation

### Claude Code Plugin (Recommended)

Install directly as a Claude Code plugin:

```bash
/plugin install https://github.com/easel/ddx-library
```

This gives you:
- **Slash commands**: `/ddx:prd`, `/ddx:code-review`, `/ddx:commit-hooks`, `/ddx:github-actions`, `/ddx:docs`, `/ddx:gitignore`, `/ddx:create-workflow`
- **HELIX skill**: Auto-invoked TDD workflow guidance during development
- **Agents**: Systems architect, TDD test engineer, strict code reviewer

### DDx CLI

Alternatively, use the [DDx CLI tool](https://github.com/easel/ddx) for git subtree-based synchronization:

```bash
# Install DDx CLI
curl -fsSL https://raw.githubusercontent.com/easel/ddx/main/install.sh | bash

# Initialize in your project
ddx init
```

## Contents

- **commands/** - Claude Code slash commands
- **skills/** - Auto-invoked Claude Code skills (HELIX workflow)
- **agents/** - Specialized Claude Code agents
- **prompts/** - AI prompts and instructions for various development tasks
- **personas/** - AI personality definitions for consistent interactions
- **mcp-servers/** - Model Context Protocol server configurations
- **workflows/** - Complete development methodologies (HELIX, etc.)
- **environments/** - Development environment configurations
- **tools/** - Development tool integrations and scripts
- **templates/** - Project templates and boilerplates
- **patterns/** - Reusable code patterns and solutions

## Contributing

### Local Development

Clone and install locally to test changes:

```bash
# Clone the repository
git clone https://github.com/easel/ddx-library.git
cd ddx-library

# Test as a local plugin
claude --plugin-dir .

# Or from another directory
claude --plugin-dir /path/to/ddx-library
```

### Plugin Structure

```
ddx-library/
├── .claude-plugin/
│   └── plugin.json      # Plugin manifest
├── commands/            # Slash commands (/ddx:*)
├── skills/              # Auto-invoked skills
├── agents/              # Specialized agents
└── .mcp.json            # MCP server configs
```

### Making Changes

- **commands/*.md** - Add or modify slash commands
- **skills/*/SKILL.md** - Add or modify auto-invoked skills
- **agents/*.md** - Add or modify specialized agents
- **workflows/** - Add or modify workflow definitions
- **prompts/** - Add or modify standalone prompts

### Submitting Changes

1. Fork this repository
2. Create a branch for your changes
3. Test locally with `claude --plugin-dir .`
4. Submit a pull request

## License

This library is open source software licensed under the MIT License.

## Related Projects

- [DDx CLI](https://github.com/easel/ddx) - The command-line tool for using this library
- [HELIX Workflow](./workflows/helix/) - Six-phase AI-assisted development methodology