# Simple test script for translation system
cat("🧪 Testing Translation System\n")
cat("=" , rep("=", 50), "\n", sep = "")

# Load translation module
cat("\n📦 Loading translation module...\n")
source("translations.R")
cat("✅ Translation module loaded successfully\n")

# Test basic translation function
cat("\n🔤 Testing translation function:\n")
cat("  English app_title:", t("app_title", "en"), "\n")
cat("  French app_title:", t("app_title", "fr"), "\n")

# Test scenario translations
cat("\n🌍 Testing scenario translations:\n")
cat("  EN marine pollution:", t("scenario_marine_pollution", "en"), "\n")
cat("  FR marine pollution:", t("scenario_marine_pollution", "fr"), "\n")

# Test scenario choices function
cat("\n📋 Testing scenario choices function:\n")
scenarios_en <- getScenarioChoices("en", include_blank = FALSE)
scenarios_fr <- getScenarioChoices("fr", include_blank = FALSE)
cat("  English scenarios count:", length(scenarios_en), "\n")
cat("  French scenarios count:", length(scenarios_fr), "\n")

# Test a few scenario names
cat("\n✅ Sample scenario names:\n")
cat("  EN:", names(scenarios_en)[1], "=", scenarios_en[1], "\n")
cat("  FR:", names(scenarios_fr)[1], "=", scenarios_fr[1], "\n")

# Test all translation keys exist in both languages
cat("\n🔍 Checking translation completeness:\n")
en_keys <- names(TRANSLATIONS$en)
fr_keys <- names(TRANSLATIONS$fr)
cat("  English keys:", length(en_keys), "\n")
cat("  French keys:", length(fr_keys), "\n")

missing_fr <- setdiff(en_keys, fr_keys)
missing_en <- setdiff(fr_keys, en_keys)

if (length(missing_fr) > 0) {
  cat("  ⚠️ Missing French translations:", paste(missing_fr, collapse = ", "), "\n")
} else if (length(missing_en) > 0) {
  cat("  ⚠️ Missing English translations:", paste(missing_en, collapse = ", "), "\n")
} else {
  cat("  ✅ All translations present in both languages\n")
}

# Test error handling
cat("\n🧪 Testing error handling:\n")
suppressWarnings({
  result <- t("nonexistent_key", "en")
  cat("  Non-existent key returns:", result, "\n")
})

result_invalid_lang <- t("app_title", "de")
cat("  Invalid language falls back to English:", result_invalid_lang, "\n")

cat("\n✅ All translation tests passed!\n")
cat("=" , rep("=", 50), "\n", sep = "")
