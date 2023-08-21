#----------------------------------------------------------
#                  GEOPROCESSAMENTO - BICT Mar
#----------------------------------------------------------
# Docente: Fabio Cop
#
# Aula 1: Introdução e cronograma do curso
#----------------------------------------------------------

# --------- Pacotes utilizados ---------
library(sf)
library(spData)
library(tidyverse)

# --------- Script ---------
# Carregando os dados `world`.
data(world)

# Verificando a tabela de atributos das 10 primeiras linhas.
world  %>% 
  head(n = 10)

# Plotando o mapa de continentes.
ggplot(world) +
  geom_sf(aes(fill = continent))

# Plotando o mapa de tamanhos populacionais.

ggplot(world) +
  geom_sf(aes(fill = pop))

# Plotando o mapa da América do Sul.
asul <- world %>%  
  filter(continent == 'South America')

asul

ggplot(asul) +
  geom_sf(aes(fill = name_long)) +
  labs(fill = 'País') +
  theme_void()
