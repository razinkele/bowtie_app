# Pre-Commit Hook Quick Start Guide

## Installation Status

✅ **The pre-commit hook is already installed and active!**

The hook is located at: `.git/hooks/pre-commit`

## What It Does

The hook automatically runs before every commit to check:

### 1. File Naming Conventions
- ❌ R files with `.r` extension → Must use `.R` (Linux compatible)
- ❌ Files with spaces → Must use underscores
- ⚠️ camelCase in R files → Prefer snake_case
- ⚠️ Unusual file extensions

### 2. Commented Code Detection
Detects and prevents commits containing commented-out code:

**Examples of what gets flagged:**
```r
# old_function <- function(x) { return(x + 1) }
# result = calculate_something()
# library(oldpackage)
```

**Examples of what's allowed:**
```r
# This is a documentation comment
# TODO: Implement this feature
# Configuration settings for the application
# ============================================
# @param x The input value
```

## Testing the Hook

### Option 1: Test with Current Staged Files
```bash
# The hook runs automatically when you commit
git commit -m "Your message"
```

### Option 2: Test the Hook Directly
```bash
# Run the hook manually to see what it checks
bash .git/hooks/pre-commit
```

### Option 3: Create a Test Scenario

**Test 1: File naming (should fail)**
```bash
# Create a file with wrong extension
echo "x <- 1" > test.r
git add test.r
git commit -m "Test commit"
# ❌ Hook will reject this
```

**Test 2: Commented code (should fail)**
```bash
# Create a file with commented code
cat > test_file.R << 'EOF'
# This is fine
calculate <- function(x) {
  return(x + 1)
}
# old_code <- function() { return(NULL) }
EOF

git add test_file.R
git commit -m "Test commit"
# ❌ Hook will detect commented code
```

**Test 3: Valid code (should pass)**
```bash
# Create a proper file
cat > valid_file.R << 'EOF'
# Calculate function
# @param x Numeric value to increment
calculate <- function(x) {
  return(x + 1)
}
EOF

git add valid_file.R
git commit -m "Add calculate function"
# ✅ Hook will allow this
```

## Reinstalling the Hook

If you need to reinstall or update the hook:

**Linux/Mac/Git Bash:**
```bash
chmod +x install_hooks.sh
./install_hooks.sh
```

**Windows PowerShell:**
```powershell
.\install_hooks.ps1
```

## Bypassing the Hook (Emergency Only)

If you absolutely must bypass the hook:

```bash
git commit --no-verify -m "Your message"
```

**⚠️ Warning:** Only bypass when absolutely necessary. The checks maintain code quality.

## Current Hook Status

Run this to verify the hook is working:

```bash
# Check hook exists and is executable
ls -l .git/hooks/pre-commit

# Test the hook
bash .git/hooks/pre-commit
```

Expected output when no issues found:
```
Running pre-commit checks...

=== Checking File Naming Conventions ===
✓ All file naming conventions passed

=== Checking for Commented Code ===
✓ No commented code detected

=== Summary ===
✓ All pre-commit checks passed!
```

## Troubleshooting

### "Hook not running"
```bash
# Make it executable
chmod +x .git/hooks/pre-commit
```

### "Permission denied"
```bash
# On Windows, use Git Bash or WSL
# On Linux/Mac, check file permissions
```

### "False positive detection"
If the hook incorrectly flags something:
1. Check if it's truly documentation (add descriptive keywords)
2. Use standard documentation markers (TODO, NOTE, @param, etc.)
3. Report the issue for hook improvement

## Integration with Workflow

The hook works seamlessly with:
- ✅ Regular git commits
- ✅ Git GUIs (GitKraken, SourceTree, etc.)
- ✅ IDE integrations (RStudio, VS Code)
- ✅ CI/CD pipelines (runs locally before push)

## Best Practices

1. **Run tests locally**: The hook catches issues before CI/CD
2. **Remove old code**: Don't comment it out, git tracks history
3. **Write clear comments**: Distinguish documentation from code
4. **Follow naming conventions**: Consistent names improve maintainability
5. **Review hook feedback**: Fix issues instead of bypassing

## Support

- **Documentation**: See `GIT_HOOKS_README.md` for detailed information
- **Project Guide**: See `CLAUDE.md` for overall project structure
- **Issues**: Report hook problems in the project repository

## Summary

✅ Hook is installed and active
✅ Runs automatically on every commit
✅ Enforces file naming conventions
✅ Prevents commented code from being committed
✅ Maintains code quality standards

**The hook is your friend - it helps maintain a clean, professional codebase!**
