library(purrr)
library(here)
library(sf)
library(tidyverse)
#------ Read shap files form .zip -------
read_zip_shp <- function(uf){
  zip_path <- paste0(here(), '/dados/', uf, '_Municipios_2022.zip')
  temp_dir <- tempdir()
  
  unzip(zipfile = zip_path, exdir = temp_dir)
  
  shape_data <- st_read(dsn = temp_dir, layer = paste0(uf, '_Municipios_2022'))
  
  unlink(temp_dir, recursive = TRUE)  
  
  return(shape_data)
}

uf <- c('PR', 'SC')

# Use map_df to unify the results into a single data frame
all_shape_data <- map_df(uf, ~read_zip_shp(.x))
st_write(all_shape_data, "prsc.shp")
