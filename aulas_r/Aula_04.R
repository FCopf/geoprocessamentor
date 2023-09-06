#----------------------------------------------------------
#                  GEOPROCESSAMENTO - BICT Mar
#----------------------------------------------------------
# Docente: Fabio Cop
#
# Aula 4: Dados vetoriais, manipulações e transformações
#----------------------------------------------------------

# Pacotes utilizados
library(tidyverse)
library(sf)
library(geobr)
library(patchwork)

# Script
# --------- Munícípios IBGE 2022 ---------
munibge <- read_csv('dados/municipios_ibge2022.csv', col_types = cols(uf_cod = 'c'))

# --------- Bases de dados disponpiveis em `geobr` ---------
list_geobr() %>% view()

# ------ Carregando cases de dados de `geobr` -----
# Brasil
br <- read_country(year = 2010, simplified = FALSE)
br

# Estados
uf <- read_state(year = 2010, simplified = FALSE)
uf

# Biomas
biom <- read_biomes(year = 2019, simplified = FALSE)
biom

# Mapa Brasil
plt_br <- ggplot() +
  geom_sf(data = br, fill = 'white')

# Mapa Estados
plt_uf <- ggplot() +
  geom_sf(data = uf, aes(color = name_region), fill = 'white') +
  labs(fill = 'Região')

# Mapa Biomas
plt_bm <- ggplot() +
  geom_sf(data = biom, aes(fill = name_biome)) +
  labs(fill = 'Bioma')

plt_br | plt_uf | plt_bm

# Combinando os mapas
ggplot() +
  geom_sf(data = br, fill = 'white') +
  geom_sf(data = uf, aes(color = name_region), fill = NA, linewidth = 0.5, linetype = 2) +
  geom_sf(data = biom, aes(fill = name_biome), alpha = 0.2) +
  labs(Fill = '') +
  theme_bw() +
  guides(color = 'none')

# ------------- Transformações ------------------
# 1. Centróide
# -------------
uf_centro <- st_centroid(st_geometry(uf))
br_centro <- st_centroid(st_geometry(br))

ggplot() +
  geom_sf(data = br, fill = 'white') +
  geom_sf(data = uf, fill = NA, linewidth = 0.5, linetype = 2) +
  geom_sf(data = br_centro, color = 'blue', size  = 3) +
  geom_sf(data = uf_centro, color = 'red', size = 0.5)

# 2. Reposicionamento
# -------------
uf_repos <- st_geometry(uf) + c(0,10)
st_crs(uf_repos) <- 4326

ggplot() +
  geom_sf(data = br, fill = 'white') +
  geom_sf(data = uf_repos, fill = NA, linewidth = 0.5, linetype = 2)

# 3. Rescalonamento
# -------------
# Centralizando nos estados
uf_reduz <- (st_geometry(uf) - st_geometry(uf_centro)) * 0.50 + st_geometry(uf_centro)
st_crs(uf_reduz) <- 4326

ggplot() +
  geom_sf(data = br, fill = 'white') +
  geom_sf(data = uf_centro, color = 'red', size = 0.5) +
  geom_sf(data = uf_reduz, fill = NA, linewidth = 0.5, linetype = 2)

# Centralizando nos Brasil
uf_reduz_br <- (st_geometry(uf) - st_geometry(br_centro)) * 0.55 + st_geometry(br_centro)
st_crs(uf_reduz_br) <- 4326

ggplot() +
  geom_sf(data = br, fill = 'white') +
  geom_sf(data = br_centro, color = 'blue', size = 2) +
  geom_sf(data = uf_reduz_br, fill = NA, linewidth = 0.5, linetype = 2)

# Uma aplicação visual: Mapa da Densidade Populacional
uf_pop <- munibge %>% 
  group_by(uf) %>% 
  summarise(populacao_total = sum(populacao_2022)) %>% 
  mutate(pop_rel = populacao_total/max(populacao_total)) 
  
uf_aum <- uf %>% left_join(uf_pop, by = join_by(abbrev_state == uf))  

uf_prop <- (st_geometry(uf_aum) - st_geometry(uf_centro)) * (uf_aum$pop_rel) + st_geometry(uf_centro)
st_crs(uf_prop) <- 4326

ggplot() +
  geom_sf(data = br, fill = 'white') +
  geom_sf(data = uf_prop, fill = 'lightblue', color = NA, linetype = 2) +
  geom_sf(data = uf, fill = NA) +
  theme_void()

# 4. Rotação
# -------------
rot <- function(a) matrix(c(cos(a), sin(a), -sin(a), cos(a)), 2, 2)

## Rotacionando ao redor do centro do pais
theta = pi/4  #ângulo em radianos
uf_rot <- (st_geometry(uf) - st_geometry(br_centro)) * rot(theta) + st_geometry(br_centro)
st_crs(uf_rot) <- 4326

ggplot() +
  geom_sf(data = br, fill = NA) +
  geom_sf(data = br_centro, color = 'blue', size = 2) +
  geom_sf(data = uf_rot, fill = 'white', alpha = 0.5, linewidth = 0.5, linetype = 2)

