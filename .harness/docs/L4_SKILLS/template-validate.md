# Skill: Template Validation

Run after every change to `template/`.

## Checks

1. **No platform paths:** `grep -r '\.kilo\|\.cursor\|\.vscode' template/` — 0 matches
2. **No escaping paths:** No file uses `../` to reference outside template/
3. **AGENTS.md is routing-only:** Check it references `.harness/docs/` rather than duplicating content
4. **ExecPlan template exists:** `template/.harness/execplan/template.md` present
5. **Files match:** Verify diff between `.harness/` and `template/.harness/`

## Command

```bash
[ -f "template/.harness/config.yaml" ] || echo "MISSING"
[ -f "template/.harness/constraints.yaml" ] || echo "MISSING"
[ -f "template/.harness/execplan/template.md" ] || echo "MISSING"
```
