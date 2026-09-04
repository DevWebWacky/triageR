library(shiny)
library(triageR)
library(bslib)

ui <- page_sidebar(
  title = "triageR: Clinical Prediction Modelling",
  theme = bs_theme(primary = "#2C5F8A", base_font = font_google("Montserrat")),

  sidebar = sidebar(
    width = 350,
    fileInput("datafile", "Upload clinical data (CSV)", accept = ".csv"),
    uiOutput("id_col_ui"),
    uiOutput("outcome_ui"),
    selectInput("engine", "Model engine",
                choices = c("Logistic Regression" = "logistic_reg",
                            "Random Forest" = "random_forest",
                            "XGBoost" = "boost_tree")),
    sliderInput("split", "Training set proportion", min = 0.5, max = 0.9, value = 0.7, step = 0.05),
    actionButton("run", "Fit & Validate Model", class = "btn-primary w-100"),
    hr(),
    downloadButton("download_report", "Download TRIPOD+AI Report", class = "btn-outline-primary w-100")
  ),

  navset_tab(
    nav_panel("Data Preview",
              h4("Uploaded Data"),
              tableOutput("data_preview"),
              h4("Missing Data Summary"),
              tableOutput("missing_summary")
    ),
    nav_panel("Validation Results",
              h4("Performance Metrics"),
              tableOutput("metrics_table"),
              layout_columns(
                plotOutput("roc_plot"),
                plotOutput("calibration_plot")
              )
    ),
    nav_panel("Explainability",
              h4("Variable Importance (Permutation)"),
              plotOutput("explain_plot")
    ),
    nav_panel("Pipeline Review",
              h4("Automated Pipeline Review"),
              tableOutput("review_flags")
    ),
    nav_panel("AI Assistant",
              p("Optional: requires a configured Gemini API key on the server running this app."),
              actionButton("get_recommendation", "Get AI Method Recommendation", class = "btn-secondary"),
              br(), br(),
              uiOutput("recommendation_text")
    )
  )
)

server <- function(input, output, session) {

  raw_data <- reactive({
    req(input$datafile)
    read.csv(input$datafile$datapath, stringsAsFactors = FALSE)
  })

  output$id_col_ui <- renderUI({
    req(raw_data())
    selectInput("id_col", "Patient ID column",
                choices = c("(Auto-generate row ID)" = "__auto_id__", names(raw_data())))
  })

  output$outcome_ui <- renderUI({
    req(raw_data())
    selectInput("outcome_col", "Outcome column (binary)", choices = names(raw_data()))
  })

  output$data_preview <- renderTable({
    req(raw_data())
    head(raw_data(), 10)
  })

  loaded_data <- reactive({
    req(raw_data(), input$id_col)
    df <- raw_data()
    if (input$id_col == "__auto_id__") {
      df$row_id <- seq_len(nrow(df))
      tr_load_clinical(df, id_col = "row_id")
    } else {
      tr_load_clinical(df, id_col = input$id_col)
    }
  })

  output$missing_summary <- renderTable({
    req(loaded_data())
    suppressMessages(tr_check_missing(loaded_data()))
  })

  model_results <- eventReactive(input$run, {
    req(loaded_data(), input$outcome_col, input$engine)

    withProgress(message = "Fitting and validating model...", value = 0, {
      incProgress(0.2, detail = "Preparing data")
      df <- loaded_data()
    id_to_drop <- if (input$id_col == "__auto_id__") "row_id" else input$id_col
    df <- df[, setdiff(names(df), id_to_drop)]

    n <- nrow(df)
    set.seed(42)
    train_idx <- sample(seq_len(n), size = floor(input$split * n))
    train <- df[train_idx, ]
    test <- df[-train_idx, ]

    incProgress(0.2, detail = "Fitting model")
    model <- tr_fit(train, outcome = input$outcome_col, engine = input$engine)

    incProgress(0.3, detail = "Validating model")
    validation <- suppressMessages(suppressWarnings(tr_validate(model, newdata = test)))

    incProgress(0.2, detail = "Running pipeline review")
    review <- tr_agent_review(train, model, use_agent = FALSE)

    incProgress(0.1, detail = "Done")
    list(model = model, validation = validation, review = review,
         train = train, test = test)
    })
  })

  output$explain_plot <- renderPlot({
    req(model_results())
    explanation <- tr_explain(model_results()$model, method = "permutation")
    explanation$plot
  })

  output$recommendation_text <- renderUI({
    req(rec_result())
    tags$div(class = "border rounded p-3 bg-light", style = "white-space: pre-wrap;", rec_result())
  })

  rec_result <- eventReactive(input$get_recommendation, {
    req(model_results())
    withProgress(message = "Asking AI agent for a recommendation...", value = 0.5, {
      tryCatch(
        tr_recommend_method(model_results()$train, outcome = input$outcome_col),
        error = function(e) paste(
          "The AI agent is temporarily unavailable (this uses a free-tier API",
          "that occasionally experiences high demand). This does not affect",
          "any of triageR's core modelling, validation, or reporting",
          "features, only this optional AI suggestion. Please try again",
          "in a moment."
        )
      )
    })
  })

  output$download_report <- downloadHandler(
    filename = function() "triageR_report.html",
    content = function(file) {
      req(model_results())
      withProgress(message = "Generating report...", value = 0.5, {
        report_path <- tr_tripod_report(
          model = model_results()$model,
          validation = model_results()$validation,
          review = model_results()$review,
          output_file = file.path(tempdir(), "shiny_report"),
          format = "html"
        )
        file.copy(report_path, file, overwrite = TRUE)
      })
    }
  )

  output$metrics_table <- renderTable({
    req(model_results())
    model_results()$validation$metrics
  })

  output$roc_plot <- renderPlot({
    req(model_results())
    model_results()$validation$roc_plot
  })

  output$calibration_plot <- renderPlot({
    req(model_results())
    model_results()$validation$calibration_plot
  })

  output$review_flags <- renderTable({
    req(model_results())
    flags <- model_results()$review$flags
    if (nrow(flags) == 0) {
      data.frame(Message = "No major issues flagged.")
    } else {
      flags
    }
  })
}

shinyApp(ui, server)
