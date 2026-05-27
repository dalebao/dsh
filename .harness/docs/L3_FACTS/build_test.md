# Build & Test

## Current state
This is a documentation and design project. No runtime code, no build pipeline, no test framework.

## Code indexing pipeline (for analyzing target projects)

### Prerequisites

```bash
# Tree-sitter (parser)
# Binary: download from GitHub releases
curl -L -o tree-sitter "https://github.com/tree-sitter/tree-sitter/releases/download/v0.26.9/tree-sitter-linux-x64.gz"
gunzip tree-sitter && chmod +x tree-sitter
# Or via npm: npm install -g tree-sitter-cli

# Semgrep (pattern-based query)
# pip install semgrep

# SCIP CLI (indexer)
npm install -g @sourcegraph/scip
```

### Pipeline

```
Tree-sitter (parse → CST) → SCIP (index → structured JSON) → Semgrep/CodeQL (query → violations)
```

### Install language grammars for Tree-sitter

```bash
# Download and build grammar
# Go:   tree-sitter build node_modules/tree-sitter-go
# Java: tree-sitter build node_modules/tree-sitter-java
```

### Run Semgrep rules

```bash
semgrep --config .harness/rules/ --json <target>
```

### SCIP index format

SCIP produces JSON-lines format. Agents can read it directly without external services:

```python
import json
with open('index.scip') as f:
    index = json.load(f)
    for doc in index['documents']:
        print(f"{doc['relative_path']}: {len(doc.get('occurrences',[]))} symbols")
```

## This project's verification

```bash
# L0: General hygiene — run before any commit
.harness/docs/L4_SKILLS/verify.md

# Doc structure validation
find .harness/docs/ -name "*.md" -exec grep -oP '\.harness/docs/[^ )]+' {} \; | \
  while read ref; do \
    [ -f "$ref" ] || [ -d "$ref" ] || echo "[FAIL] Broken reference: $ref"; \
  done
```

## Pipeline
```
lint_docs → [future: template consistency check → code indexing (for target projects)]
```

## Environment limitations (current)
- Tree-sitter v0.26.9 installed and functional
- Grammar compilation requires Go or Rust toolchain
- Semgrep requires pip (Python venv not configured)
- SCIP CLI requires npm (available)
