library(DBI)
library(duckdb)
library(readr)

# Function to setup the main database
setup_main_database <- function() {
  cat("Setting up main database...\n")
  
  # Connect to the main database
  con <- dbConnect(duckdb::duckdb(), "data/data.duckdb")
  
  # Check if animal_data table already exists
  tables <- dbListTables(con)
  if ("animal_data" %in% tables) {
    cat("animal_data table already exists. Skipping setup.\n")
    dbDisconnect(con)
    return(TRUE)
  }
  
  # Read the CSV data
  csv_file <- "data/wowByrne_v2.csv"
  if (!file.exists(csv_file)) {
    stop("CSV file not found: ", csv_file)
  }
  
  cat("Reading CSV data from:", csv_file, "\n")
  data <- read_csv(csv_file, show_col_types = FALSE)
  
  # Validate required columns
  required_cols <- c("EID", "Date")
  missing_cols <- setdiff(required_cols, names(data))
  if (length(missing_cols) > 0) {
    stop("CSV is missing required columns: ", paste(missing_cols, collapse = ", "))
  }
  
  # Convert Date column to proper date type
  data$Date <- as.Date(data$Date)
  
  # Write data to database
  cat("Writing data to database...\n")
  dbWriteTable(con, "animal_data", data, overwrite = TRUE)
  
  # Create indexes for performance
  cat("Creating indexes...\n")
  dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_animal_eid ON animal_data(EID)")
  dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_animal_date ON animal_data(Date)")
  
  # Create other indexes if columns exist
  if ("Breed" %in% names(data)) {
    dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_animal_breed ON animal_data(Breed)")
  }
  if ("Treatment" %in% names(data)) {
    dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_animal_treatment ON animal_data(Treatment)")
  }
  if ("Mob" %in% names(data)) {
    dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_animal_mob ON animal_data(Mob)")
  }
  if ("Sex" %in% names(data)) {
    dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_animal_sex ON animal_data(Sex)")
  }
  
  # Analyze table for query optimization
  dbExecute(con, "ANALYZE animal_data")
  
  # Get record count
  count <- dbGetQuery(con, "SELECT COUNT(*) as n FROM animal_data")$n
  cat("Database setup complete. Loaded", count, "records.\n")
  
  dbDisconnect(con)
  return(TRUE)
}

# Run the setup
if (interactive()) {
  setup_main_database()
} else {
  # When run as script
  tryCatch({
    setup_main_database()
    cat("Database setup completed successfully!\n")
  }, error = function(e) {
    cat("Error setting up database:", e$message, "\n")
    quit(status = 1)
  })
}