# -------------- Operações de União e intersecção de poligonos -------------
# Lendo o bioma Mata Atlântica
ma <- biom %>% 
  filter(name_biome == 'Mata Atlântica')
ggplot(ma) + geom_sf()

# Lendo e Estado de Minas Grais
mg <- read_state(code_state = 'MG')
ggplot(mg) + geom_sf()

mg_ma_plt <- ggplot() + 
  geom_sf(data = br, fill = 'white') +
  geom_sf(data = ma, fill = 'green', alpha = 0.2) +
  geom_sf(data = mg, fill = 'red', alpha = 0.2) +
  theme_bw()
mg_ma_plt

# União
uniao_mamg <- st_union(ma, mg)

# Intersecção
intersec_mamg <- st_intersection(ma, mg)

# Diferença
diff_mamg <- st_difference(ma, mg)
diff_mgma <- st_difference(mg, ma)

# Diferença simétrica
symdiff_mamg <- st_sym_difference(ma, mg)

# Os gráficos
uniao_plt <- ggplot() + 
  geom_sf(data = br, fill = 'white') +
  geom_sf(data = uniao_mamg, fill = 'orange', alpha = 0.2) +
  labs(title = expression(paste('MA',union(), 'MG')),
       subtitle = 'União') +
  theme_bw()

interse_plt <- ggplot() + 
  geom_sf(data = br, fill = 'white') +
  geom_sf(data = intersec_mamg, fill = 'Blue', alpha = 0.2) +
  labs(title = expression(paste('MA',intersect(), 'MG')),
       subtitle = 'Intersecção') +
  theme_bw()

diff1_plt <- ggplot() + 
  geom_sf(data = br, fill = 'white') +
  geom_sf(data = diff_mamg, fill = 'green', alpha = 0.2) +
  labs(title = expression('MA - MG'),
       subtitle = 'Diferença') +
  theme_bw()

diff2_plt <- ggplot() + 
  geom_sf(data = br, fill = 'white') +
  geom_sf(data = diff_mgma, fill = 'red', alpha = 0.2) +
  labs(title = expression('MG - MA'),
       subtitle = 'Diferença') +
  theme_bw()

symdiff_plt <- ggplot() + 
  geom_sf(data = br, fill = 'white') +
  geom_sf(data = symdiff_mamg , fill = 'yellow', alpha = 0.2) +
  labs(title = expression(paste('(MA',union(), 'MG) - ', '(MA',intersect(), 'MG)')),
       subtitle = 'Diferença simétrica') +
  theme_bw()

(mg_ma_plt / uniao_plt) | (interse_plt / symdiff_plt) | (diff1_plt / diff2_plt)

#--------------------
# Aplicação: encontrando os Estados que têm alguma intersecção com o bioma Mata Atlântica
uf_ma <- uf %>% 
  st_intersection(ma) %>% 
  mutate(geom = case_when(st_geometry_type(geom) == "POLYGON" ~ st_cast(geom, "MULTIPOLYGON"),
                          .default = geom))
ggplot() +
  geom_sf(data = br, fill = 'white') +
  geom_sf(data = uf_ma, fill = 'lightgreen', color = 'black')
  
# Percebemos que o comando `st_intersection` criou poligonos somente com a parte dos estados que intercepam o bioma.
# Vamos usar o comando join para selecionar TODO o polygono dos estados que interceptam o bioma
uf_ma_null <- st_drop_geometry(uf_ma) %>% 
  select(abbrev_state)

uf_ma_completo <- uf %>% 
  inner_join(uf_ma_null, by = 'abbrev_state')

# Verificando os mapas isolados
uf_interc_plt <- ggplot() +
  geom_sf(data = br, fill = 'white') +
  geom_sf(data = uf_ma_completo)

ma_interc_plt <- ggplot() +
  geom_sf(data = br, fill = 'white') +
  geom_sf(data = uf_ma, fill = 'lightgreen', color = 'black')

# Verificando o mapa completo
ufma_interc_plt <- ggplot() +
  geom_sf(data = br, fill = 'white') +
  geom_sf(data = uf_ma_completo) +
  geom_sf(data = uf_ma, fill = 'lightgreen', color = 'black')

uf_interc_plt + ma_interc_plt + ufma_interc_plt

# Percentual dos estados no bioma Mata Atlântica
uf_ma_a <- uf_ma %>% 
  mutate(area = st_area(uf_ma))
uf_a <- uf %>% 
  mutate(area = st_area(uf)) %>% 
  left_join(uf_ma_a %>% 
              st_drop_geometry() %>% 
              select(abbrev_state, area), 
              by = 'abbrev_state') %>% 
  mutate(area_rel = as.numeric(area.y/area.x))


perc_ma_plt <- ggplot(uf_a) +
  geom_sf(aes(fill = area_rel)) +
  scale_fill_gradient(low = "lightgreen", high = "darkgreen",
                      breaks = seq(0, 1, by = .2)) +
  labs(title = 'Inserção no Bioma Mata Atlântica', fill = 'Inserção (%)') +
  theme(plot.title = element_text(hjust = 0.5))

perc_ma_plt

ufma_interc_plt | perc_ma_plt
