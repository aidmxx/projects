src_path <- if (file.exists("global.R")) {
} else if (file.exists("src/global.R")) {
  "src/"
} else {
  stop("Cannot find source files. Please run from project root or src directory.")
}

source(paste0(src_path, "global.R"), local = TRUE)
source(paste0(src_path, "timeseries_page.R"), local = TRUE) 
source(paste0(src_path, "summary_stats.R"), local = TRUE)
source(paste0(src_path, "customise.R")) 
source(paste0(src_path, "cohorts_page.R"), local = TRUE)
source(paste0(src_path, "distribution.R"), local = TRUE)
source(paste0(src_path, "report_page.R"), local = TRUE)
source(paste0(src_path, "email_automation.R"), local = TRUE)
source(paste0(src_path, "report_generator.R"), local = TRUE)
source(paste0(src_path, "background_email_scheduler.R"), local = TRUE) 

# Load additional libraries for timeseries
library(RColorBrewer)

server <- function(input, output, session) {

  # ---- Authentication ----
  res_auth <- secure_server(
    check_credentials = check_credentials_duckdb(credentials_con)
  )

  # ---- Background Email Scheduler ----
  start_background_email_scheduler() 
  
  onStop(function() {
    stop_background_email_scheduler() 
  })
  
  # Get user info for conditional UI elements
  # In shinymanager, res_auth is a ReactiveValues object
  is_admin <- reactive({
    req(res_auth)
    
    # Get the actual reactive value
    auth_result <- res_auth
    
    # Check if this is a ReactiveValues object and access is_admin directly
    if (inherits(auth_result, "reactivevalues") || inherits(auth_result, "ReactiveValues")) {
      if (!is.null(auth_result$is_admin)) {
        return(as.logical(auth_result$is_admin))
      }
    }
    
    # Fallback: return FALSE if not authenticated or no admin info
    return(FALSE)
  })


  observeEvent(input$trigger_logout, {
    # Clear the authentication
    session$userData$.shinymanager_where <- NULL
    session$userData$.shinymanager_user <- NULL
    # Reload the app to show login page
    session$reload()
  })

  # ---- EID Anonymization Function ----
  anonymize_eids <- function(data, is_admin_user) {
    if (!is_admin_user && "eid" %in% names(data)) {
      data$eid <- "*****"
    }
    return(data)
  }

  
  # ---- Filtering ----
  reactives <- build_filtered_reactives(input, dat0, is_admin)
  filtered_base <- reactives$filtered
  processed_data_base <- reactives$processed_data
  grouped_data_base <- reactives$grouped_data
  measure_sel <- debounce(reactive(input$measure), 300)
  
  # Use base filtered data directly (no search filtering)
  filtered <- reactive({
    filtered_base()
  })
  
  processed_data <- reactive({
    processed_data_base()
  })
  
  grouped_data <- reactive({
    grouped_data_base()
  })
  
  # ---- EID Anonymisation if non-admin ----
  filtered_anonymized <- reactive({
    anonymize_eids(filtered(), is_admin())
  })
  
  processed_data_anonymized <- reactive({
    anonymize_eids(processed_data(), is_admin())
  })
  
  grouped_data_anonymized <- reactive({
    anonymize_eids(grouped_data(), is_admin())
  })
  
  # ---- Common filters note ----
  common_filters_note <- reactive({
    df <- grouped_data()
    get_common_filters_note(df, input)
  })
  
  # ---- Record count ----
  output$record_count <- renderText({
    paste("Showing", nrow(processed_data_anonymized()), "of", nrow(dat0), "records")
  })
  
  
  # ---- Saved Views ----
  # Initialize saved views storage
  saved_views <- reactiveValues(views = list())
  
  # Load saved views from localStorage on app start
  observe({
    # Try to load from browser localStorage
    session$onFlushed(function() {
      session$sendCustomMessage("loadSavedViews", list())
    })
  })
  
  # Handle loaded views from localStorage
  observeEvent(input$loaded_views, {
    if (length(input$loaded_views) > 0) {
      saved_views$views <- input$loaded_views
    }
  })
  
  # Save current view
  observeEvent(input$save_current_view, {
    view_name <- trimws(input$save_view_name)
    if (view_name == "") {
      showNotification("Please enter a view name", type = "warning")
      return()
    }
    
    # Get current filter state
    current_filters <- list(
      year = input$year,
      month = input$month,
      day = input$day,
      sex = input$sex,
      treatment = input$treatment,
      breed = input$breed,
      mob = input$mob,
      eid = if (is_admin()) input$eid else NULL,
      measure = input$measure,
      timestamp = Sys.time()
    )
    
    # Save to reactive values
    saved_views$views[[view_name]] <- current_filters
    
    # Save to browser localStorage
    session$sendCustomMessage("saveView", list(
      name = view_name,
      filters = current_filters
    ))
    
    # Clear the input
    updateTextInput(session, "save_view_name", value = "")
    
    showNotification(paste("View '", view_name, "' saved successfully"), type = "message")
  })
  
  # Load saved view
  load_saved_view <- function(view_name) {
    if (view_name %in% names(saved_views$views)) {
      filters <- saved_views$views[[view_name]]
      
      # Apply filters
      updateSelectInput(session, "year", selected = filters$year)
      updateSelectInput(session, "month", selected = filters$month)
      updateSelectInput(session, "day", selected = filters$day)
      updatePickerInput(session, "sex", selected = filters$sex)
      updatePickerInput(session, "treatment", selected = filters$treatment)
      updatePickerInput(session, "breed", selected = filters$breed)
      updatePickerInput(session, "mob", selected = filters$mob)
      if (is_admin() && !is.null(filters$eid)) {
        updatePickerInput(session, "eid", selected = filters$eid)
      }
      updatePickerInput(session, "measure", selected = filters$measure)
      
      showNotification(paste("Loaded view '", view_name, "'"), type = "message")
    }
  }
  
  # Delete saved view
  delete_saved_view <- function(view_name) {
    if (view_name %in% names(saved_views$views)) {
      saved_views$views[[view_name]] <- NULL
      session$sendCustomMessage("deleteView", list(name = view_name))
      showNotification(paste("Deleted view '", view_name, "'"), type = "message")
    }
  }
  
  # Render saved views list
  output$saved_views_list <- renderUI({
    if (length(saved_views$views) == 0) {
      return(div(
        class = "text-muted small",
        style = "text-align: center; padding: 1rem;",
        "No saved views yet"
      ))
    }
    
    view_list <- lapply(names(saved_views$views), function(view_name) {
      view_data <- saved_views$views[[view_name]]
      
      div(
        class = "saved-view-item",
        style = "display: flex; justify-content: space-between; align-items: center; padding: 0.5rem; margin-bottom: 0.5rem; background: white; border-radius: 0.5rem; border: 1px solid var(--border-color);",
        div(
          style = "flex: 1;",
          div(
            style = "font-weight: 500; color: var(--text-primary);",
            view_name
          )
        ),
        div(
          style = "display: flex; gap: 0.25rem;",
          actionButton(
            paste0("load_view_", gsub("[^A-Za-z0-9]", "_", view_name)),
            icon("play"),
            class = "btn btn-primary btn-sm",
            title = "Load this view",
            onclick = paste0("Shiny.setInputValue('load_view_name', '", view_name, "', {priority: 'event'});")
          ),
          actionButton(
            paste0("delete_view_", gsub("[^A-Za-z0-9]", "_", view_name)),
            icon("trash"),
            class = "btn btn-danger btn-sm",
            title = "Delete this view",
            onclick = paste0("Shiny.setInputValue('delete_view_name', '", view_name, "', {priority: 'event'});")
          )
        )
      )
    })
    
    tagList(view_list)
  })
  
  # Handle load view
  observeEvent(input$load_view_name, {
    load_saved_view(input$load_view_name)
  })
  
  # Handle delete view
  observeEvent(input$delete_view_name, {
    delete_saved_view(input$delete_view_name)
  })
  
  
  # ---- Conditional EID filter UI ----
  output$eid_filter_ui <- renderUI({
    # Show EID filter only for admin users
    if (is_admin()) {
      build_eid_row(dat0)
    } else {
      # Empty div for non-admin users (no EID filter shown)
      div()
    }
  })
  
  # ---- Empty state helper ----
  create_empty_state <- function() {
    get_vec <- function(x) {
      if (is.null(x)) return("Overall")
      if (length(x) == 0) return("Overall")
      paste(x, collapse = ", ")
    }
    current_filters <- list(
      paste("Year:", if (is.null(input$year)) "—" else input$year),
      paste("Month:", if (is.null(input$month)) "All" else input$month),
      paste("Day:", if (is.null(input$day)) "All" else input$day),
      paste("Sex:", get_vec(input$sex)),
      paste("Treatment:", get_vec(input$treatment)),
      paste("Breed:", get_vec(input$breed)),
      paste("Mob:", get_vec(input$mob))
    )
    
    # Add EID filter only for admin users
    if (is_admin()) {
      
      current_filters <- append(current_filters, paste("EID:", get_vec(input$eid)))
    } 
    
    filter_display <- div(
      div(class = "empty-state-filters-title", "Current filters:"),
      div(class = "empty-state-filters",
          lapply(current_filters, function(filter) {
            div(class = "empty-state-filter-item", filter)
          })
      )
    )
    
    div(
      class = "empty-state-container",
      div(
        class = "empty-state-card",
        div(class = "empty-state-icon", "📊"),
        div(class = "empty-state-title", "No Data Found"),
        div(class = "empty-state-message", 
            "No livestock records match your current filter criteria. Try adjusting your filters to see more data."),
        filter_display,
        actionButton("reset_all_filters", "Reset All Filters", 
                    class = "empty-state-reset-btn")
      )
    )
  }
  
  # ---- Setup centralized filter observers ----
  setup_filter_observers(input, session, dat0)
  
  # Register summary stats (KPI + summary content)
  register_summary_stats(output, processed_data_anonymized, measure_sel, filtered_anonymized, input, grouped_data_anonymized)
  
  # ---- Empty state + summary ----
  output$empty_state <- renderUI({
    if (nrow(filtered_anonymized()) == 0) create_empty_state() else div()
  })

  # ---- Empty state + distributions ----
  output$empty_state_dist <- renderUI({
    if (nrow(filtered_anonymized()) == 0) create_empty_state() else div()
  })
  
  output$distributions_content <- renderUI({
    if (nrow(filtered_anonymized()) > 0) {
      tagList(
        # Legend toggle message
        div(
          class = "alert alert-info",
          style = "margin-bottom: 15px; padding: 10px; border-radius: 0.5rem;",
          icon("info-circle", class = "me-2"),
          "Tip: Click on legend items to toggle their visibility on the graphs below."
        ),
        # Common filters note (if applicable)
        if (nchar(common_filters_note()) > 0) {
          div(
            class = "alert alert-secondary",
            style = "margin-bottom: 15px; padding: 10px; border-radius: 0.5rem;",
            icon("filter", class = "me-2"),
            common_filters_note()
          )
        },
        # Histogram controls
        div(
          style = "margin-bottom: 15px; padding: 10px; background-color: #f8f9fa; 
                  border-radius: 0.5rem; border: 1px solid #ddd; display: flex; 
                  gap: 15px; align-items: center;",
          div(
            style = "flex: 1;",
            sliderInput("hist_bins", "Histogram Bins",
                        min = 10, max = 50, value = 20, step = 5,
                        ticks = FALSE, width = "100%")
          )
        ),
        # Histogram and box plot side by side (swapped positions)
        layout_columns(
          col_widths = c(6, 6),
          card(card_header("Histogram Comparison"),
              plotlyOutput("hist_plot", height = "500px")),
          card(card_header("Box Plot"),
              plotlyOutput("box_plot", height = "500px"))
        )
      )
    } else div()
  })
  
  # ---- Empty state + data management ----
  output$empty_state_data_management <- renderUI({
    if (nrow(filtered_anonymized()) == 0) create_empty_state() else div()
  })
  
  output$data_management_content <- renderUI({
    if (nrow(filtered_anonymized()) > 0) {
    tagList(
        card(card_header("Data Table"),
            DT::dataTableOutput("data_table")),
        card(card_header("Download"),
            downloadButton("download_csv", "Download CSV"))
      )
    } else div()
  })
  
  # KPI outputs now registered by register_summary_stats
  
  # Group KPI cards now registered by register_summary_stats
  
  # ---- Reports ----
  output$data_table <- renderDT({
    datatable(filtered_anonymized(), options=list(pageLength=10, scrollX=TRUE), filter="top")
  })
  
  output$download_csv <- downloadHandler(
    filename = function() paste0("filtered_", Sys.Date(), ".csv"),
    content  = function(file) readr::write_csv(filtered_anonymized(), file)
  )
  
  # ---- Distribution plots ----
  # Call the distribution_outputs function to set up both histogram and box plot
  distribution_outputs(input, output, session, processed_data_anonymized, measure_sel, filtered_anonymized, grouped_data_anonymized)
  
  # customise page
  customise_server("customise1", data_r = processed_data_anonymized)

  # ---- Empty state + cohorts ----
  output$empty_state_coh <- renderUI({
    if (nrow(filtered_anonymized()) == 0) create_empty_state() else div()
  })
  
  output$cohorts_content <- renderUI({
    if (nrow(filtered_anonymized()) > 0) {
      # Return the module's UI when data exists
      cohorts_ui("coh")
    } else {
      div()
    }
  })
    
  # ---- Cohorts Page----
  cohorts_server("coh", data_r = processed_data_anonymized, 
                  measure_col = reactive(input$measure), 
                  date_col = NULL) 
  
  # ---- Empty state + time series ----
  output$empty_state_ts <- renderUI({
    if (nrow(filtered_anonymized()) == 0) create_empty_state() else div()
  })
  
  output$timeseries_content <- renderUI({
    if (nrow(filtered_anonymized()) > 0) {
      tagList(
        # Legend toggle message
        div(
          class = "alert alert-info",
          style = "margin-bottom: 15px; padding: 10px; border-radius: 0.5rem;",
          icon("info-circle", class = "me-2"),
          "Tip: Click on legend items to toggle their visibility on the time series plot below."
        ),
        # Common filters note (if applicable)
        if (nchar(common_filters_note()) > 0) {
          div(
            class = "alert alert-secondary",
            style = "margin-bottom: 15px; padding: 10px; border-radius: 0.5rem;",
            icon("filter", class = "me-2"),
            common_filters_note()
          )
        },
        div(
          style = "margin-bottom: 15px; padding: 10px; background-color: #f8f9fa; 
                    border-radius: 0.5rem; border: 1px solid #ddd; display: flex; 
                    gap: 15px; align-items: center;",
          div(
            style = "flex: 1;",
            sliderInput("ts_point_size", "Point Size",
                        min = 1, max = 5, value = 3, step = 0.5,
                        ticks = FALSE, width = "100%")
          ),
          div(
            style = "flex: 1;",
            checkboxInput("ts_show_smooth", "Show Trend Line", value = FALSE)
          )
        ),
        card(card_header("Time Series Plot"),
              plotlyOutput("ts_plot", height = "500px", width = "100%"))
      )
    } else div()
  })
  
  # ---- Time series plot ----
  output$ts_plot <- renderPlotly({
    df_combined <- grouped_data_anonymized()
    req(!is.null(df_combined) && nrow(df_combined) > 0, cancelOutput = TRUE)
    
    m <- measure_sel()
    
    # Aggregate data by date and group
    df_daily <- df_combined |> 
      group_by(date, group) |>
      summarize(
        value = mean(.data[[m]], na.rm=TRUE),
        count = n(),
        .groups="drop"
      )
    
    # Use default ggplot2 colors to match cohorts page (no custom palette)
    unique_groups <- unique(df_daily$group)
    n_groups <- length(unique_groups)
      
      point_size <- if (!is.null(input$ts_point_size)) input$ts_point_size else 3
      show_smooth <- if (!is.null(input$ts_show_smooth)) input$ts_show_smooth else FALSE
      
      p <- ggplot(df_daily, aes(date, value, color = group, group = group,
                                      text = paste0(
                                        "<b>", group, "</b><br>",
                                        "Date: ", date, "<br>",
                                        "Average ", m, ": ", round(value, 2), "<br>",
                                        "Records: ", count
                                      ))) +
        geom_line() + 
        geom_point() +
        {if (show_smooth) geom_smooth(method = "loess", se = FALSE, alpha = 0.7)} +
        # No custom color scale - uses default ggplot2 colors like cohorts page
        labs(
          x = NULL, 
          y = paste(m, "(", measure_units[[tolower(m)]], ")"), 
          color = "Animal Group"
        ) +
        theme_minimal(base_size = 12)
      
    ggplotly(p, tooltip = "text", height = 500)
    })
  
  # ---- Empty state + reports ----
  output$empty_state_reports <- renderUI({
    if (nrow(filtered_anonymized()) == 0) create_empty_state() else div()
  })
  
  output$reports_content <- renderUI({
    if (nrow(filtered_anonymized()) > 0) {
      report_ui("reports")
    } else {
      div()
    }
  })
  
  # ---- Reports Page ----
  report_server("reports", filtered = filtered_anonymized, grouped_data = grouped_data_anonymized, measure_sel = measure_sel, is_admin = is_admin)
}


