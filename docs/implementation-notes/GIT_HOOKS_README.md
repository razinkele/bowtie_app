# Git Hooks Documentation

This project uses git pre-commit hooks to enforce code quality standards automatically.

## What Are Git Hooks?

Git hooks are scripts that run automatically at certain points in the git workflow. Our pre-commit hook runs before each commit to check your code for quality issues.

## Installed Hooks

### Pre-Commit Hook

The pre-commit hook enforces two main quality standards:

#### 1. File Naming Conventions

**Rules:**
- R files must use `.R` extension (not `.r`) for Linux compatibility
- Filenames should not contain spaces (use underscores instead)
- Prefer snake_case over camelCase for R files
- Standard extensions should be uppercase (.R, .MD, .TXT, etc.)

**Examples:**
```bash
# ✓ Good
utils.R
guided_workflow.R
vocabulary_bowtie_generator.R

# ✗ Bad
utils.r                    # Use .R not .r
my file.R                  # No spaces
myUtilsFile.R              # Prefer snake_case
```

#### 2. No Commented Code

**Rules:**
- Commented-out code should be removed before committing
- Actual documentation comments are allowed and encouraged
- TODO, FIXME, NOTE comments are allowed

**Examples:**
```r
# ✓ Good - Documentation comments
# This function generates bowtie diagrams
# @param data The input data frame
# TODO: Add error handling

# ✗ Bad - Commented code
# old_function <- function(x) {
#   return(x + 1)
# }
```

## Installation

### Option 1: Bash/Git Bash (Recommended)
```bash
# Make the installation script executable
chmod +x install_hooks.sh

# Run the installation script
./install_hooks.sh
```

### Option 2: PowerShell (Windows)
```powershell
# Run the installation script
.\install_hooks.ps1
```

### Option 3: Manual Installation
The hook is already installed at `.git/hooks/pre-commit` and is executable.

## Usage

### Normal Workflow

Once installed, the hook runs automatically before each commit:

```bash
git add .
git commit -m "Your commit message"
# Hook runs automatically here
```

If the hook detects issues, you'll see output like:

```
Running pre-commit checks...

=== Checking File Naming Conventions ===
✗ NAMING ERROR: R file uses lowercase .r extension: utils.r
  Fix: Rename to use .R extension (Linux compatible)

=== Checking for Commented Code ===
✗ COMMENTED CODE: server.R:145
  # old_code <- function() { return(NULL) }

=== Summary ===
✗ Pre-commit checks FAILED
  - Naming convention errors: 1
  - Commented code errors: 1

Fix the errors above and try again.
To bypass this hook (not recommended): git commit --no-verify
```

### Bypassing the Hook

In rare cases where you need to commit despite hook failures:

```bash
git commit --no-verify -m "Your commit message"
```

**⚠️ Warning:** Only bypass the hook when absolutely necessary. The checks are in place to maintain code quality.

## What Gets Checked

### File Types
- **R files** (`.R`, `.r`): All naming and commented code checks
- **Shell scripts** (`.sh`, `.bash`): All naming and commented code checks
- **Other files**: Only naming convention checks

### Excluded Patterns

The hook intelligently excludes:
- Documentation files (README, LICENSE, etc.)
- Configuration files (.gitignore, etc.)
- Data files (.csv, .xlsx, etc.)
- Documentation comments (with `@param`, `@return`, etc.)
- Marker comments (TODO, FIXME, NOTE)

## Troubleshooting

### Hook Not Running

1. Check if hook is executable:
   ```bash
   ls -l .git/hooks/pre-commit
   ```

2. Reinstall the hook:
   ```bash
   ./install_hooks.sh
   ```

### False Positives

If the hook incorrectly flags a comment as code:

1. Add pattern to documentation exclusions
2. Or use descriptive comments that clearly indicate documentation:
   ```r
   # Example: function_call()  # This is documentation
   ```

### Hook Runs but No Output

Make sure you're using Git Bash or a bash-compatible terminal. On Windows, use:
- Git Bash (recommended)
- WSL (Windows Subsystem for Linux)
- MinGW/Cygwin

## Customization

To modify the hook behavior, edit `.git/hooks/pre-commit`.

Common customizations:
- Add more file type checks
- Modify naming convention rules
- Adjust commented code detection patterns
- Add custom validation rules

After editing, the changes take effect immediately (no reinstallation needed).

## Best Practices

1. **Fix issues before committing**: Don't bypass the hook unless absolutely necessary
2. **Remove commented code**: Delete old code instead of commenting it out
3. **Use git for history**: Git tracks all changes, so you can always recover old code
4. **Write descriptive comments**: Good documentation helps distinguish from commented code
5. **Follow naming conventions**: Consistent naming improves codebase maintainability

## Integration with CI/CD

The pre-commit hook complements the CI/CD pipeline:
- **Pre-commit hook**: Fast local checks before committing
- **CI/CD pipeline**: Comprehensive tests, security scans, and deployment

Both work together to ensure code quality at every stage.

## Support

If you encounter issues with the git hooks:

1. Check this documentation
2. Review hook output for specific error messages
3. Try reinstalling the hooks
4. Check git configuration: `git config core.hooksPath`

For questions or improvements, contact the development team or create an issue in the repository.
