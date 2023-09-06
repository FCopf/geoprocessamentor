#----------------------------------------------------------
#                  GEOPROCESSAMENTO - BICT Mar
#----------------------------------------------------------
# Docente: Fabio Cop
#
# Aula 7: Projeções
#----------------------------------------------------------

# Pacotes utilizados
library(sf)
library(spData)
library(tidyverse)
library(gapminder)

# Script
# --------- Script ---------
# Carregando os dados `world` do pacote `spData`.
data(world)
# Carregando os dados `gapminder`.
# Fontes: 
# - https://www.gapminder.org/
# - https://simplemaps.com/data/world-cities
gapminder <- read_csv('dados/gapminder_formatado.csv')
wdcities <- read_csv('dados/worldcities.csv')

# -------- Estrutura do objeto `word` ------------
glimpse(world)
proj <- st_crs(world)

# -------- Estrutura do objeto `gapminder` ------------
glimpse(gapminder)

# -------- Estrutura do objeto `wdcities` ------------
glimpse(wdcities)

# Transformando `wdcities` em um objeto espacial
wdcities_sf <- st_as_sf(wdcities, coords = c('lng', 'lat')) %>% 
  st_set_crs(proj)

glimpse(wdcities_sf)
capitais <- wdcities_sf %>% 
  filter(capital == 'primary')

# ----------- Representando paises e capitais --------
ggplot() +
  geom_sf(data = world, aes(fill = continent)) +
  geom_sf(data = capitais, size = sqrt(capitais$population)*0.001) +
  labs(fill = '')

ggplot() +
  geom_sf(data = world, aes(fill = lifeExp)) +
  scale_fill_gradient(low = "red", high = "green", breaks = seq(50, 100, by = 5)) +
  labs(title = 'Expectativa de vida (anos)', fill = '') +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5))
