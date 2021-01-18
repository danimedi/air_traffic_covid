library(readxl)
library(readr)

embarking <- read_xls("data/raw/7. Pasajeros Embarcados por Ciudades a Nivel Nacional (2020)..xls",
                        range = "A6:N46")
embarking <- embarking[-1,]
write_csv(embarking, "data/clean/embarking.csv")


landing <- read_xls("data/raw/8. Pasajeros Desembarcados por Ciudades a Nivel Nacional (2020)..xls",
                    range = "A6:N46")
landing <- landing[-1,]
write_csv(landing, "data/clean/landing.csv")
