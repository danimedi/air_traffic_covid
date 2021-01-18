library(readr)

files <- list.files("data/raw/covid_peru/", pattern = "fallecidos", full.names = TRUE)
last_file <- files[length(files)]
fallecidos <- read_csv(last_file)

files <- list.files("data/raw/covid_peru/", pattern = "positivos", full.names = TRUE)
last_file <- files[length(files)]
positivos <- read_csv(last_file)

# combine the data into one data set
