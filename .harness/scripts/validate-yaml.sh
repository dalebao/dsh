#!/usr/bin/env bash
# YAML structural validation for .harness/ config files
# Uses yq for reliable YAML parsing when available, falls back to grep checks.

FAILED=0

echo "=== YAML Validation ==="

# Helper: check if a command exists
has_yq=false
command -v yq >/dev/null 2>&1 && has_yq=true

validate_yaml_syntax() {
  if $has_yq; then
    if ! yq eval '.' "$1" >/dev/null 2>&1; then
      echo "[FAIL] $1: invalid YAML syntax"
      return 1
    fi
  else
    python3 -c "import yaml; yaml.safe_load(open('$1'))" 2>/dev/null || {
      echo "[FAIL] $1: invalid YAML syntax"
      return 1
    }
  fi
  return 0
}

echo "--- Syntax Check ---"
for f in .harness/config.yaml .harness/constraints.yaml; do
  validate_yaml_syntax "$f" || FAILED=1
done

echo "--- config.yaml ---"
grep -q "^name:" .harness/config.yaml || { echo "[FAIL] missing 'name'"; FAILED=1; }
grep -q "^version:" .harness/config.yaml || { echo "[FAIL] missing 'version'"; FAILED=1; }
grep -q "^verification:" .harness/config.yaml || { echo "[FAIL] missing 'verification'"; FAILED=1; }
# Check verification.layers has content
LAYER_COUNT=$(sed -n '/^verification:/,/^[a-z]/p' .harness/config.yaml | grep "^\s*- " | wc -l)
[ "$LAYER_COUNT" -ge 1 ] || { echo "[FAIL] verification.layers is empty"; FAILED=1; }

echo "--- constraints.yaml ---"
grep -q "^invariants:" .harness/constraints.yaml || { echo "[FAIL] missing 'invariants'"; FAILED=1; }
grep -q "^guardrails:" .harness/constraints.yaml || { echo "[FAIL] missing 'guardrails'"; FAILED=1; }
INVARIANT_COUNT=$(grep -c "^  - id:" .harness/constraints.yaml)
GUARDRAIL_COUNT=$(sed -n '/^guardrails:/,$ p' .harness/constraints.yaml | grep -c "^  - id:")
echo "  invariants: $INVARIANT_COUNT, guardrails: $GUARDRAIL_COUNT"
[ "$INVARIANT_COUNT" -ge 1 ] || { echo "[FAIL] at least 1 invariant required"; FAILED=1; }

echo "==================="
if [ "$FAILED" -eq 0 ]; then
  echo "[PASS] All YAML files valid"
else
  echo "[FAIL] $FAILED validation errors found"
fi
exit $FAILED
