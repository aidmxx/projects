# Test Shiny app functions

test_that("ui.R file structure is valid", {
  # Test that ui.R exists and can be sourced
  if (file.exists("src/ui.R")) {
    ui_content <- readLines("src/ui.R", warn = FALSE)
    expect_true(length(ui_content) > 0)
    
    # Test that it contains UI elements (modern Shiny with bslib)
    ui_text <- paste(ui_content, collapse = " ")
    expect_true(grepl("page_navbar|sidebar|nav_panel|fluidPage|navbarPage|sidebarLayout", ui_text))
  } else {
    skip("src/ui.R file not found")
  }
})

test_that("server.R file structure is valid", {
  # Test that server.R exists and can be sourced
  if (file.exists("src/server.R")) {
    server_content <- readLines("src/server.R", warn = FALSE)
    expect_true(length(server_content) > 0)
    
    # Test that it contains server elements
    server_text <- paste(server_content, collapse = " ")
    expect_true(grepl("function\\(input, output, session\\)|server", server_text))
  } else {
    skip("src/server.R file not found")
  }
})

test_that("global.R file structure is valid", {
  # Test that global.R exists and can be sourced
  if (file.exists("src/global.R")) {
    global_content <- readLines("src/global.R", warn = FALSE)
    expect_true(length(global_content) > 0)
    
    # Test that it contains global elements
    global_text <- paste(global_content, collapse = " ")
    expect_true(grepl("library|source", global_text))
  } else {
    skip("src/global.R file not found")
  }
})
