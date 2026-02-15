source("src/customise.R")

test_that('friendly_label covers all logical branches', {
  # Setup: assign measure_labels into the global environment for testing.
  assign('measure_labels', c(finalpweight = 'Final processed weight (kg)', foo = 'Bar Foo'), envir = .GlobalEnv)

  expect_equal(friendly_label(NULL), NULL)
  expect_equal(friendly_label(character(0)), character(0))
  expect_equal(unname(friendly_label('treatment_display')), 'Treatment')
  expect_equal(unname(friendly_label('treatment')), 'Treatment')
  expect_equal(unname(friendly_label('eid')), 'EID')
  expect_equal(unname(friendly_label('date')), 'Date')
  expect_equal(unname(friendly_label('finalpweight')), 'Final processed weight (kg)')
  expect_equal(unname(friendly_label('foo')), 'Bar Foo')
  expect_equal(unname(friendly_label('unknown_col')), 'Unknown col')

  # Multiple values
  expect_equal(
    unname(friendly_label(c('treatment_display', 'eid', 'date', 'finalpweight', 'unknown_col'))),
    c('Treatment', 'EID', 'Date', 'Final processed weight (kg)', 'Unknown col')
  )

  # Clean up
  rm(measure_labels, envir = .GlobalEnv)
})
