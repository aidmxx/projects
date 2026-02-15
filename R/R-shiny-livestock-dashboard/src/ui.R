# Determine the correct path for sourcing files
src_path <- if (file.exists("global.R")) {
  ""  # We're in the src directory
} else if (file.exists("src/global.R")) {
  "src/"  # We're in the project root
} else {
  stop("Cannot find source files. Please run from project root or src directory.")
}

source(paste0(src_path, "global.R"), local = TRUE)


ui <- secure_app(
  tagList(
    # Logo header bar (separate from navbar)
    tags$div(
      class = "logo-header-bar",
      tags$div(
        class = "logo-container",
        # Dynamically load all logos from logo directory
        generate_logo_tags()
      )
    ),

    # Head section with CSS and JavaScript
    tags$head(
    tags$style(HTML("
      @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap');
      @import url('https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css');
      
      body, label, input, button, select {
        font-family: 'Poppins', sans-serif;
        font-weight: 400;
        line-height: 1.6;
      }

      :root {
        --primary-color: #1B4332;
        --primary-light: #2D6A4F;
        --primary-dark: #0F2B1F;
        --secondary-color: #5C4033;
        --accent-color: #B08968;
        --success-color: #2D6A4F;
        --info-color: #95A5A6;
        --warning-color: #B08968;
        --danger-color: #7B241C;
        --light-bg: #f8f9fa;
        --card-bg: #ffffff;
        --text-primary: #2c3e50;
        --text-secondary: #6c757d;
        --border-color: #e9ecef;
        --shadow-light: 0 2px 4px rgba(0,0,0,0.1);
        --shadow-medium: 0 4px 12px rgba(0,0,0,0.15);
        --shadow-heavy: 0 8px 24px rgba(0,0,0,0.2);
        --gradient-primary: linear-gradient(135deg, #1B4332 0%, #2D6A4F 100%);
        --gradient-card: linear-gradient(145deg, #ffffff 0%, #f8f9fa 100%);
        --gradient-hover: linear-gradient(145deg, #f8f9fa 0%, #e9ecef 100%);
      }
      
      /* Login page specific styles */
      .shinymanager-panel {
        position: fixed !important;
        top: 50% !important;
        right: 5% !important;
        transform: translateY(-50%) !important;
        width: 40% !important;
        max-width: 450px !important;
        background: var(--gradient-card) !important;
        border: none !important;
        border-radius: 1.5rem !important;
        box-shadow: var(--shadow-heavy) !important;
        padding: 2.5rem !important;
        z-index: 2 !important;
        backdrop-filter: blur(15px) !important;
        border: 1px solid rgba(255, 255, 255, 0.2) !important;
      }
      
      /* Add welcome text above the form */
      .shinymanager-panel::before {
        content: 'Welcome to Livestock Dashboard';
        display: block;
        text-align: center;
        font-size: 1.8rem;
        font-weight: 700;
        color: #1B4332;
        margin-bottom: 1.5rem;
        padding-bottom: 1rem;
        border-bottom: 2px solid #1B4332;
      }
      
      /* Add subtitle */
      .shinymanager-panel::after {
        content: 'Advanced Analytics for Livestock Management';
        display: block;
        text-align: center;
        font-size: 1rem;
        color: #6c757d;
        margin-top: 1rem;
        font-style: italic;
      }
      
      /* Responsive design for login page */
      @media (max-width: 768px) {
        .shinymanager-panel {
          position: relative !important;
          top: auto !important;
          right: auto !important;
          transform: none !important;
          width: 90% !important;
          margin: 2rem auto !important;
          padding: 1.5rem !important;
        }
        
        .shinymanager-panel::before {
          font-size: 1.5rem;
        }
      }

      /* Enhanced form styling for new layout */
      .shinymanager-form {
        margin: 0 !important;
        padding: 0 !important;
      }
      
      .shinymanager-form .form-control {
        border-radius: 0.6rem !important;
        border: 2px solid #e9ecef !important;
        padding: 0.75rem 1rem !important;
        font-size: 1rem !important;
        transition: all 0.3s ease !important;
        background-color: white !important;
      }
      
      .shinymanager-form .form-control:focus {
        border-color: #1B4332 !important;
        box-shadow: 0 0 0 0.2rem rgba(27, 67, 50, 0.25) !important;
        outline: none !important;
      }
      
      .shinymanager-form .form-control::placeholder {
        color: #6c757d !important;
        opacity: 0.8 !important;
        font-style: normal !important;
      }
      
      .shinymanager-form .form-group {
        margin-bottom: 1.5rem !important;
      }
      
      .shinymanager-form label {
        color: #1B4332 !important;
        font-weight: 600 !important;
        margin-bottom: 0.5rem !important;
        font-size: 0.95rem !important;
      }

      .shinymanager-form .btn {
        width: 100% !important;
        margin-top: 1rem !important;
        background-color: #1B4332 !important;
        border-color: #1B4332 !important;
        border-radius: 0.6rem !important;
        padding: 0.75rem 1.5rem !important;
        font-size: 1rem !important;
        font-weight: 600 !important;
        text-transform: uppercase !important;
        letter-spacing: 0.5px !important;
        transition: all 0.3s ease !important;
        border: none !important;
      }
      
      .shinymanager-form .btn:hover {
        background-color: #2D6A4F !important;
        border-color: #2D6A4F !important;
        transform: translateY(-2px) !important;
        box-shadow: 0 4px 12px rgba(27, 67, 50, 0.3) !important;
      }
      
      .shinymanager-form .btn:active {
        transform: translateY(0) !important;
        box-shadow: 0 2px 6px rgba(27, 67, 50, 0.3) !important;
      }
      
      /* Logo Header Bar - Separate from Navbar */
      .logo-header-bar {
        background: var(--gradient-primary);
        border-bottom: none;
        padding: 0.5rem 1.5rem;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
      }
      
      .logo-container {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 1.5rem;
        max-width: 1400px;
        margin: 0 auto;
      }
      
      .partner-logo {
        height: 60px;
        width: auto;
        object-fit: contain;
        filter: brightness(1.1) drop-shadow(0 2px 4px rgba(0,0,0,0.2));
      }
      
      /* Responsive layout adjustments */
      @media (max-width: 768px) {
        .logo-header-bar {
          padding: 0.4rem 1rem;
        }
        
        .logo-container {
          justify-content: center;
          gap: 1rem;
        }
      }
      
      .navbar {
        background: var(--gradient-primary);
        box-shadow: var(--shadow-medium);
        border: none;
        padding: 1rem 0;
      }
      
      .navbar-brand {
        font-weight: 700;
        font-size: 1.5rem;
        color: white !important;
        text-shadow: 0 2px 4px rgba(0,0,0,0.3);
      }
      
      .navbar .nav-link {
        color: rgba(255, 255, 255, 0.9);
        background-color: transparent;
        border-radius: 1rem;
        padding: 0.75rem 0.75rem !important;
        border: none;
        transition: all 0.3s ease;
        font-weight: 500;
        position: relative;
        overflow: hidden;
      }
      
      .navbar .nav-link::before {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(255,255,255,0.1), transparent);
        transition: left 0.5s;
      }
      
      .navbar .nav-link:hover {
        color: white;
        background-color: rgba(255, 255, 255, 0.15);
        transform: translateY(-1px);
        box-shadow: 0 4px 8px rgba(0,0,0,0.2);
      }
      
      .navbar .nav-link:hover::before {
        left: 100%;
      }
      
      .navbar .nav-link.active {
        color: white;
        background: linear-gradient(135deg, #B08968 0%, #D4A574 100%);
        font-weight: 600;
        border-radius: 1rem;
        padding: 0.75rem 0.75rem !important;
        border: none;
        box-shadow: 0 4px 12px rgba(176, 137, 104, 0.4);
        transform: translateY(-1px);
      }

      /* Logout button specific styling */
      #logout_btn {
        display: flex;
        align-items: center;
        gap: 0.5rem;
        cursor: pointer;
        background-color: rgba(255, 255, 255, 0.12) !important;
        border: 1px solid rgba(255, 255, 255, 0.25) !important;
        color: #fff !important;
        border-radius: 0.8rem !important;
        padding: 0.5rem 0.75rem !important;
      }

      #logout_btn i {
        font-size: 1rem;
      }
      #logout_btn:hover {
        background-color: rgba(255, 255, 255, 0.24) !important;
        border-color: rgba(255, 255, 255, 0.4) !important;
      }
      
      .sidebar {
        padding: 1.2rem;
      }
      .sidebar .form-group {
        margin-bottom: 1rem;
      }
      
      /* Sidebar title styling to match form labels */
      .sidebar > .sidebar-title {
        font-weight: 600;
        color: var(--text-primary);
        margin-bottom: 1rem;
        font-size: 0.9rem;
        text-transform: uppercase;
        letter-spacing: 0.5px;
      }
      
      .card {
        border-radius: 1rem;
        background: var(--gradient-card);
        border: 1px solid var(--border-color);
        margin-bottom: 1.5rem;
        padding: 0;
        box-shadow: var(--shadow-light);
        transition: all 0.3s ease;
        overflow: hidden;
        position: relative;
      }
      
      .card:hover {
        transform: translateY(-2px);
        box-shadow: var(--shadow-medium);
        border-color: var(--primary-light);
      }
      
      .card-header {
        background: var(--gradient-primary);
        color: white;
        font-weight: 400;
        border-radius: 1rem 1rem 0 0;
        padding: 1.25rem 1.5rem;
        border: none;
        position: relative;
        overflow: hidden;
      }
      
      .card-header::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: linear-gradient(45deg, rgba(255,255,255,0.1) 0%, transparent 100%);
        pointer-events: none;
      }
      
      .card-body {
        padding: 1.5rem;
        background: white;
      }
      
      /* Card with icons */
      .card-header i {
        margin-right: 0.5rem;
        opacity: 0.9;
      }
      
      .layout-columns > div {
        margin-right: 1rem;
        margin-bottom: 1rem;
      }
      
      .btn {
        border-radius: 0.75rem;
        font-weight: 500;
        padding: 0.75rem 1.5rem;
        transition: all 0.3s ease;
        border: none;
        position: relative;
        overflow: hidden;
        text-transform: none;
        letter-spacing: 0.5px;
      }
      
      .btn::before {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
        transition: left 0.5s;
      }
      
      .btn:hover::before {
        left: 100%;
      }
      
      .btn-primary {
        background: var(--gradient-primary);
        color: white;
        border: none;
        box-shadow: var(--shadow-light);
      }
      
      .btn-primary:hover {
        background: var(--primary-light);
        transform: translateY(-1px);
        box-shadow: var(--shadow-medium);
        color: white;
      }
      
      .btn-success {
        background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
        color: white;
        border: none;
      }
      
      .btn-success:hover {
        background: linear-gradient(135deg, #218838 0%, #1ea085 100%);
        transform: translateY(-1px);
        box-shadow: var(--shadow-medium);
      }
      
      .btn-warning {
        background: linear-gradient(135deg, #ffc107 0%, #fd7e14 100%);
        color: white;
        border: none;
      }
      
      .btn-danger {
        background: linear-gradient(135deg, #dc3545 0%, #e74c3c 100%);
        color: white;
        border: none;
      }
      
      .btn-outline-primary {
        background: transparent;
        color: var(--primary-color);
        border: 2px solid var(--primary-color);
      }
      
      .btn-outline-primary:hover {
        background: var(--primary-color);
        color: white;
        transform: translateY(-1px);
      }
      
      .container-fluid .page-content {
        padding: 1.5rem;
      }
      
      .form-control, .form-select {
        border-radius: 0.75rem;
        border: 2px solid var(--border-color);
        padding: 0.75rem 1rem;
        font-size: 0.95rem;
        transition: all 0.3s ease;
        background: white;
        box-shadow: var(--shadow-light);
      }
      
      .form-control:focus, .form-select:focus {
        border-color: var(--primary-color);
        box-shadow: 0 0 0 0.2rem rgba(27, 67, 50, 0.15);
        outline: none;
        transform: translateY(-1px);
      }
      
      .form-label {
        font-weight: 600;
        color: var(--text-primary);
        margin-bottom: 0.5rem;
        font-size: 0.9rem;
        text-transform: uppercase;
        letter-spacing: 0.5px;
      }
      
      /* Multi-select picker styling */
      .picker-input {
        margin-bottom: 1rem;
      }
      
      .picker-input .form-control {
        border-radius: 0.75rem;
        border: 2px solid var(--border-color);
        padding: 0.75rem 1rem;
        background: white;
        box-shadow: var(--shadow-light);
        transition: all 0.3s ease;
      }
      
      .picker-input .form-control:focus {
        border-color: var(--primary-color);
        box-shadow: 0 0 0 0.2rem rgba(27, 67, 50, 0.15);
        transform: translateY(-1px);
      }

      .picker-dropdown {
        border-radius: 0.6rem;
        border: 1px solid #ddd;
        box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
      }
      
      .picker-row {
        display: flex;
        justify-content: space-between;
        align-items: center;
        width: 100%;
      }
      .picker-label { flex: 1; }
      .count-badge {
        background-color: #e9ecef;
        color: #495057;
        border-radius: 999px;
        padding: 0 .5rem;
        font-size: 0.75rem;
        font-weight: 600;
        min-width: 1.5rem;
        text-align: center;
      }
      
      .picker-actions {
        background-color: #f8f9fa;
        border-top: 1px solid #ddd;
        padding: 0.5rem;
      }
      
      .picker-search {
        border-radius: 0.4rem;
        border: 1px solid #ddd;
        padding: 0.5rem;
        margin-bottom: 0.5rem;
      }
      
      /* Select All and Invert link styling */
      .action-link {
        font-size: 0.8rem;
        color: #6c757d;
        text-decoration: none;
        padding: 0.1rem 0.3rem;
        border-radius: 0.25rem;
        transition: all 0.2s ease;
      }
      
      .action-link:hover {
        color: #1B4332;
        background-color: #f8f9fa;
        text-decoration: none;
      }
      
      .ms-2 {
        margin-left: 0.5rem;
      }
      
      /* Empty state styling */
      .empty-state-container {
        display: flex;
        justify-content: center;
        align-items: center;
        min-height: 400px;
        padding: 2rem;
      }
      
      .empty-state-card {
        background-color: white;
        border-radius: 0.8rem;
        box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.1);
        padding: 3rem 2rem;
        text-align: center;
        max-width: 500px;
        width: 100%;
      }
      
      .empty-state-icon {
        font-size: 4rem;
        color: #6c757d;
        margin-bottom: 1.5rem;
        opacity: 0.7;
      }
      
      .empty-state-title {
        font-size: 1.5rem;
        font-weight: 600;
        color: #495057;
        margin-bottom: 1rem;
      }
      
      .empty-state-message {
        color: #6c757d;
        margin-bottom: 2rem;
        line-height: 1.5;
      }
      
      .empty-state-filters {
        background-color: #f8f9fa;
        border-radius: 0.5rem;
        padding: 1rem;
        margin-bottom: 2rem;
        text-align: left;
      }
      
      .empty-state-filters-title {
        font-weight: 600;
        color: #495057;
        margin-bottom: 0.5rem;
      }
      
      .empty-state-filter-item {
        color: #6c757d;
        margin-bottom: 0.25rem;
      }
      
      .empty-state-reset-btn {
        background-color: #1B4332;
        border-color: #1B4332;
        color: white;
        border-radius: 0.6rem;
        padding: 0.75rem 2rem;
        font-weight: 500;
        border: none;
        cursor: pointer;
        transition: all 0.2s ease;
      }
      
      .empty-state-reset-btn:hover {
        background-color: #2D6A4F;
        border-color: #2D6A4F;
        color: white;
      }
      
      /* Prevent white flash during plot re-rendering */
      .plotly {
        background-color: #f4f3f1 !important;
      }
      
      .shiny-plot-output {
        background-color: #f4f3f1 !important;
      }
      
      /* Ensure consistent plot sizing */
      .shiny-plot-output {
        min-height: 500px !important;
        max-height: 500px !important;
        height: 500px !important;
        width: 100% !important;
      }
      
      .plotly {
        min-height: 500px !important;
        max-height: 500px !important;
        height: 500px !important;
        width: 100% !important;
      }
      
      /* Force plotly containers to maintain size */
      .plotly.html-widget {
        height: 500px !important;
        width: 100% !important;
      }
      
      /* Smooth transitions for plot containers */
      .card {
        transition: opacity 0.1s ease-in-out;
      }
      
      .loading-spinner {
        display: inline-block;
        width: 20px;
        height: 20px;
        border: 3px solid rgba(255,255,255,.3);
        border-radius: 50%;
        border-top-color: #fff;
        animation: spin 1s ease-in-out infinite;
      }
      
      @keyframes spin {
        to { transform: rotate(360deg); }
      }
      
      .fade-in {
        animation: fadeIn 0.5s ease-in;
      }
      
      @keyframes fadeIn {
        from { opacity: 0; transform: translateY(20px); }
        to { opacity: 1; transform: translateY(0); }
      }
      
      .empty-state-container {
        display: flex;
        justify-content: center;
        align-items: center;
        min-height: 400px;
        padding: 2rem;
        background: var(--gradient-card);
        border-radius: 1rem;
        margin: 1rem 0;
      }
      
      .empty-state-card {
        background: white;
        border-radius: 1rem;
        box-shadow: var(--shadow-medium);
        padding: 3rem 2rem;
        text-align: center;
        max-width: 500px;
        width: 100%;
        border: 1px solid var(--border-color);
      }
      
      .empty-state-icon {
        font-size: 4rem;
        color: var(--text-secondary);
        margin-bottom: 1.5rem;
        opacity: 0.7;
      }
      
      .empty-state-title {
        font-size: 1.5rem;
        font-weight: 600;
        color: var(--text-primary);
        margin-bottom: 1rem;
      }
      
      .empty-state-message {
        color: var(--text-secondary);
        margin-bottom: 2rem;
        line-height: 1.6;
      }
      
      @media (max-width: 768px) {
        .card {
          margin-bottom: 1rem;
        }
        
        .card-header {
          padding: 1rem;
        }
        
        .card-body {
          padding: 1rem;
        }
        
        .btn {
          padding: 0.5rem 1rem;
          font-size: 0.9rem;
        }
        
        .navbar .nav-link {
          padding: 0.5rem 1rem !important;
          font-size: 0.9rem;
        }
        
        .form-control, .form-select {
          padding: 0.5rem 0.75rem;
          font-size: 0.9rem;
        }
      }
      
      @media (max-width: 576px) {
        .container-fluid .page-content {
          padding: 1rem;
        }
        
        .card-header {
          font-size: 0.9rem;
        }
        
        .empty-state-card {
          padding: 2rem 1rem;
        }
      }
      
      .plotly {
        background: white !important;
        border-radius: 0.75rem;
        box-shadow: var(--shadow-light);
        border: 1px solid var(--border-color);
      }
      
      .shiny-plot-output {
        background: white !important;
        border-radius: 0.75rem;
        box-shadow: var(--shadow-light);
        border: 1px solid var(--border-color);
        padding: 1rem;
        margin: 1rem 0;
      }
      
      /* Data Table Enhancements */
      .dataTables_wrapper {
        background: white;
        border-radius: 0.75rem;
        box-shadow: var(--shadow-light);
        border: 1px solid var(--border-color);
        overflow: hidden;
      }
      
      .dataTables_wrapper .dataTables_filter input {
        border-radius: 0.5rem;
        border: 2px solid var(--border-color);
        padding: 0.5rem;
        transition: all 0.3s ease;
      }
      
      .dataTables_wrapper .dataTables_filter input:focus {
        border-color: var(--primary-color);
        box-shadow: 0 0 0 0.2rem rgba(27, 67, 50, 0.15);
      }
      
      /* Breadcrumb Navigation Styles */
      .breadcrumb-container {
        background: var(--light-bg) !important;
        border-bottom: 1px solid var(--border-color) !important;
        padding: 0.75rem 1.5rem !important;
        margin: 0 !important;
      }
      
      .breadcrumb-nav {
        display: flex;
        align-items: center;
        gap: 0.5rem;
        font-size: 0.9rem;
        margin: 0;
        padding: 0;
      }
      
      .breadcrumb-link {
        color: var(--primary-color) !important;
        text-decoration: none !important;
        font-weight: 500;
        transition: all 0.2s ease;
        padding: 0.25rem 0.5rem;
        border-radius: 0.375rem;
        display: flex;
        align-items: center;
        gap: 0.25rem;
      }
      
      .breadcrumb-link:hover {
        background-color: rgba(27, 67, 50, 0.1);
        color: var(--primary-dark) !important;
        text-decoration: none !important;
        transform: translateY(-1px);
      }
      
      .breadcrumb-current {
        color: var(--text-primary);
        font-weight: 600;
        display: flex;
        align-items: center;
        gap: 0.5rem;
        padding: 0.25rem 0.5rem;
        background-color: rgba(27, 67, 50, 0.05);
        border-radius: 0.375rem;
        border: 1px solid rgba(27, 67, 50, 0.1);
      }
      
      /* Search Component Styles */
      .search-container {
        background: var(--light-bg) !important;
        border-radius: 0.75rem !important;
        border: 1px solid var(--border-color) !important;
        padding: 1rem !important;
        margin-bottom: 1.5rem !important;
      }
      
      .search-container .form-label {
        font-weight: 600 !important;
        color: var(--primary-color) !important;
        margin-bottom: 0.5rem !important;
      }
      
      .search-container .form-control {
        border-radius: 0.5rem 0 0 0.5rem !important;
        border: 2px solid var(--border-color) !important;
        transition: all 0.3s ease !important;
      }
      
      .search-container .form-control:focus {
        border-color: var(--primary-color) !important;
        box-shadow: 0 0 0 0.2rem rgba(27, 67, 50, 0.15) !important;
        outline: none !important;
      }
      
      .search-container .btn {
        border-radius: 0 0.5rem 0.5rem 0 !important;
        border-left: none !important;
        border: 2px solid var(--border-color) !important;
        border-left: none !important;
        background: white !important;
        color: var(--text-secondary) !important;
        transition: all 0.3s ease !important;
      }
      
      .search-container .btn:hover {
        background: var(--primary-color) !important;
        color: white !important;
        border-color: var(--primary-color) !important;
      }
      
      .search-results-info {
        margin-top: 0.5rem !important;
        font-size: 0.85rem !important;
        color: var(--text-secondary) !important;
        font-style: italic;
      }
      
      /* Saved Views Styles */
      .saved-views-container {
        background: var(--light-bg) !important;
        border-radius: 0.75rem !important;
        border: 1px solid var(--border-color) !important;
        padding: 1rem !important;
        margin-top: 1.5rem !important;
      }
      
      .saved-views-container .form-label {
        font-weight: 600 !important;
        color: var(--primary-color) !important;
        margin-bottom: 0.75rem !important;
      }
      
      .saved-views-controls {
        display: flex !important;
        gap: 0.5rem !important;
        margin-bottom: 0.75rem !important;
      }
      
      .saved-views-controls .form-control {
        border-radius: 0.5rem !important;
        border: 2px solid var(--border-color) !important;
        transition: all 0.3s ease !important;
      }
      
      .saved-views-controls .form-control:focus {
        border-color: var(--primary-color) !important;
        box-shadow: 0 0 0 0.2rem rgba(27, 67, 50, 0.15) !important;
        outline: none !important;
      }
      
      .saved-views-controls .btn {
        border-radius: 0.4rem !important;
        border: none !important;
        font-weight: 500 !important;
        transition: all 0.3s ease !important;
        min-width: 60px !important;
        height: 42px !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        padding: 0.375rem 0.75rem !important;
      }
      
      .saved-views-controls .btn:hover {
        transform: translateY(-1px) !important;
        box-shadow: 0 4px 8px rgba(0,0,0,0.15) !important;
      }
      
      .saved-view-item {
        display: flex !important;
        justify-content: space-between !important;
        align-items: center !important;
        padding: 0.5rem !important;
        margin-bottom: 0.5rem !important;
        background: white !important;
        border-radius: 0.5rem !important;
        border: 1px solid var(--border-color) !important;
        transition: all 0.2s ease !important;
      }
      
      .saved-view-item:hover {
        box-shadow: var(--shadow-light) !important;
        border-color: var(--primary-light) !important;
        transform: translateY(-1px) !important;
      }
      
      .saved-view-item .btn {
        border-radius: 0.375rem !important;
        padding: 0.25rem 0.5rem !important;
        font-size: 0.75rem !important;
        transition: all 0.2s ease !important;
      }
      
      .saved-view-item .btn:hover {
        transform: translateY(-1px) !important;
        box-shadow: var(--shadow-light) !important;
      }
    ")),
    
    #login page background
    tags$script(HTML("
      $(document).ready(function() {
        // Check if login panel exists and apply background
        function applyLoginBackground() {
          if ($('.shinymanager-panel').length > 0) {
            $('body').css({
              'background': '#1B4332',
              'margin': '0',
              'padding': '0',
              'min-height': '100vh',
              'position': 'relative'
            });
            
            // Add left side background image
            if ($('#login-bg-left').length === 0) {
              $('body').append('<div id=\"login-bg-left\" style=\"position: fixed; top: 0; left: 0; width: 50%; height: 100vh; background-image: url(\\'login_background.png\\'); background-size: cover; background-position: center; z-index: 1; pointer-events: none;\"></div>');
            }
            
            // Add right side background
            if ($('#login-bg-right').length === 0) {
              $('body').append('<div id=\"login-bg-right\" style=\"position: fixed; top: 0; right: 0; width: 50%; height: 100vh; background-color: #1B4332; z-index: 1; pointer-events: none;\"></div>');
            }
          } else {
            // Remove login backgrounds when not on login page
            $('#login-bg-left, #login-bg-right').remove();
          }
        }
        
        // Apply on page load
        applyLoginBackground();
        
        // Use MutationObserver instead of deprecated DOMNodeInserted
        // Only observe for the login panel appearing once
        var observer = new MutationObserver(function(mutations) {
          if ($('.shinymanager-panel').length > 0) {
            applyLoginBackground();
            // Stop observing after login panel is found
            observer.disconnect();
          }
        });
        
        // Start observing for login panel
        observer.observe(document.body, {
          childList: true,
          subtree: true
        });
      });
    ")),
    
    # Logout handler
    tags$script(HTML("
      $(document).ready(function() {
        // Logout button handler
        $(document).on('click', '#logout_btn', function(e) {
          e.preventDefault();
          // Find and click the actual shinymanager logout button
          var logoutBtn = $('button[id*=\".__sm__._logout\"]');
          if (logoutBtn.length > 0) {
            logoutBtn.click();
          } else {
            // Fallback: send logout event to server
            Shiny.setInputValue('trigger_logout', Math.random(), {priority: 'event'});
          }
        });
      });
    ")),
    
    # Saved Views JavaScript
    tags$script(HTML("
      $(document).ready(function() {
        // Handle custom messages from Shiny
        Shiny.addCustomMessageHandler('loadSavedViews', function(message) {
          // Load saved views from localStorage
          var savedViews = JSON.parse(localStorage.getItem('livestock_saved_views') || '{}');
          Shiny.setInputValue('loaded_views', savedViews, {priority: 'event'});
        });
        
        Shiny.addCustomMessageHandler('saveView', function(message) {
          // Save view to localStorage
          var savedViews = JSON.parse(localStorage.getItem('livestock_saved_views') || '{}');
          savedViews[message.name] = message.filters;
          localStorage.setItem('livestock_saved_views', JSON.stringify(savedViews));
        });
        
        Shiny.addCustomMessageHandler('deleteView', function(message) {
          // Delete view from localStorage
          var savedViews = JSON.parse(localStorage.getItem('livestock_saved_views') || '{}');
          delete savedViews[message.name];
          localStorage.setItem('livestock_saved_views', JSON.stringify(savedViews));
        });
      });
    "))
    ),  # Close tags$head

    # Main navbar with pages
    page_navbar(
      title = "Livestock Dashboard",
      theme = theme,

      # ---- FILTER BAR (left) ----
      sidebar = sidebar(
    title = "Data Filters",
    width = 350,
    
    
    # Year, Month, Day
    build_date_row(dat0),
    # Sex and Treatment
    build_sex_treatment_row(dat0),
    # Breed and Mob
    build_breed_mob_row(dat0),
    # EID filter (admin only)
    uiOutput("eid_filter_ui"),
    
    # Measure select
    layout_columns(
      col_widths = c(12),
      div(
        tags$label("Measure", class="form-label"),
        pickerInput(
          "measure", NULL,
          choices = setNames(
            measure_choices,
            vapply(
              measure_choices,
              function(k) if (k %in% names(measure_labels)) measure_labels[[k]] else k,
              character(1)
            )
          ),
          selected = "finalpweight",
          multiple = FALSE,
          options = pickerOptions(
            liveSearch = TRUE,
            liveSearchPlaceholder = "Search measures...",
            dropupAuto = FALSE
          )
        )
      )
    ),
    
    # Record count display
    div(textOutput("record_count"), class = "text-muted small mt-1"),

    # Clear all filters button
    div(
      actionButton("reset_all_filters", "Clear all filters", class = "btn btn-primary w-100"),
      style = "margin-top: 0.75rem;"
    ),
    
    # ---- SAVED VIEWS ----
    div(
      class = "saved-views-container",
      style = "margin-top: 1.5rem; padding: 1rem; background: var(--light-bg); border-radius: 0.75rem; border: 1px solid var(--border-color);",
      div(
        tags$label("Saved Views", class="form-label", style = "font-weight: 600; color: var(--primary-color); margin-bottom: 0.75rem;"),
        div(
          class = "saved-views-controls",
          style = "display: flex; gap: 0.5rem; margin-bottom: 0.75rem;",
          div(
            style = "flex: 1;",
            textInput("save_view_name", NULL, placeholder = "Enter view name...", width = "100%")
          ),
          actionButton("save_current_view", "Save", class = "btn btn-success btn-sm", style = "white-space: nowrap; padding: 0.25rem 0.75rem; font-size: 0.8rem;")
        ),
        div(
          class = "saved-views-list",
          uiOutput("saved_views_list")
        )
      )
    )
  ),
  
  # ---- PAGE 1: Summary Stats ----
  nav_panel(
    "Summary Stats",
    uiOutput("empty_state"),
    uiOutput("summary_content")
  ),
  
  # ---- PAGE 2: Time Series ----
  nav_panel(
    "Time Series",
    uiOutput("empty_state_ts"),
    uiOutput("timeseries_content")
  ),
  
  # ---- PAGE 3: Distributions ----
  nav_panel(
    "Distributions",
    uiOutput("empty_state_dist"),
    uiOutput("distributions_content")
  ),
  
  # ---- PAGE 4: Cohort ----
  nav_panel(
    "Cohorts",
    uiOutput("empty_state_dist"),
    uiOutput("cohorts_content")
  ),
  
  # ---- PAGE 5: Data Management ----
  nav_panel(
    "Data Management",
    uiOutput("empty_state_data_management"),
    uiOutput("data_management_content")
  ),
  
  # ---- PAGE 6: Customise ----
  nav_panel(
    "Customise",
    customise_ui("customise1")
  ),

  # ---- PAGE 7: Reports ----
  nav_panel(
    "Reports",
    uiOutput("empty_state_reports"),
    uiOutput("reports_content")
  ),

  nav_spacer(),

      # ---- Logout Button ----
      nav_item(
        tags$a(
          id = "logout_btn",
          href = "#",
          class = "nav-link",
          icon("right-from-bracket"),
          "Logout",
          onclick = "return false;"
        )
      )
    )  # Close page_navbar
  ),  # Close tagList

  head_auth = tags$script(HTML("
  pressbtn = function(){

      // click the log in button
      document.getElementById('auth-go_auth').click();
  };
  window.onload = function() {

  // password input field
  const field = document.getElementById('auth-user_pwd');

  // add a function that preempts the enter key press
  field.addEventListener('keydown',  
  function(e) {

      if (e.keyCode == 13) {
      // prevent sending the key event
      e.preventDefault();
    
      // delay activating the login button for 400 ms. adjust time as needed
      setTimeout(pressbtn,400);
      };

  });
  }
  "
)),theme=theme, fab_position = "none"
)
