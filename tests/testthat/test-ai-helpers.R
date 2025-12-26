library(testthat)

source('../../vocabulary-ai-helpers.R')

test_that('preprocess_text works and handles NA', {
  expect_equal(preprocess_text('Hello, World!'), 'hello world')
  expect_equal(preprocess_text(NA), '')
  expect_equal(preprocess_text('  Multiple   spaces\n and PUNCT!!'), 'multiple spaces and punct')
})

test_that('extract_key_terms returns expected terms', {
  terms <- extract_key_terms('Agriculture runoff causes water pollution and eutrophication', top_n = 3)
  expect_true(length(terms) <= 3)
  expect_true('agriculture' %in% terms || 'runoff' %in% terms || 'water' %in% terms)
  expect_equal(extract_key_terms(NA), character(0))
})

test_that('calculate_semantic_similarity is symmetric and bounded', {
  s1 <- calculate_semantic_similarity('water pollution from agricultural runoff', 'runoff causes water pollution')
  s2 <- calculate_semantic_similarity('runoff causes water pollution', 'water pollution from agricultural runoff')
  expect_true(!is.na(s1) && s1 >= 0 && s1 <= 1)
  expect_equal(s1, s2)
  expect_equal(calculate_semantic_similarity(NA, 'x'), 0)
})