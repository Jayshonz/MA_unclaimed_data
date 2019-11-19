library(dplyr)
library(janitor)
library(bigmemory)
library(googlesheets4)
library(rstanarm)
library(purrr)
library(dplyr)
library(broom)
library(readr)
library(ggmap)
library(tidyverse)


# Defining 3 files containing data from CA for claims $500+
CA_500_plus1 = "/Users/jake/Desktop/Unclaimed_data/CA/04_From_500_To_Beyond/From_500_To_Beyond__File_1_of_3.csv"
CA_500_plus2 = "/Users/jake/Desktop/Unclaimed_data/CA/04_From_500_To_Beyond/From_500_To_Beyond__File_2_of_3.csv"
CA_500_plus3 = "/Users/jake/Desktop/Unclaimed_data/CA/04_From_500_To_Beyond/From_500_To_Beyond__File_3_of_3.csv"


# Reading zip code income data in.
ca_zip <- read_csv("/Users/jake/Desktop/Unclaimed_data/CA/Demo/CA_Income_Zip.csv") %>% select(1:9) %>% clean_names()
ca_zip <- ca_zip %>% mutate(income_hh = ca_agi/returns) %>% select(zip_code, income_hh)
ca_zip %>% ggplot(aes(x=zip_code, y=income_hh)) + geom_col()

#Read in CA Data to object, drop rows w no address
CA_500_plus1.sample <- read_csv(CA_500_plus1) %>% drop_na(OWNER_STREET_1) %>% clean_names() 
#Remove dashes from zips
CA_500_plus1.sample <- CA_500_plus1.sample %>% mutate(owner_zip = gsub('[-]', '', owner_zip))
# Group by and summarize by Zip & Value
cash_by_zip <-CA_500_plus1.sample %>% group_by(owner_zip) %>% summarize(value = sum(current_cash_balance))

# Join Zip Code income and value tables

jcash_by_zip<- cash_by_zip %>% full_join(ca_zip, by = c("owner_zip"="zip_code")) %>% na.omit() %>% filter(income_hh >0,
                                                                                                          value >10000, 
                                                                                                          owner_zip != 91521)
## 
jcash_by_zip %>% ggplot(aes(x=reorder(owner_zip, desc(income_hh)), y = value, fill=income_hh)) + 
  geom_col() +
  labs(x="Zip Code by HH Income",
       y="Aggregate Unclaimed Value") +
      scale_colour_gradientn(high = "Red", low = "Yellow")

# Map column 
CA_500_plus1.sample %>% drop_na(owner_zip) %>% ggplot(aes(owner_zip)) + geom_bar()

ca_zip %>% ggplot(aes(x=zip_code, y=income_hh)) + geom_col()
      

