## ## ## ## 
## DPLYR ## 
## ## ## ## 

library(nycflights13)
library(tidyverse)
library(magrittr)

## ## ## ## ## ## ## ## 
## SOME USEFUL TRICKS ## 
## ## ## ## ## ## ## ## 

# If want to move some vars at beginning of df: 
# use select + everything()
select(flights, time_hour, air_time, everything())

## #### ## 
## EGGS ## 
## #### ## 

## Change dep_time and sched_dep_time to be more readable 
head(flights$dep_time)
head(flights$sched_dep_time)



# Change format for dep time and sched dep time 
convertTime_toMinutesSinceMidnight <- function(time) {
  newTime <- time %/% 100 * 60 + time %% 60 # 1st. is hours, 2nd minuttes
  return(newTime)
}
flights %<>%
  mutate(new_depTime =  convertTime_toMinutesSinceMidnight(dep_time),
         new_scheduledDepTiem = convertTime_toMinutesSinceMidnight(sched_dep_time))

not_cancelled <- flights %>% 
  filter(!is.na(dep_delay), !is.na(arr_delay))

# Find 10 most delayed flights
flights2<- flights %>% 
  mutate(dep_delay2 = convertTime_toMinutesSinceMidnight(dep_time) -
           convertTime_toMinutesSinceMidnight(sched_dep_time)) %>% 
  mutate(mostDelayedFlight = min_rank(-dep_delay2)) %>%  # same as min_rank(desc(...))
  arrange(mostDelayedFlight) %>%
  filter(mostDelayedFlight < 10)

## ##  ## ## 
## COUNTS ##
## ##  ## ## 

print("
When aggregating, always a good idea to include a count n() 
or sum(!is.na(x)) to make sure not looking at subset of data 
example:
      ")

delays <- not_cancelled %>% 
  group_by(tailnum) %>% 
  summarize(delay = mean(arr_delay))

ggplot(delays, aes(x = delay)) + 
  geom_freqpoly(binwidth = 10)

## Some airplanes have delays of more than 300 mins???
# Look at count + scatterplot of # of flights vs avg delay 
delays <- not_cancelled %>% 
  group_by(tailnum) %>% 
  summarise(delay = mean(arr_delay),
            count = n())

ggplot(delays) + 
  geom_point(aes(x = count, y = delay), alpha = 1/10)

#  Variation decreases as the sample size increases 
# -> much greater variation in the average delay when there are few flights 

## Filter out points that do not have many observations to look 
# at general pattern 
delays %>% 
  filter(count > 25) %>% 
  ggplot() + 
  geom_point(aes(x = count, y = delay), alpha = 1/10)  

## ## ## ## ## ## ## ## 
## SUMMARY FUNCTIONS ## 
## ## ## ## ## ## ## ##

# Neasures of location 
# Can combine aggregation with logical subsetting: 
not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarize(avg_delay1 = mean(arr_delay), 
            avg_delay2 = mean(arr_delay[arr_delay > 0]))


## Measures of variation - e.g. why is distance to some destinations more var than others 
# IQR would be more robust if have outliers
not_cancelled %>% 
  group_by(dest) %>% 
  summarise(dist = sd(distance)) %>% 
  arrange(desc(dist))

# Measures of rank -  e,g, min max quantile etc... 

# Measures of position, first, nth, last 
# First and last equivalent to filtering on rank 
not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarize(r = min_rank(desc(dep_time))) %>% 
  filter(r %in% range(r))

# Counts - e.g n(), sum(!is.na()), n_distinct()
not_cancelled %>% 
  group_by(dest) %>% 
  summarise(carriers = n_distinct(carrier)) %>% 
  arrange(desc(carriers))

# Can also use weight var 
not_cancelled %>% 
  count(tailnum, wt = distance)

## Counts can be used to calculate # of trues and prop of trues 
not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(n_early = sum(dep_time < 500)) # How many flights left before 5 am 

# What prop of flights are delayed by more than an hour
not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(hour_perc = mean(arr_delay > 60))

## ## ## ## ## # ## ## ## ## ## 
## GROUPING W/ MULTIPLE VARS ## 
## ## ## ## ## # ## ## ## ## ## 

# @Note: Each summary peels off one level of the grouping 
# !!! about weighted means and variance

## #### ## 
## EGGS ## 
## #### ## 


