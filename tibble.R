library(tidyverse)
library(lubridate)
library(nycflights13)


installprint('Benefits of using tibbles vs vanilla data frames:
- Never changes data types (e.g. from string to factor)
- Never changes name of variables
- Doesnt create row names 
- Printing and subsetting
  - For printing, shows first 10 rows and as many columns as can fit (in console)
    Each column reports its type
- Subsetting: 
  - tibbles will generate warning if column does not exist
  - Never do partial matching
      ')

# Creating tibbles ----

# To create a tibble with non syntactic names, use backticks (``)
tb <- tibble(
  `:)` = "test",
  `123` = 1:3
)

# Creating tribbles -> transposed tibbles
# Use tribbles to create small tibbles in an easy to read form 
trb <- tribble(
  ~x, ~y, ~z, 
  #--|--|--
  "a", 2, 3.6, 
  "b", 1, 2
)

# Differences in printing ----

# now and today display current andtoday's date respectively 
# runif generates random deviates, with 1e3 number of observations herem between 0 and 1 by default.
(long_tbl <- tibble(
  a = lubridate::now() + runif(1e3) * 86400, 
  b = lubridate::today() + runif(1e3) * 30, 
  c = 1:1e3, 
  d = runif(1e3),
  e = sample(letters, 1e3, replace = T)
))


## Options for printing tibble 
print(long_tbl, n = 10, width = Inf)
print(flights %>% as_tibble(), n = 10, width = Inf)

# Alternatively, can modify options and change default print behavior
# options(tibble.print_max = n, tibble.print_min = m) # If there are more than m rows, just print n rows
# options(dplyr.print_min = Inf) # Always show all columns

# @trescool -> to look helper function of packages (equivalent of ?function), do package?<package_name>)
# E.g. can see more options with package?tibble 

# Differences in subsetting ----
df <- tibble(
  x = runif(5), y = rnorm(5))

df$x # Extract by name 
df[[1]] # Extract by position with [[]]
df[["x"]] # With name -> returns a vector
df["x"]# What about single brackets? -> returns a tibble, same type as df

# if want to pipe, have to use "." placeholder
df %>% .$x
df %>% .[[1]]

# Interacting with older code ----
# Some functions don't work with tibbles, mostly of what was seen above, the single bracket
# In base R, [] sometimes returns a data frame, sometimes a vector
# In tibble, it always returns a tibble
# Solution: Use as.data.frame() to reconvert tibble to df


# EGGS ----

# 1. How to tell if object is a tibble 
class(mtcars)
class(as_tibble(mtcars))

# 2. Compare different operations of data frames and tibbles
df <- data.frame(abc = 1, xyz = "a") # xyz is a factor here
tb <- tibble(abc = 1, xyz = "a") # xyz is a character vector here
df$x # Partial matching - never knew this could work 
tb$x # throws an error
df[,'xyz']
tb[,"xyz"] # again, factors vs strings
df[,c("abc", "xyz")]
tb[,c("abc", "xyz")] # Not sure what the problem is here 

# 3. If have name of var stored in object, how can you extract the reference var from a tibble 
var <- "mpg"
mtcars$var # df - doesnt work 
mtcars[[var]] # works 
# for tibble: 
mtcars_tbl <- as_tibble(mtcars)
mtcars_tbl[[var]]

# 4. Practiec referring to non syntactic names in the following dfs: 
annoying <- tibble(
  `1` = 1:10, 
  `2` = `1` * 2 + rnorm(length(`1`)))
# 4.1 
annoying[['1']]
annoying$`1`

# 4.2 
ggplot(annoying, aes(`1`, `2`)) + geom_point()

# 4.3 
annoying$`3` <- annoying$`2`/ annoying$`1`

# 4.4 
annoying %>% 
  rename("one" = `1`, "two" = `2`, 'three' = `3`)

#5. What does tibble.enframe() do? When might you use it? 
?enframe
enframe(c('a','b','c')) 

#6. Changing options of footer 
package?tibble
options(tibble.max_extra_cols = 100)
# print(tibble(a = 1:100))
