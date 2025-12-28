# CodeRabbit AI Code Review Integration

## Overview

CodeRabbit is integrated into this repository to provide AI-powered code reviews on all pull requests. It analyzes code quality, security, performance, and adherence to R/Shiny best practices.

## Features

### Automated Reviews
- ✅ **Automatic PR Reviews**: CodeRabbit reviews all pull requests automatically
- ✅ **Inline Comments**: Provides specific, actionable feedback on code changes
- ✅ **Code Suggestions**: Offers auto-fixable improvements
- ✅ **Security Scanning**: Identifies potential security vulnerabilities
- ✅ **Performance Analysis**: Detects performance bottlenecks
- ✅ **Test Coverage**: Ensures adequate test coverage for changes

### R/Shiny Specific Checks
- **Reactive Patterns**: Reviews reactive expressions, observers, and dependencies
- **Error Handling**: Ensures proper try-catch blocks and error messages
- **Data Validation**: Checks for input validation and sanitization
- **Logging**: Validates use of centralized logging (app_message, bowtie_log)
- **Style Guide**: Enforces tidyverse style conventions

### Custom Rules
This project has custom rules configured for:
- Shiny observer priority specifications
- Reactive dependency declarations
- Hardcoded path detection
- Console output in reactives
- Centralized logging usage

## Setup Instructions

### 1. Enable CodeRabbit on GitHub

