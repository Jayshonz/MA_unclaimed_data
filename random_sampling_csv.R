# generate some random numbers between 1 and how many rows your files has,
# assuming you can ballpark the number of rows in your file
#
# Generating 900 integers because we'll grab 10 rows for each start, 
# giving us a total of 9000 rows in the final
start_at  <- floor(runif(900, min = 1, max = (1000000 - 10) ))

# sort the index sequentially
start_at  <- start_at[order(start_at)]

# Read in 10 rows at a time, starting at your random numbers, 
# binding results rowwise into a single data frame
NAME  <- map_dfr(start_at, ~read_csv("FILENAME", n_max = 10, skip = .x))
