FROM node:22-bookworm-slim

# System dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Install asciinema
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip pipx \
    && rm -rf /var/lib/apt/lists/* \
    && pipx install asciinema

ENV PATH="/root/.local/bin:$PATH"

# Install br (beads_rust) — lightweight SQLite-based issue tracker
RUN curl -fsSL https://raw.githubusercontent.com/Dicklesworthstone/beads_rust/main/install.sh | bash

# Install Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code

# Git identity for commits inside the container
RUN git config --global user.name "HELIX Demo" \
    && git config --global user.email "demo@helix.dev" \
    && git config --global init.defaultBranch main

# Working directory for the demo project
WORKDIR /workspace

# Copy the demo script and ddx-library
COPY demo.sh /usr/local/bin/demo.sh
RUN chmod +x /usr/local/bin/demo.sh

# Mount points:
#   /root/.claude     — Claude OAuth credentials (bind-mount, read-only)
#   /ddx-library      — ddx-library repo (bind-mount, read-only)
#   /workspace        — demo project workspace (ephemeral)
#   /recordings       — asciinema output (bind-mount for extraction)

ENTRYPOINT ["/usr/local/bin/demo.sh"]