**Option A: Via GitHub Marketplace** (Recommended)
1. Go to [CodeRabbit GitHub App](https://github.com/apps/coderabbitai)
2. Click "Install" or "Configure"
3. Select this repository: `razinkele/bowtie_app`
4. Grant required permissions:
   - ✅ Read access to code
   - ✅ Read/write access to pull requests
   - ✅ Read/write access to issues
   - ✅ Read access to workflows
5. Click "Install & Authorize"

**Option B: Via Repository Settings**
1. Navigate to repository: https://github.com/razinkele/bowtie_app
2. Go to Settings → Integrations → Applications
3. Click "Configure" next to CodeRabbit
4. Enable for this repository

### 2. Verify Configuration

After installation, CodeRabbit will:
- ✅ Detect the `.coderabbit.yaml` configuration file
- ✅ Start reviewing new pull requests automatically
- ✅ Add inline comments and suggestions
- ✅ Update PR status checks

### 3. Test the Integration

Create a test PR to verify CodeRabbit is working:

```bash
# Create a test branch
git checkout -b test/coderabbit-integration

# Make a small change
echo "# Testing CodeRabbit" >> README.md

# Commit and push
git add README.md
git commit -m "test: Verify CodeRabbit integration"
git push -u origin test/coderabbit-integration

# Create PR via GitHub CLI
gh pr create --title "test: CodeRabbit integration" --body "Testing AI code review"
```

Expected behavior:
- ⏳ CodeRabbit status check appears in PR
- 🤖 CodeRabbit adds review comments within 1-2 minutes
- ✅ Review summary posted as PR comment

## Configuration

The repository uses `.coderabbit.yaml` for configuration:

```yaml
# Review level: comprehensive
# Focus areas: Shiny reactivity, error handling, security, performance
# Auto-fix: Enabled for style and formatting
# Coverage threshold: 80%
```

### Key Settings

| Setting | Value | Description |
|---------|-------|-------------|
| **Review Level** | Comprehensive | Deep analysis of all changes |
| **Auto-fix** | Enabled | Suggests automatic fixes |
| **Coverage Threshold** | 80% | Minimum test coverage |
| **Max Function Length** | 300 lines | Complexity limit |
| **Max Complexity** | 15 | Cyclomatic complexity |
| **Block on Critical** | Yes | Prevents merge if critical issues |

## Using CodeRabbit

### On Pull Requests

CodeRabbit automatically:
1. **Reviews all changed files** within minutes of PR creation/update
2. **Posts inline comments** on specific lines needing attention
3. **Provides summary** with overview of all issues found
4. **Suggests fixes** that can be applied with one click
5. **Updates labels** based on issue types found

### Interacting with Reviews

**Apply suggested fixes:**
```
@coderabbitai apply
```

**Request clarification:**
```
@coderabbitai explain this suggestion
```

**Dismiss a comment:**
```
@coderabbitai ignore
```

**Re-run review:**
```
@coderabbitai review
```

### Review Categories

CodeRabbit categorizes issues:
- 🔴 **Critical**: Security vulnerabilities, breaking changes
- 🟠 **Major**: Performance issues, missing tests, complex logic
- 🟡 **Minor**: Style violations, documentation gaps
- 🟢 **Suggestion**: Improvements, optimizations

## CI/CD Integration

CodeRabbit integrates with the existing CI/CD pipeline:

```yaml
# In .github/workflows/ci-cd-pipeline.yml
jobs:
  coderabbit-check:
    runs-on: ubuntu-latest
    steps:
      - name: Wait for CodeRabbit Review
        uses: coderabbitai/coderabbit-action@v1
```

### Status Checks

CodeRabbit adds these status checks to PRs:
- ✅ **CodeRabbit Review**: Overall review status
- ✅ **Critical Issues**: Blocks merge if found
- ✅ **Test Coverage**: Ensures 80%+ coverage
- ✅ **Security Scan**: No vulnerabilities

## Troubleshooting

### CodeRabbit Not Reviewing PRs

**Check:**
1. CodeRabbit app is installed and authorized
2. Repository has access enabled
3. `.coderabbit.yaml` file is present in root
4. PR has code changes (not just documentation)

**Solution:**
- Re-trigger review: Comment `@coderabbitai review` on PR
- Check GitHub Actions logs for errors
- Verify permissions in repository settings

### Review Taking Too Long

**Typical times:**
- Small PRs (< 100 lines): 1-2 minutes
- Medium PRs (100-500 lines): 2-5 minutes
- Large PRs (500+ lines): 5-10 minutes

**If stuck:**
- Comment `@coderabbitai reset` to restart review
- Check GitHub API rate limits
- Contact CodeRabbit support

### False Positives

If CodeRabbit flags valid code:

**Option 1: Add inline ignore**
```r
# coderabbit:ignore - Intentional pattern for Shiny reactivity
observe({
  # Complex observer logic
})
```

**Option 2: Update configuration**
Edit `.coderabbit.yaml` to adjust custom rules

**Option 3: Dismiss comment**
Comment `@coderabbitai ignore` on the specific review comment

## Best Practices

### Before Creating PR

✅ **Run pre-commit hooks** to catch basic issues:
```r
Rscript install_hooks.R  # One-time setup
git commit  # Hooks run automatically
```

✅ **Run tests locally**:
```r
Rscript tests/comprehensive_test_runner.R
```

✅ **Check code style**:
```r
Rscript -e "lintr::lint_package()"
```

### Responding to Reviews

✅ **Address critical issues first**
✅ **Apply suggested auto-fixes** when appropriate
✅ **Add tests** if coverage is low
✅ **Update documentation** if flagged
✅ **Acknowledge or dismiss** other comments

### Improving Review Quality

CodeRabbit learns from:
- ✅ Approved suggestions
- ✅ Project coding patterns
- ✅ Maintainer feedback

Over time, reviews become more accurate and relevant.

## Configuration Reference

### Full `.coderabbit.yaml` Structure

```yaml
language: r
reviews:
  auto_review: true
  level: comprehensive
checks:
  r:
    style_guide: tidyverse
    anti_patterns: true
    performance: true
    security: true
focus_areas:
  - Shiny Reactivity
  - Error Handling
  - Data Validation
  - Performance
  - Security
  - Testing
custom_rules:
  - Shiny-specific checks
  - Logging validation
  - Path validation
```

See `.coderabbit.yaml` for complete configuration.

## Support

### Resources
- **CodeRabbit Docs**: https://docs.coderabbit.ai
- **GitHub App**: https://github.com/apps/coderabbitai
- **Support**: support@coderabbit.ai

### Project Maintainers
For project-specific questions about CodeRabbit configuration:
1. Check this document first
2. Review `.coderabbit.yaml` comments
3. Consult with project maintainers

## Version History

- **v5.5.3** (2025-12-28): Initial CodeRabbit integration
  - Comprehensive configuration for R/Shiny projects
  - Custom rules for Shiny reactivity patterns
  - Focus areas for environmental risk analysis domain
  - CI/CD integration with existing pipeline

---

**Last Updated**: 2025-12-28
**Configuration Version**: 5.5.3
**CodeRabbit Version**: Latest
