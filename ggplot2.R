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
ggplot(mpg) + 
  geom_point()
