library(blastula)

create_smtp_creds_key(
  id = "weekly_report_email",
  user = "sarahaikositompul0625@gmail.com",
  provider = "gmail",
  use_ssl = TRUE,
  overwrite = TRUE
)

cat("email credentials have been set up!")