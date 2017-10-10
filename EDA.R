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
  facet_grid(variable ~ . ) # Tres cool

# 2. Xplore the distribution of price
ggplot(diamonds) + 
  geom_histogram(aes(x = price), binwidth = 10, center = 0)  +
   coord_cartesian(xlim = c(0, 8000))


# 2 - What types of covariation occurs within my variables? ====