# V - Exploratory Data Analysis ----

# 1 - What types of variation occurs within my variables? ====

# a) Variation ####

# @note: Each variable has its own pattern of variation. 
#        The best way to understand this variation is by visualizing 
#        distribution of variable's value. Variation will come from tendency
#        of variable value to change from measurement to measurement. 

# To visualize distribution of categorical value, use a barchart
ggplot(data = diamonds) + 
  geom_bar( mapping = aes(x = cut))

# Compute count (<=> height of each bar with:)
diamonds %>% count(cut)

# Histograms are used to vis. distribution of continuous values: 
ggplot(diamonds) +
  geom_histogram(aes(x = carat), binwidth = .5)

# Compute this by hand with count + cut_width 
diamonds %>% 
  count(cut_width(carat,.5))

# Exploring different bin width 
smaller <- diamonds %>% filter(carat < 3)

smaller %>% 
  ggplot(aes(x = carat)) + 
  geom_histogram(binwidth = .1)

# To display multiple histograms (overlay them), use geom_freqpoly instad: 
smaller %>% 
  ggplot(aes(x = carat, col = cut)) +
  geom_freqpoly(binwidth = .1) ## Some issues with this plot.. 

# b) Typical and unusual values ####
# @note: Try to spot unusual patterns, look t differences / similarities between diff 'cluster'
#        Zoom in to spot unusual values

# Eggs ----
# 1. Explore x, y and z vars in diamonds set - which dim is length? Width? Depth? 
# Continuous vars: Use histogrm 
ggplot(diamonds) + 
  geom_histogram(aes(x = x), binwidth = .1) #

ggplot(diamonds) + 
  geom_histogram(aes(x = y), binwidth = 1) +
  coord_cartesian(xlim = c(0,20))

ggplot(diamonds) + 
  geom_histogram(aes(x = z), binwidth = .1) +
  coord_cartesian(xlim = c(0,10)) # The depth, with values ranging from 2.5 to 5

# Plotting it like in the sols 
ggplot(diamonds %>% 
         gather(variable, value, x, y, z), 
       aes(x = value)) + 
  geom_density() + 
  geom_rug() + 
  facet_grid(variable ~ . ) # @tresCool

# 2. Xplore the distribution of price 
ggplot(diamonds) + 
  geom_histogram(aes(x = price), binwidth = 10, center = 0)  +
   coord_cartesian(xlim = c(0, 8000))

# Big gap at ~ 1500
# Left skewed
# Look at distribution of the last digit 
ggplot(diamonds %>% 
         mutate(dig = price %% 10), 
       aes(x = dig)) + 
  geom_histogram(binwidth = 1)

# Alternatively:
diamonds %>% 
  count(cut_width(price %% 10, width = 1)) %>% 
  mutate(n = n / sum(n))


# 3. How many diamonds are .99 carats? How many are 1 carat? 
diamonds %>% 
  filter(between(carat, .99,1)) %>% 
  count(carat)

# Visualize to look at neighboring values and distribution
ggplot(diamonds %>% 
         filter(between(carat, 0, 2)),
       aes(x = carat)) + 
  geom_histogram(binwidth = .1)

# The difference can be due to 'rounding' coming from the seller side 
# Although wouldn't this mean a 1.1 carat diamond wouldn't be rounded down to 1.0? 


# 4. Compare coord_cartesian() and xlim() when zooming in on histogram. 
# Leave binwidth unset 
# What happens if you tryand zoom so only half a bar shows

ggplot(diamonds) +
  geom_histogram(aes(x = carat)) + 
  coord_cartesian(xlim = c(0,.9)) # coord cart will 'cut-off' the half bar, i.e. just zooming in 

ggplot(diamonds) +
  geom_histogram(aes(x = carat)) + 
  xlim(c(0,.9)) # The view is modified, bins = 30 is recalculated to include 30 bins in the current view (0 to 0.9)


## 3 - Missing values ====

# Which columns contain an NA in diamonds dataset 
apply(diamonds, MARGIN = 2, FUN = anyNA)
# Seems like data is clean, set a random value to NA to test 
diamonds2 <- diamonds %>% 
  mutate(x = ifelse(row_number() == 1, NA, x))

# @tip Can suppress warnings when plotting 
ggplot(diamonds2) + 
  geom_point(aes(x = x, y = y), na.rm = T)

# But what if want to understand what makes a missing value different from 
# obs with non missing value?
# In flights data -> NA in dep_time -> flight was cancelled
# COmpare scheduled ddeparture time for cancelled and non cancelled times
flights <- nycflights13::flights %>% 
  mutate(cancelled = ifelse(is.na(dep_time), 1, 0))
 flights %>% 
  ggplot(aes(x = sched_dep_time, group = as.factor(cancelled), color = as.factor(cancelled))) +
  geom_freqpoly()
 

# Can improve comparision -> there are many more non-cancelled flights than cancelled flights

# Eggs ----
# 1. Check for missing values in a histogram and barchart
ggplot(flights %>% 
         mutate(dep_time = ifelse((row_number() %% 1000) == 0, NA, dep_time)), aes(x = dep_time)) + 
   geom_histogram(binwidth = 100)
 
 ggplot(flights %>% 
          mutate(carrier = ifelse((row_number() %% 5) == 0, NA, carrier)), aes(x = as.factor(carrier))) + 
   geom_bar()
 
 ## Can also use NA_character
 ggplot(flights %>% 
          mutate(carrier = ifelse((row_number() %% 2) == 0, NA_character_, as.character(carrier))), aes(x = carrier)) + 
   geom_bar() # Actually doesn't quite work but ok 
 
 ## Artificially adding NA values -> Removed rows for geom_histogram
 # For geom_bar, NA shows up if variable is a factor. 
 
# 2 - What types of covariation occurs within my variables? ====
# Covariation: The tendency of two variables to vary together in a related way 
 
# Hard to see difference of groups when one group has a lot more observations than another
# Use density instead of count in freqplot 
 ggplot(diamonds, aes(color = cut, x = price, y = ..density..)) + 
   geom_freqpoly(binwidth = 500)
# Vs the normal: 
 ggplot(diamonds, aes(color = cut, x = price, y = ..count..)) + 
   geom_freqpoly(binwidth = 500)
 
# A lot is happening here, use a boxplot instead: 
# Look at 25th, 50th and 75th percentile to determine
# spread, symmetric / asymmetric distribution and skewness 
# Outliers shown at +- 1.5* IQR 
 ggplot(diamonds, aes(x = cut, y = price)) + 
   geom_boxplot()
 
 # Reorder to have a better look at data / differences between group 
 # With an intuitive increasing / decreasing order
 # For example, with mpg dataset
 ggplot(mpg, aes(x = class, y = hwy)) + 
   geom_boxplot()

 # Reordering with the reorder() function: 
 ggplot(mpg, aes(y = hwy, 
                 x = reorder(class, hwy, FUN = median))) + 
   geom_boxplot() # @tresCool 
 
 # + can coord flip if label long (or rotate label) 
 ggplot(mpg, aes(y = hwy, 
                 x = reorder(class, hwy, FUN = median))) + 
   geom_boxplot() + 
   coord_flip()
 