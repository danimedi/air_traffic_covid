library(readr)

embarking <- read_csv("data/clean/embarking.csv")
landing <- read_csv("data/clean/landing.csv")
pop <- read_csv("data/clean/provinces_population.csv")
fallecidos <- read_csv("data/clean/fallecidos_covid.csv")
positivos <- read_csv("data/clean/positivos_covid.csv")

# change the name of some airports to provinces in which they are located
x <- embarking$`Aeródromos/Aeropuertos`
embarking$`Aeródromos/Aeropuertos` <- case_when(
  x == "CUZCO" ~ "CUSCO",
  x == "IQUITOS" ~ "MAYNAS",
  x == "TARAPOTO" ~ "SAN MARTIN",
  x == "PUCALLPA" ~ "CORONEL PORTILLO",
  x == "JULIACA" ~ "SAN ROMAN",
  x == "AYACUCHO" ~ "HUAMANGA",
  x == "PUERTO MALDONADO" ~ "TAMBOPATA",
  x == "LAS MALVINAS" ~ "LA CONVENCION",
  x == "YURIMAGUAS" ~ "ALTO AMAZONAS",
  x == "SAN LORENZO" ~ "DATEM DEL MARAÑON",
  x == "CONTAMANA" ~ "UCAYALI",
  x == "PIÁS" ~ "PATAZ",
  x == "ANDOAS" ~ "DATEM DEL MARAÑON",
  x == "NUEVO MUNDO" ~ "LA CONVENCION",
  x == "EL ESTRECHO" ~ "MAYNAS",
  x == "CHAGUAL" ~ "PATAZ",
  x == "TINGO MARIA" ~ "LEONCIO PRADO",
  x == "CABALLOCOCHA" ~ "MARISCAL RAMON CASTILLA",
  x == "TROMPETEROS/CORRIENTES" ~ "LORETO",
  x == "PUERTO ESPERANZA" ~ "PURUS",
  x == "SEPAHUA" ~ "ATALAYA",
  TRUE ~ as.character(x)
)

# check that the names are the same
embarking$`Aeródromos/Aeropuertos`[!embarking$`Aeródromos/Aeropuertos` %in% positivos$PROVINCIA]

# check that there are not repeated names for provinces (select the provinces with airports)
positivos %>% 
  group_by(DEPARTAMENTO, PROVINCIA) %>% 
  count() %>% 
  group_by(PROVINCIA) %>% 
  count() %>% 
  filter(n > 1)

fallecidos %>% 
  group_by(DEPARTAMENTO, PROVINCIA) %>% 
  count() %>% 
  group_by(PROVINCIA) %>% 
  count() %>% 
  filter(n > 1)

