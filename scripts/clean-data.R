message("Cleaning data")
library(data.table)

# process command arguments
if (interactive()) {
  pathways <- file.path("data", "raw", "2021-12-07-pathways.csv")
  nhsonline <- file.path("data", "raw", "2021-12-07-nhs111.csv")
  lu <- file.path("data", "lookups", "Clinical_Commissioning_Group_to_STP_and_NHS_England_(Region)_(April_2021)_Lookup_in_England.csv")
  out <- file.path("data", "clean", "2021-12-07.csv")
} else {
  args <- commandArgs(trailingOnly = TRUE)
  pathways <- args[1]
  nhsonline <- args[2]
  lu <- args[3]
  out <- args[4]
}

# load files
pathways <- fread(pathways)
nhsonline <- fread(nhsonline)
lu <- fread(lu)

# clean up names
setnames(nhsonline, old = c("journeydate", "Total"), new = c("date", "count"))
setnames(pathways, old = c("SiteType", "Call Date", "TriageCount"), new = c("type", "date", "count"))
setnames(pathways, tolower)
nhsonline[, type:="111online"]

# combine tables and cleanup
pathways[,type:=as.character(type)]
dat <- rbind(pathways, nhsonline)

# convert column to date
dat[, date:=as.IDate(date, format = "%d/%m/%Y")]

# filter to June 2021 onwards
dat <- dat[date >= as.IDate("2021-06-01")]

# add nhs region value
cols <- c("NHSER21CD", "NHSER21CDH", "NHSER21NM")
dat[lu, (cols) := mget(paste0("i.", cols)), on = c("ccgcode" = "CCG21CD")]

# save out
out_folder <- dirname(out)
if (!dir.exists(out_folder)) {
  d <- dir.create(out_folder, recursive = TRUE)
  if (!d) stop("Unable to create directory %s", out_folder)
}
fwrite(dat, out)
