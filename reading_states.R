library(dplyr)
library(janitor)
library(bigmemory)
library(googlesheets4)
library(rstanarm)
library(purrr)
library(dplyr)
library(broom)
library(readr)
library(tidyverse)

NY_file1 = "/Users/jake/Desktop/Unclaimed_data/NY/FINDERS/OWNCUR1.txt"
MA_file = "/Users/jake/Desktop/Unclaimed_data/MA/MA.txt"


##### Reading in MASSACHUSETTES #####

# Attempting to use fixed-width reading technqiues
MA.sample<- read.fwf(MA_file,
         widths= c(20, 23,	18,	200,	11,	21,	39,	23,	100,50,	50,	100,	100,	50,	50,	18),
                      strip.white=TRUE,
                       sep = "\n",
                      n = 10, 
                      skip = 1)

cols <- c("name", "street_address", "apt_suite", "city", "state", "zip", "reported_by", "last_owner", "property_type", "number_props", "unsure", "unsure2", "year_repored")

###Write sample data into CSV file to be used later on in Lat-Long Conversion. 
write.csv(MA.sample, "state_samples/new_york.csv", row.names=FALSE)

##### Reading in NEW YORK #####


ncol <- max(count.fields('NY_file1', sep = "|"))
NY.sample <- read.table(NY_file1,  
                           stringsAsFactors=TRUE, 
                           nrows = 10000, 
                           #skipNul=TRUE, 
                           header = FALSE,
                           sep = "|",
                           col.names = paste0("V",seq_len(14)), 
                           fill = TRUE)

cols <- c("name", "street_address", "apt_suite", "city", "state", "zip", "reported_by", "last_owner", "property_type", "number_props", "unsure", "unsure2", "year_repored")
colnames(NY.sample) <- cols

###Write sample data into CSV file to be used later on in Lat-Long Conversion. 
write.csv(NY.sample, "state_samples/NY.csv", row.names=FALSE)



#### Reading in CA ####

## Data 

# Defining 3 files containing data from CA for claims $500+
CA_500_plus1 = "/Users/jake/Desktop/Unclaimed_data/CA/04_From_500_To_Beyond/From_500_To_Beyond__File_1_of_3.csv"
CA_500_plus2 = "/Users/jake/Desktop/Unclaimed_data/CA/04_From_500_To_Beyond/From_500_To_Beyond__File_2_of_3.csv"
CA_500_plus3 = "/Users/jake/Desktop/Unclaimed_data/CA/04_From_500_To_Beyond/From_500_To_Beyond__File_3_of_3.csv"

# Create Sample

CA_500_plus1.sample <- read_csv(CA_500_plus1, n_max =1000)

# Combine addresses into one coluumn
CA_500_plus1.sample <- CA_500_plus1.sample %>% mutate(addresses = paste(OWNER_STREET_1,",", OWNER_CITY,",",OWNER_STATE))

# Write sample into own file
write.csv(CA_500_plus1.sample, "state_samples/CA.csv", row.names=FALSE)

