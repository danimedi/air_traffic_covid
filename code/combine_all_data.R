library(readr)
library(dplyr)
library(tidyr)


# read --------------------------------------------------------------------

embarking <- read_csv("data/clean/embarking.csv")
landing <- read_csv("data/clean/landing.csv")
pop <- read_csv("data/clean/provinces_population.csv")
fallecidos <- read_csv("data/clean/fallecidos_covid.csv")
positivos <- read_csv("data/clean/positivos_covid.csv")


# process flights data ----------------------------------------------------

# change the name of some airports to provinces in which they are located
change_airport_names <- function(x) {
  case_when(
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
}
embarking$`Aeródromos/Aeropuertos` <- change_airport_names(embarking$`Aeródromos/Aeropuertos`)
landing$`Aeródromos/Aeropuertos` <- change_airport_names(landing$`Aeródromos/Aeropuertos`)

# check that the names are the same
embarking$`Aeródromos/Aeropuertos`[!embarking$`Aeródromos/Aeropuertos` %in% positivos$PROVINCIA]

# trasforming to numeric
as_numeric_flights <- function(x) {
  vec <- ifelse(x == "-", NA, x)
  as.numeric(vec)
}
embarking[2:13] <- apply(embarking[2:13], 2, as_numeric_flights)
landing[2:13] <- apply(landing[2:13], 2, as_numeric_flights)

# drop the last column
embarking <- embarking[,-14]
landing <- landing[,-14]

# change the format
embarking <- embarking %>% pivot_longer(Ene:Dic, names_to = "MES")
landing <- landing %>% pivot_longer(Ene:Dic, names_to = "MES")

# change names of months to numbers
map <- setNames(1:12, unique(embarking$MES))
embarking$MES <- map[embarking$MES]
map <- setNames(1:12, unique(landing$MES))
landing$MES <- map[landing$MES]

# change column name to "PROVINCIA"
embarking <- embarking %>% rename("PROVINCIA" = "Aeródromos/Aeropuertos")
landing <- landing %>% rename("PROVINCIA" = "Aeródromos/Aeropuertos")


# process population data -------------------------------------------------

change_province_names <- function(x) {
  case_when(
    x == "SAN MARTÍN" ~ "SAN MARTIN",
    x == "SAN ROMÁN" ~ "SAN ROMAN",
    x == "JAÉN" ~ "JAEN",
    x == "LA CONVENCIÓN" ~ "LA CONVENCION",
    x == "HUÁNUCO" ~ "HUANUCO",
    x == "DATEM DEL MARAÑÓN" ~ "DATEM DEL MARAÑON",
    x == "MARISCAL RAMÓN CASTILLA" ~ "MARISCAL RAMON CASTILLA",
    x == "PURÚS" ~ "PURUS",
    x == "RODRÍGUEZ DE MENDOZA" ~ "RODRIGUEZ DE MENDOZA",
    TRUE ~ as.character(x)
  )
}
pop$provincia <- change_province_names(pop$provincia)

# check
unique(embarking$PROVINCIA[!embarking$PROVINCIA %in% pop$provincia])

# check repeated provinces (actually they are departments)
pop %>% group_by(provincia) %>% count() %>% filter(n > 1)

# deal with repeated provinces
y <- vector("list", length(unique(pop$provincia)))
k <- 1
for (i in unique(pop$provincia)) {
  x <- filter(pop, provincia == i) %>% arrange(poblacion) %>% .[1,]
  # selecting the province instead of the departament, because it has less population
  y[[k]] <- x
  k <- k + 1
}
pop <- bind_rows(y)


# filter ------------------------------------------------------------------

# filter data set by the provinces with airport
filt_positivos <- positivos %>% filter(PROVINCIA %in% landing$PROVINCIA)
filt_fallecidos <- fallecidos %>% filter(PROVINCIA %in% landing$PROVINCIA)

# deal with the repeated names of provinces in different departments
filt_fallecidos <- filt_fallecidos %>% 
  filter(!(DEPARTAMENTO == "LAMBAYEQUE" & PROVINCIA == "PIURA")) %>% 
  filter(!((DEPARTAMENTO == "CALLAO" | DEPARTAMENTO == "LAMBAYEQUE") & PROVINCIA == "LIMA"))

# check that there are not repeated names for provinces (select the provinces with airports)
filt_positivos %>% 
  group_by(DEPARTAMENTO, PROVINCIA) %>% 
  count() %>% 
  group_by(PROVINCIA) %>% 
  count() %>% 
  filter(n > 1)

filt_fallecidos %>% 
  group_by(DEPARTAMENTO, PROVINCIA) %>% 
  count() %>% 
  group_by(PROVINCIA) %>% 
  count() %>% 
  filter(n > 1)


# combine -----------------------------------------------------------------

# join positive cases and deaths by covid-19
dat <- full_join(filt_positivos, filt_fallecidos, 
                 by = c("DEPARTAMENTO", "PROVINCIA", "MES"), 
                 suffix = c("_positivos", "_fallecidos"))

# join flight data
dat <- left_join(dat, embarking, by = c("PROVINCIA", "MES")) %>% 
  left_join(landing, by = c("PROVINCIA", "MES"), suffix = c("_embarcados", "_desembarcados"))

# join population in the province
dat <- left_join(dat, pop, by = c("PROVINCIA" = "provincia"))

# change names
names(dat) <- c("departamento", "provincia", "mes", "n_positivos", "n_fallecidos", 
                "n_embarcados", "n_desembarcados", "poblacion")


# write combined data -----------------------------------------------------

write_csv(dat, "data/clean/final_data.csv")
