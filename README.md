# sonaR

## *This package is not under active development*
## *See [sonarlight](https://github.com/KennethTM/sonarlight) for a Python alternative*

### R-package for reading data from recreational sonars
### Currenly supports Lowrance '.sl2' and '.sl3' file formats


#### Installation

Use the 'remotes' package to install the package from Github:

```r
remotes::install_github('KennethTM/sonaR')
```

#### Examples of useage

Reading and plotting data:

```r
library(sonaR)

#Read .sl2/sl3 file
#Read function implemented using Rcpp to speed it up
sl <- sonar_read("Path to file")

#Inspect data
print(sl)

#Subset data
sl_sub <- sl[0:10000,]

#Get data from primary channel and plot it
sl_primary <- sonar_image(sl_sub, channel = "Primary")

sonar_show_image(sl_primary)

#Get data from sidescan channel and plot it
sl_sidescan <- sonar_image(sl_sub, channel = "Sidescan")

sonar_show_image(sl_sidescan)
```

![Example of sonar data from the 'Primary' channel](https://github.com/KennethTM/sonaR/blob/master/test/primary_example.png)

![Example of sonar data from the 'Sidescan' channel](https://github.com/KennethTM/sonaR/blob/master/test/sidescan_example.png)

Georeferencing data:

```r
#Georefence sonar sidescan data
sl_geo <- sonar_sidescan_geo(sl_sub)
plot(sl_geo, col = heat.colors(10))
```

