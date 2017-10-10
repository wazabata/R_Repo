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

## Equivalent 
not_cancelled %>% 
  count(dest)
# <==> 
not_cancelled %>% 
  group_by(dest) %>% 
  summarise(count = n()) %>% 
  select(dest,count)

not_cancelled %>% 
  count(tailnum, wt = distance)
not_cancelled %>% 
  group_by(tailnum) %>% 
  summarise(count = sum(distance))

View(flights %>%
       filter(is.na(dep_delay)))
#Instead of doing  is.na(dep_delay) | is.na(arr_delay)
# Can just check if dep_time is na 

# # of cancelled flights per day 
flights %>% 
  mutate(cancelled = (is.na(dep_delay) | is.na(arr_delay))) %>% 
  group_by(year, month, day) %>% 
  summarise(count = sum(cancelled, na.rm = T),
            average_dep_delay = mean(dep_delay, na.rm = T),
            prop_cancelled = mean(cancelled)) %>% 
  ggplot(aes(x = average_dep_delay, y = prop_cancelled)) + 
  geom_point() + 
  geom_smooth()

## Worst carrier 
flights %>% 
  group_by(carrier) %>% 
  summarise(average_delay = mean(arr_delay, na.rm = T)) %>% 
  arrange(desc(average_delay))

## Count before first delay greater than an hour
View(not_cancelled %>% 
  mutate(bad_delay = (arr_delay > 60),
         i = 1) %>%
  group_by(tailnum) %>%
  arrange(tailnum, year, month, day) %>% 
  mutate(numb_flights = cumsum(i)) %>% 
  filter(bad_delay == T) %>% 
  summarise(first_flight = first(numb_flights)))
  

# Alternatively
View(not_cancelled %>% 
  mutate(bad_delay = arr_delay > 60) %>% 
  group_by(tailnum) %>% 
  arrange(tailnum, year, month, day) %>%
  mutate(count = cumsum(bad_delay)) %>% 
  filter(count < 1) %>% 
    count(sort = T))


## Count -> sort argument sort count insted of doing arrange(count)

###############
## LAST EGGS ##
###############

not_cancelled %>% 
  group_by(tailnum) %>% 
  summarise(mean_delay = mean(arr_delay, na.rm = T)) %>% 
  filter(mean_delay == max(mean_delay))

View(not_cancelled %>% 
  mutate(dep_timeHour = floor(dep_time / 100)) %>% 
  group_by(dep_timeHour) %>% 
  summarise(mean_delay = mean(arr_delay) + mean(dep_delay)) %>% 
  arrange(mean_delay))

## Verify with plots 
# not_cancelled %>% 
#   mutate(total_delay = arr_delay + dep_delay) %>% 
#   ggplot() +
#   geom_point(aes(x = dep_time, y = total_delay)) +
#   geom_smooth(method = lm)



# For each dest -> total minutes of delay 
dest_delay <- not_cancelled %>% 
  group_by(dest) %>% 
  summarise(total_delay = sum(arr_delay) + sum(dep_delay))
# Proportion of the total delay for its destination
# Do it in one go 
not_cancelled %>% 
  group_by(dest) %>% 
  filter(arr_delay > 0) %>% 
  mutate(prop_delay = arr_delay / sum(arr_delay)) %>% 
  select(year:day, dest, arr_delay, prop_delay)
 
# How delay of one flight related to delay of the flight directly after it 
timeDiffBetweenFlights <- not_cancelled %>% 
  filter(dep_delay > 0) %>% 
  arrange(year, month, day, new_depTime) %>%
  mutate(diffBetweenTimes = (new_depTime - lag(new_depTime)) %% (24 * 60)) %>%
  select(year:day, tailnum, new_depTime, dep_delay, diffBetweenTimes)

# FInd cuttoff for diff between last flight of day (in AM of next day)
# and first flight of the day  by plotting (arbitrary?) #
timeDiffBetweenFlights %>% filter(between(new_depTime, 200, 600)) %>%
  filter(diffBetweenTimes > 70) %>% 
ggplot() +
  geom_point(aes(x = new_depTime, y = diffBetweenTimes))

# Set first flight of the day delay as = 0, assume first flight happens 
# between 5 and 6 AM 
View(timeDiffBetweenFlights %<>% 
  mutate(firstFlightOfDay = ifelse((new_depTime >= 300 & new_depTime <= 360) 
                                   & diffBetweenTimes > 60, T, F)))

# How many did we get
nrow(timeDiffBetweenFlights %>% 
  group_by(year, month, day) %>% 
  summarise(nday = 1)) # 1 year 
nrow(timeDiffBetweenFlights %>% filter(firstFlightOfDay == T)) # only 228 

# Change way of doing this! 
