library(readr)
library(dplyr)
library(lubridate)

# first, select the latest files from the folder with covid data

files <- list.files("data/raw/covid_peru/", pattern = "fallecidos", full.names = TRUE)
last_file <- files[length(files)]
fallecidos <- read_csv2(last_file)
fallecidos[,"FECHA_FALLECIMIENTO"] <- ymd(fallecidos[,"FECHA_FALLECIMIENTO"][[1]])
# obtain just the month
fallecidos[,"FECHA_FALLECIMIENTO"] <- month(fallecidos[,"FECHA_FALLECIMIENTO"][[1]])

files <- list.files("data/raw/covid_peru/", pattern = "positivos", full.names = TRUE)
last_file <- files[length(files)]
positivos <- read_csv2(last_file)
positivos[,"FECHA_RESULTADO"] <- ymd(positivos[,"FECHA_RESULTADO"][[1]])
# obtain just the month
positivos[,"FECHA_RESULTADO"] <- month(positivos[,"FECHA_RESULTADO"][[1]])

# pipes to save files

fallecidos %>% 
  rename(MES = FECHA_FALLECIMIENTO) %>% 
  group_by(DEPARTAMENTO, PROVINCIA, MES) %>% 
  count() %>% 
  write_csv("data/clean/fallecidos_covid.csv")

positivos %>% 
  rename(MES = FECHA_RESULTADO) %>% 
  group_by(DEPARTAMENTO, PROVINCIA, MES) %>% 
  count() %>% 
  write_csv("data/clean/positivos_covid.csv")
