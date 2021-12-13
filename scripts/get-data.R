# Not currently used

# ---------------------------------------------------------------------------------------------
# process command arguments -------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------
if (interactive()) {
  data_folder <- file.path("data", "raw")
  pathways_suffix <- "pathways.csv"
  nhs111_suffix <- "nhs111.csv"
} else {
  args <- commandArgs(trailingOnly = TRUE)
  data_folder <- args[1]
  pathways_suffix <- args[2]
  nhs111_suffix <- args[3]
}

# ---------------------------------------------------------------------------------------------
# setup ---------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------
root <- "https://digital.nhs.uk/data-and-information/publications/statistical/mi-potential-covid-19-symptoms-reported-through-nhs-pathways-and-111-online/latest/"
pathways_pattern <- URLencode("NHS Pathways Covid-19 data_20")
nhs111_pattern <- URLencode("111 Online Covid-19 data_20")

data_folder <- file.path(data_folder, Sys.Date())
if (!dir.exists(data_folder)) {
  d <- dir.create(data_folder, recursive = TRUE)
  if (!d) stop("Unable to create directory %s", data_folder)
}

# ---------------------------------------------------------------------------------------------
# functions -----------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------
find_and_download <- function(pattern, html, folder, suffix) {
  x <- grep(pattern, html, fixed = TRUE, value=TRUE)               # find lines containing pattern
  x <- grep("onClick", x, value = TRUE, invert = TRUE, fixed=TRUE) # remove tracking
  x <- regmatches(x, regexpr("(https://.*.csv)", x, perl = TRUE))  # pull out file link
  xdate <- regmatches(x, regexpr("\\d{4}-\\d{1,2}-\\d{1,2}", x, perl=TRUE))
  outfile <- file.path(folder, paste(xdate, suffix, sep="-"))
  download.file(x, outfile)
}

# ---------------------------------------------------------------------------------------------
# download root page to find files ------------------------------------------------------------
# ---------------------------------------------------------------------------------------------
con <- url(root)
html <- readLines(con)
close(con)

# ---------------------------------------------------------------------------------------------
# download the pathways data ------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------
res1 <- find_and_download(pathways_pattern, html=html, folder=data_folder, suffix=pathways_suffix)
if (res1) stop("Unable to download pathways data")

# ---------------------------------------------------------------------------------------------
# download the nhs 111 data -------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------
res2 <- find_and_download(nhs111_pattern, html=html, folder=data_folder, suffix=nhs111_suffix)
if (res2) stop("Unable to download nhs111 data")
