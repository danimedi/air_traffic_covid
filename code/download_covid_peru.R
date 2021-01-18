# positive cases
download.file(
  url = "https://cloud.minsa.gob.pe/s/Y8w3wHsEdYQSZRp/download",
  destfile = paste0("data/raw/covid_peru/", "positivos_", Sys.Date())
)

# deaths
download.file(
  url = "https://cloud.minsa.gob.pe/s/Md37cjXmjT9qYSa/download",
  destfile = paste0("data/raw/covid_peru/", "fallecidos_", Sys.Date())
)
