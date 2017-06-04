library(tidyverse)

ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy))

## #### ##
## EGGS ##
## #### ##

ggplot(data = mpg)
nrow(mtcars)
ncol(mtcars)
?mpg
ggplot(data = mpg) +
  geom_point(mapping = aes(x = cyl, y = hwy))
ggplot(data = mpg) +
  geom_point(mapping = aes(x = drv, y = class))

## ## ## ## ## ## ## ## 
## Aesthetic Mapping ## 
## ## ## ## ## ## ## ## 

# Check if outlier cars with higher than avg mileage and rel. large displacements
# Are subcompact vehicles

# Use different levels of an aesthetic property (diff levels of size, cols, shape...2)
ggplot(mpg) + 
  geom_point(aes(x = displ, y = hwy, col = class))

## #### ##
## EGGS ##
## #### ##

ggplot(data = mpg) +
  geom_point(
    mapping = aes(x = displ, y = hwy, color = "blue")
  ) # Not blue because color inside of aes? it's as if color = x, with x <- "blue"

# Instead, do: 
ggplot(data = mpg) +
  geom_point(
    mapping = aes(x = displ, y = hwy), color = "blue"
  )

# Mapping a continous var to color, size, shape. Then categorical
str(mpg)
ggplot(mpg) + 
  geom_point(aes(x = displ, y = hwy, col = class))
# For continuous variables:
# Color -> gradient  
# Size -> selects a couple of sizes 
# Shape -> Error: A continuous variable cannot be mapped to shape. 
# For categorical vars, works as expected. 

# Same variable to multiple aestethics: 
ggplot(mpg) +
  geom_point(aes(x = displ, y = hwy, col = class, size = class))
# Works as expected, legend is changed accordingly too. 

# Stroke aes: for shapes that have a border, can color outside seperatly
ggplot(mpg) + geom_point(aes(x = displ, y = hwy), shape = 21, stroke = 5)

# mapping an aes to something else than a var 
ggplot(mpg) +
  geom_point(aes(x = displ, y = hwy, col = displ < 5)) # Like magic 

## ## ## ### 
## FACETS ## 
## ## ## ###

# Split cat. data with facets, with each subplot displaying one subset of the data 
# First argumnent is R formula object, should be categorical var
ggplot(mpg) +
  geom_point(aes(x = displ, y = hwy)) +
  facet_wrap(~ class, nrow = 2)

# To facet with a combo of 2 vars, use facet_grid
ggplot(mpg) +
  geom_point(aes(x = displ, y = hwy)) +
  facet_grid(drv ~ cyl) 
# ggplot(mpg) +
#   geom_point(aes(x = displ, y = hwy)) +
#   facet_grid(cyl~drv) 

ggplot(mpg) +
  geom_point(aes(x = displ, y = hwy)) +
  facet_grid(cyl ~ .) # To not use rows or col. 

## #### ## 
## EGGS ## 
## #### ## 

# Try facet-ing a cont variable
ggplot(mpg) +
  geom_point(aes(x = displ, y = hwy)) +
  facet_wrap(~hwy) # LOTSA values - seems like it takes it like factor

ggplot(mpg) +
  geom_point(mapping = aes(x = drv, y = cyl))
# Compare this to facet_grid(drv ~ cyl) empty cells 
# Empty cell = empty point in plot above 
# For cells that do have the corresponding drv, cyl combo -> 
# get a more in depth view on displ and hwy values

## What does this do? 
ggplot(mpg) +
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_grid(drv ~ .) # Plot on one col only 

ggplot(mpg) +
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_grid(. ~ cyl) # plot on one row only

## How about
ggplot(mpg) +
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_grid(~ cyl) # Same as the above 

## Advantages and cons of faceting - compare with 1st facet code
ggplot(mpg) +
  geom_point(aes(x = displ, y = hwy, col = class))
# Pro: easier seperation of data (if have a lot of data points)
# Can see finer details for every group 
# Con: (and advantage of using aesthetics): how do different variables 'interact' 

## ## ## ## ## ## 
## Geom Object ## 
## ## ## ## ## ## 

ggplot(mpg) +
  geom_point(aes(x = displ, y = hwy, col = drv)) +
  geom_smooth(aes(displ, hwy, col = drv, linetype = drv))

# OR 
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(color = class)) +
  geom_smooth() # Neat 

# Can use same idea to specify different 
# data for each layer 
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(color = class)) +
  geom_smooth(
    data = filter(mpg, class == "subcompact"),
    se = F
)

## #### ## 
## EGGS ## 
## #### ## 
ggplot(mpg, aes(x = displ, y= hwy, color = drv)) +
  geom_point() + 
  geom_smooth(se = F)

ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point() +
  geom_smooth(se = F)

ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point() +
  geom_smooth(se = F, aes(group = drv))

ggplot(mpg, aes(x = displ, y = hwy, col = drv)) +
  geom_point() +
  geom_smooth(se = F)

ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(color = drv)) +
  geom_smooth(se = F)

ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(col = drv)) +
  geom_smooth(se = F, aes(linetype = drv))

ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(col = drv))

## ## ## ## ## ## ## ## ## 
## Stat. Transformation ##
## ## ## ## ## ## ## ## ##

print("
@note: The algorithm used to calc. new values for a graph 
called stat (for statistical transformation)
Each geom uses a default stat argument 
@note: ?geom_bar (or other) and search for computed variables
      ")
# Can use geom and stat interchangeably
# e.g:
ggplot(diamonds) + geom_bar(aes(x = cut))
ggplot(diamonds) + stat_count(aes(x = cut))

print("
      @note: The above works because every stat
has a default geom and every geom has a def stat. 
 If want to set your own y for bar chart, use stat = 'identity'
      ")
# Proportion bar chart 
ggplot(diamonds) + geom_bar(aes(x = cut, y = ..prop.., group = 1)) # @question: What does group do? 

# Summarize y values for every x 
ggplot(diamonds) + geom_bar(aes(x = cut, y = depth))
