# Test file for report_generator.R functions
# Tests for convert_markdown_to_html and create_simple_pdf_report

test_that("convert_markdown_to_html works correctly", {
  # Test basic markdown conversion
  markdown_text <- "# Main Title\n## Subtitle\n### Sub-subtitle\n\n**Bold text**\n\n- List item 1\n- List item 2"
  
  result <- convert_markdown_to_html(markdown_text)
  
  # Check that headers are converted
  expect_match(result, "<h1>Main Title</h1>")
  expect_match(result, "<h2>Subtitle</h2>")
  expect_match(result, "<h3>Sub-subtitle</h3>")
  
  # Check that bold text is converted
  expect_match(result, "<strong>Bold text</strong>")
  
  # Check that list items are converted
  expect_match(result, "<li>List item 1</li>")
  expect_match(result, "<li>List item 2</li>")
  
  # Check that list is wrapped in ul tags
  expect_match(result, "<ul>")
  expect_match(result, "</ul>")
  
  # Check that line breaks are converted
  expect_match(result, "<br>")
})

test_that("convert_markdown_to_html handles empty input", {
  result <- convert_markdown_to_html("")
  expect_equal(result, "")
})

test_that("convert_markdown_to_html handles single line", {
  result <- convert_markdown_to_html("# Single Title")
  expect_match(result, "<h1>Single Title</h1>")
})

test_that("convert_markdown_to_html handles mixed content", {
  markdown_text <- "# Title\n\nSome **bold** text\n\n- Item 1\n- Item 2\n\n## Another Title"
  
  result <- convert_markdown_to_html(markdown_text)
  
  expect_match(result, "<h1>Title</h1>")
  expect_match(result, "<strong>bold</strong>")
  expect_match(result, "<li>Item 1</li>")
  expect_match(result, "<li>Item 2</li>")
  expect_match(result, "<h2>Another Title</h2>")
})

test_that("create_simple_pdf_report works correctly", {
  # Create test data
  test_df <- data.frame(
    id = 1:5,
    weight = c(100, 150, 200, 120, 180),
    date = as.Date(c("2023-01-01", "2023-01-02", "2023-01-03", "2023-01-04", "2023-01-05"))
  )
  
  # Mock input object
  test_input <- list(
    year = 2023,
    sex = c("Male", "Female"),
    breed = c("Angus", "Hereford")
  )
  
  # Mock report content
  report_content_md <- "# Test Report\n\nThis is a test report."
  
  # Mock chart files
  chart_files <- list(
    "Time Series" = "chart1.png",
    "Distribution" = "chart2.png"
  )
  
  # Create temporary file
  temp_file <- tempfile(fileext = ".txt")
  
  # Test the function
  expect_no_error({
    create_simple_pdf_report(test_df, test_input, report_content_md, chart_files, temp_file)
  })
  
  # Check that file was created
  expect_true(file.exists(temp_file))
  
  # Read and check content
  content <- readLines(temp_file)
  content_text <- paste(content, collapse = "\n")
  
  # Check for expected content
  expect_match(content_text, "LIVESTOCK DASHBOARD REPORT")
  expect_match(content_text, "Total Records: 5")
  expect_match(content_text, "Mean:")
  expect_match(content_text, "Median:")
  expect_match(content_text, "Minimum:")
  expect_match(content_text, "Maximum:")
  expect_match(content_text, "Standard Deviation:")
  expect_match(content_text, "APPLIED FILTERS")
  expect_match(content_text, "Year: 2023")
  expect_match(content_text, "Sex: Male, Female")
  expect_match(content_text, "Breed: Angus, Hereford")
  expect_match(content_text, "CHARTS INCLUDED")
  expect_match(content_text, "- Time Series")
  expect_match(content_text, "- Distribution")
  
  # Clean up
  unlink(temp_file)
})

test_that("create_simple_pdf_report works with empty filters", {
  # Create test data
  test_df <- data.frame(
    id = 1:3,
    weight = c(100, 150, 200)
  )
  
  # Mock input object with no filters
  test_input <- list()
  
  # Mock report content
  report_content_md <- "# Test Report"
  
  # No chart files
  chart_files <- list()
  
  # Create temporary file
  temp_file <- tempfile(fileext = ".txt")
  
  # Test the function
  expect_no_error({
    create_simple_pdf_report(test_df, test_input, report_content_md, chart_files, temp_file)
  })
  
  # Check that file was created
  expect_true(file.exists(temp_file))
  
  # Read and check content
  content <- readLines(temp_file)
  content_text <- paste(content, collapse = "\n")
  
  # Check for expected content
  expect_match(content_text, "LIVESTOCK DASHBOARD REPORT")
  expect_match(content_text, "Total Records: 3")
  expect_match(content_text, "DATA QUALITY")
  
  # Should not have filters section
  expect_no_match(content_text, "APPLIED FILTERS")
  
  # Should not have charts section
  expect_no_match(content_text, "CHARTS INCLUDED")
  
  # Clean up
  unlink(temp_file)
})

test_that("create_simple_pdf_report works with single filter", {
  # Create test data
  test_df <- data.frame(
    id = 1:2,
    weight = c(100, 150)
  )
  
  # Mock input object with single filter
  test_input <- list(
    year = 2023
  )
  
  # Mock report content
  report_content_md <- "# Test Report"
  
  # Single chart file
  chart_files <- list(
    "Time Series" = "chart1.png"
  )
  
  # Create temporary file
  temp_file <- tempfile(fileext = ".txt")
  
  # Test the function
  expect_no_error({
    create_simple_pdf_report(test_df, test_input, report_content_md, chart_files, temp_file)
  })
  
  # Check that file was created
  expect_true(file.exists(temp_file))
  
  # Read and check content
  content <- readLines(temp_file)
  content_text <- paste(content, collapse = "\n")
  
  # Check for expected content
  expect_match(content_text, "APPLIED FILTERS")
  expect_match(content_text, "Year: 2023")
  expect_match(content_text, "CHARTS INCLUDED")
  expect_match(content_text, "- Time Series")
  
  # Clean up
  unlink(temp_file)
})
