# Coding Policy

Read README.md first - same rules apply to humans and agents.

## Documentation
- Two MD files max: DESIGN.md (what/why), README.md (how)
- No per-component docs
- Good code is self-documenting

## Shell Scripts
- Set -euo pipefail
- Check critical preconditions, exit with clear error
- Single outcome message at end
- No progress output, no ASCII art
- Success is silence, failure is loud

## Forbidden
- Tutorial-style guides
- Per-service READMEs
- Comments explaining what (code does that)
- Echo/print for status updates
- Redundant information

## Example
```bash
# Bad
echo "Starting deployment..."
echo "Checking for key..."
if [ ! -f "$KEY" ]; then
    echo "ERROR: Key not found"
    exit 1
fi
echo "✓ Key found"

# Good
set -euo pipefail
[ -f "$KEY" ] || { echo "ERROR: Key not found"; exit 1; }
```

