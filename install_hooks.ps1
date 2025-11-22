# PowerShell installation script for git hooks
# Run this script to install or reinstall pre-commit hooks

Write-Host "Installing git hooks..." -ForegroundColor Green

# Check if we're in a git repository
if (-not (Test-Path ".git")) {
    Write-Host "Error: Not in a git repository root directory" -ForegroundColor Yellow
    exit 1
}

# Create hooks directory if it doesn't exist
New-Item -ItemType Directory -Force -Path ".git\hooks" | Out-Null

# Backup existing hook
if (Test-Path ".git\hooks\pre-commit") {
    Write-Host "Pre-commit hook already exists. Backing up..." -ForegroundColor Yellow
    Copy-Item ".git\hooks\pre-commit" ".git\hooks\pre-commit.backup" -Force
}

# Create the pre-commit hook
$hookContent = @'
#!/bin/bash
# Pre-commit hook for enforcing code quality standards
# Enforces: File naming conventions & No commented code

set -e

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}Running pre-commit checks...${NC}"

# Get list of staged files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM)

# Exit early if no files staged
if [ -z "$STAGED_FILES" ]; then
    echo -e "${GREEN}No files staged for commit.${NC}"
    exit 0
fi

# Initialize error flags
NAMING_ERRORS=0
COMMENTED_CODE_ERRORS=0

echo ""
echo "=== Checking File Naming Conventions ==="

# Check file naming conventions
for FILE in $STAGED_FILES; do
    FILENAME=$(basename "$FILE")

    # Check for spaces in filename
    if [[ "$FILENAME" =~ \  ]]; then
        echo -e "${RED}✗ NAMING ERROR: File contains spaces: $FILE${NC}"
        echo -e "  ${YELLOW}Fix: Replace spaces with underscores${NC}"
        NAMING_ERRORS=$((NAMING_ERRORS + 1))
    fi

    # Check R files use .R extension (not .r)
    if [[ "$FILE" =~ \.r$ ]]; then
        echo -e "${RED}✗ NAMING ERROR: R file uses lowercase .r extension: $FILE${NC}"
        echo -e "  ${YELLOW}Fix: Rename to use .R extension (Linux compatible)${NC}"
        NAMING_ERRORS=$((NAMING_ERRORS + 1))
    fi

    # Check for camelCase in R files (prefer snake_case)
    if [[ "$FILE" =~ \.R$ ]] && [[ "$FILENAME" =~ [a-z][A-Z] ]]; then
        # Allow some exceptions
        if [[ ! "$FILENAME" =~ ^(README|CLAUDE|VERSION) ]]; then
            echo -e "${YELLOW}⚠ WARNING: R file uses camelCase, prefer snake_case: $FILE${NC}"
        fi
    fi

    # Check for uppercase extensions other than .R
    if [[ "$FILENAME" =~ \.[A-Z]{2,}$ ]] && [[ ! "$FILENAME" =~ \.(R|MD|TXT|CSV|JSON|YAML|YML|XML)$ ]]; then
        echo -e "${YELLOW}⚠ WARNING: File uses uppercase extension: $FILE${NC}"
    fi
done

if [ $NAMING_ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ All file naming conventions passed${NC}"
fi

echo ""
echo "=== Checking for Commented Code ==="

# Check for commented-out code
for FILE in $STAGED_FILES; do
    # Only check R files and shell scripts
    if [[ ! "$FILE" =~ \.(R|r|sh|bash)$ ]]; then
        continue
    fi

    # Skip if file doesn't exist (deleted files)
    if [ ! -f "$FILE" ]; then
        continue
    fi

    # Pattern to detect commented code (not documentation)
    # Look for lines that have code patterns after #
    while IFS= read -r line_num; do
        LINE=$(sed "${line_num}!d" "$FILE")

        # Skip decorative lines (=, -, *, etc.)
        if echo "$LINE" | grep -qE '^\s*#\s*[=*_-]{3,}\s*$'; then
            continue
        fi

        # Skip section headers and descriptive comments
        if echo "$LINE" | grep -qiE '^\s*#.*(\(|Configuration|Settings|Paths|Directory|File|Application|Database|API|future|needed|default|optional|required)'; then
            continue
        fi

        # Skip documentation patterns
        if echo "$LINE" | grep -qE '^\s*#'\''|^\s*# @|^\s*# TODO|^\s*# FIXME|^\s*# NOTE|^\s*# Example:|^\s*# Usage:|^\s*# Description|^\s*# Parameters?:|^\s*# Returns?:'; then
            continue
        fi

        # Check for actual code patterns
        if echo "$LINE" | grep -qE '^\s*#\s*[a-zA-Z_][a-zA-Z0-9_]*\s*(<-|->|=)\s*[^#]|^\s*#\s*(function\(|if\(|for\(|while\(|library\(|source\(|return\()'; then
            echo -e "${RED}✗ COMMENTED CODE: $FILE:$line_num${NC}"
            echo -e "  ${YELLOW}$LINE${NC}"
            COMMENTED_CODE_ERRORS=$((COMMENTED_CODE_ERRORS + 1))
        fi
    done < <(grep -n '^\s*#' "$FILE" | cut -d: -f1)
done

if [ $COMMENTED_CODE_ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ No commented code detected${NC}"
fi

echo ""
echo "=== Summary ==="

# Report results
TOTAL_ERRORS=$((NAMING_ERRORS + COMMENTED_CODE_ERRORS))

if [ $TOTAL_ERRORS -gt 0 ]; then
    echo -e "${RED}✗ Pre-commit checks FAILED${NC}"
    echo -e "${RED}  - Naming convention errors: $NAMING_ERRORS${NC}"
    echo -e "${RED}  - Commented code errors: $COMMENTED_CODE_ERRORS${NC}"
    echo ""
    echo -e "${YELLOW}Fix the errors above and try again.${NC}"
    echo -e "${YELLOW}To bypass this hook (not recommended): git commit --no-verify${NC}"
    exit 1
else
    echo -e "${GREEN}✓ All pre-commit checks passed!${NC}"
    exit 0
fi
'@

# Write the hook file
Set-Content -Path ".git\hooks\pre-commit" -Value $hookContent -NoNewline

Write-Host "✓ Pre-commit hook installed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "The hook will now run automatically before each commit."
Write-Host "It will check for:"
Write-Host "  - File naming conventions (.R extension, no spaces)"
Write-Host "  - Commented-out code"
Write-Host ""
Write-Host "To bypass the hook (not recommended): git commit --no-verify"
