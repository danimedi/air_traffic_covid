library(tabulizer)
library(stringr)
library(readr)

# extract data for provinces using an area to recognize tables
dat <- extract_tables("data/raw/poblacion_peru_INEI.pdf",
                      pages = 45:49, output = "matrix", guess = FALSE,
                      area = list(c(93.57125, 80.97610, 772.82062, 515.61607)),
                      encoding = "UTF-8")

# filter the data to have only the population in 2020
filt_dat <- lapply(dat, function(mtrx) {
  mtrx[-c(1, nrow(mtrx)), c(2, ncol(mtrx))]
})
# deal with some problems in the last table
filt_dat[[5]] <- dat[[5]][c(-1,-45),c(1,5)]
filt_dat[[5]][,1] <- filt_dat[[5]][,1] %>% str_remove_all("\\d+\\s")
# combine data and transform the data
final_dat <- do.call(rbind, filt_dat) %>% as.data.frame()
final_dat[,2] <- final_dat[,2] %>% str_remove_all("\\s") %>% as.numeric()
names(final_dat) <- c("provincia", "poblacion")

write_csv(final_dat, "data/clean/provinces_population.csv")
