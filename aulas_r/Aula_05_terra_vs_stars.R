#----------------------------------------------------------
#                  GEOPROCESSAMENTO - BICT Mar
#----------------------------------------------------------
# Docente: Fabio Cop
#
# Aula 5: Dados matriciais do tipo raster
#         EXTRA - Comparando as bibliotecas `terra` e `stars`
#----------------------------------------------------------

# Pacotes utilizados
library(tidyverse)
library(patchwork)
library(sf)
library(viridis)
library(terra) # para dados em raster
library(stars) # para dados em raster

#------------------
# Script
# ================ 1. Dados matriciais no R====== ========
m1 <- matrix(data = c(2,4,6,8,10,12), nrow = 3, ncol = 2, byrow = FALSE)
m1

vetor <- sample(100, size = 30)
m <- matrix(data = vetor, nrow = 5)
m
m[1,]
m[,1]
m[c(1,3), c(4,5)]

# Visualizando uma matriz
image(m, col = gray.colors(9))
image(m, col = heat.colors(9))
image(m, col = terrain.colors(9))
cold_palette <- colorRampPalette(c("lightblue", "red"))
image(m, col = cold_palette(9))

# ================ 2. Dados matriciais em raster ========
# =======================================================
# 2.1. A BIBLIOTECA `terra` 
# =======================================================
# Convertendo uma matriz em objeto raster
# Criando uma matriz 4 x 4
m36 <- matrix(1:36, ncol = 6)
m36
# Converte em raster
r36 <- terra::rast(m36)
r36

# Vizualisando a matriz no ggplot
# Converte no formato data frame para usar no ggplot
r36_df <- as.data.frame(r36, xy = TRUE)

r36_plt <- ggplot(data = r36_df, aes(x = x, y = y, fill = lyr.1, label = lyr.1)) +
  geom_raster() +
  coord_equal() +
  geom_text(size = 10) +
  scale_fill_viridis()

r36_plt

# -------------------- Alterando a resolução espacial  ----------
# Diminuindo a resolução do raster
r36 # resolution  : 1, 1  (x, y)
r9 <- terra::aggregate(r36, fact = 2, fun = 'mean')
r9

# Converte em data frame
r9_df <- as.data.frame(r9, xy = TRUE)

r9_plt <- ggplot(r9_df, aes(x = x, y = y, fill = lyr.1, label = lyr.1)) +
  geom_raster() +
  coord_equal() +
  geom_text(size = 10) +
  scale_fill_viridis()
r9_plt

# Comparando lado-a-lado
r36_plt | r9_plt

# Testando outras transformações
rlower <- terra::aggregate(r36, fact = 2, fun = 'min')
rlower_df <- as.data.frame(rlower, xy = TRUE)

rlower_plt <- ggplot(rlower_df, aes(x = x, y = y, fill = lyr.1, label = lyr.1)) +
  geom_raster() +
  coord_equal() +
  geom_text(size = 10) +
  scale_fill_viridis()

r36_plt  | rlower_plt

# Aumentando a resolução - Desagregando
rupper <- terra::disagg(rlower, fact = 4, method = 'near') # method = 'bilinear'

rupper_df <- as.data.frame(rupper, xy = TRUE)

rupper_plt <- ggplot(rupper_df, aes(x = x, y = y, fill = lyr.1, label = lyr.1)) +
  geom_raster() +
  coord_equal() +
  geom_text(size = 3) +
  scale_fill_viridis()

rupper_plt | rlower_plt

# --------------------------------------------------------
# -------------- Um exemplo de imagem raster -------------
# --------------------------------------------------------
# Modelo Digital de Terreno - Imagem Shuttle Radar Topography Mission (SRTM)
# Resolução espacial: 30 metros
# Representação digital do terreno a partir de dados coletados pela missão
#    Shuttle Radar Topography Mission (SRTM), NASA - fevereiro de 2000.
lt <- rast('dados/dem_srtm_30m.tif')
lt

# Convertendo em data frame
lt_df <- as.data.frame(lt, xy = TRUE)
dim(lt_df)
head(lt_df)
tail(lt_df)

plt_lt <- ggplot(lt_df) +
  geom_raster(aes(x = x, y = y, fill = elevation)) +
  geom_hline(yintercept = seq(-24.2, -23.65, 0.05),
             color = "white", 
             linewidth = 0.2) +
  geom_vline(xintercept = seq(-47.3, -46.15, 0.05),
             color = "white", 
             linewidth = 0.2) +
  coord_equal() +
  scale_fill_viridis(option = "C")

plt_lt

# Extraindo uma parte (subset) do raster
# Definindo os limites que serão extraídos
x_min <- -47.1
x_max <- -47.05
y_min <- -24.2
y_max <- -24.15

# Vizualizando o trecho que será recortado
plt_lt1 <- ggplot(lt_df) +
  geom_raster(aes(x = x, y = y, fill = elevation)) +
  geom_hline(yintercept = c(y_min, y_max),
             color = "white", 
             linewidth = 0.2) +
  geom_vline(xintercept = c(x_min, x_max),
             color = "white", 
             linewidth = 0.2) +
  coord_equal() +
  scale_fill_viridis(option = "C")

plt_lt1

# Recorta a imagem
bbox <- ext(x_min, x_max, y_min, y_max)
lt_sub <- crop(lt, bbox)
lt_sub
lt

lt_sub_df <- as.data.frame(lt_sub, xy = TRUE)

plt_lt_sub <- ggplot(lt_sub_df) +
  geom_raster(aes(x = x, y = y, fill = elevation)) +
  scale_fill_viridis(option = 'C') +
  coord_equal()

plt_lt_sub

plt_lt1 + plt_lt_sub

# Colocando no mesmo gradiente de cores
gradiente_cores <- scale_fill_gradient(low = 'blue', high = 'orange', limits = c(0, 1000))
plt_lt1 + gradiente_cores | plt_lt_sub + gradiente_cores

# ---------------------------------------------------------------
# -------------------- Alterando a resolução espacial  ----------
# ---------------------------------------------------------------
# Diminuindo a resolução do raster
plt_lt_sub
lt_sub # resolution  : 0.0002694946, 0.0002694946  (x, y) em graus

f = 2
lt_sub_lower <- terra::aggregate(lt_sub, fact = f, fun = 'mean')
lt_sub_lower

lt_sub_lower_df <- as.data.frame(lt_sub_lower, xy = TRUE)

plt_lt_sub_lower <- ggplot(lt_sub_lower_df) +
  geom_raster(aes(x = x, y = y, fill = elevation)) +
  scale_fill_viridis(option = 'C') +
  coord_equal()

plt_lt_sub + labs(title = 'Resolução ogirinal') |  
  plt_lt_sub_lower + labs(title = paste('Resolução reduzida em fator = ', f, sep = '')) 

#---------------------------------------------------------------
#------------- Um função para reduzir a resolução --------------
#-------------------- e plotar a imagem  -----------------------
loweringRes <- function(rasterIn, fatorRed, func = 'mean') {
  rasterLower <- terra::aggregate(rasterIn, fact = fatorRed, fun = func)
  rasterLower_df <- as.data.frame(rasterLower, xy = TRUE)
  
  pltrasterLower_df <- ggplot(rasterLower_df) +
    geom_raster(aes(x = x, y = y, fill = elevation)) +
    scale_fill_viridis(option = 'C') +
    coord_equal() +
    labs(title = paste('Resolução reduzida em fator = ', fatorRed, sep = ''))
  return(pltrasterLower_df)
}
#---------------------------------------------------------------
#---------------------------------------------------------------
# Usando a função
loweringRes(lt_sub, fatorRed = 4, func = 'min')

(loweringRes(lt_sub, fatorRed = 1) | loweringRes(lt_sub, fatorRed = 2)) /
  (loweringRes(lt_sub, fatorRed = 4) | loweringRes(lt_sub, fatorRed = 8))

#---------------------------------------------------------------
# Aplicando a função na imagem completa
#---------------------------------------------------------------
ltF1 <- loweringRes(lt, fatorRed = 1)
ltF4 <- loweringRes(lt, fatorRed = 4)
ltF20 <- loweringRes(lt, fatorRed = 20)
ltF40 <- loweringRes(lt, fatorRed = 40)

(ltF1 | ltF4) /
  (ltF20 | ltF40)

# =======================================================
# 2.2. A BIBLIOTECA `stars` 
# =======================================================
# Transformando uma matiz em um objeto da classe `stars`
m36 <- matrix(1:36, ncol = 6)
ms <- st_as_stars(m36)
ms
image(ms, text_values = TRUE, axes = TRUE, col = cold_palette(9))

# --------------------------------------------------------
# -------------- Um exemplo de imagem raster -------------
# --------------------------------------------------------
# Modelo Digital de Terreno - Imagem Shuttle Radar Topography Mission (SRTM)
# Resolução espacial: 30 metros
# Representação digital do terreno a partir de dados coletados pela missão
#    Shuttle Radar Topography Mission (SRTM), NASA - fevereiro de 2000.
lts <- read_stars('dados/dem_srtm_30m.tif')

# Estrutura do arquivo
lts

# Alterando o nome do(s) atributo(s)
lts <- setNames(lts, 'dem')
lts

# Acessando os valores do(s) atributos
lts$dem %>% str()
lts$dem[1:10, 1:10]
lts$dem[1:10, 1:5]

# Acessando as dimensões
st_dimensions(lts)
st_dimensions(lts)['x']
st_dimensions(lts)['y']
st_dimensions(lts)$x$from
st_dimensions(lts)$x$to
st_dimensions(lts)$x$offset
st_dimensions(lts)$x$delta
st_dimensions(lts)$x$refsys

# Plotando a imagem
plt_lts <- ggplot() +
  geom_stars(data = lts) +
  geom_hline(yintercept = seq(-24.2, -23.65, 0.05),
           color = "white", 
           linewidth = 0.2) +
  geom_vline(xintercept = seq(-47.3, -46.15, 0.05),
             color = "white", 
             linewidth = 0.2) +
  coord_equal() +
  scale_fill_viridis(option = "C")

plt_lts + labs(title = 'Biblioteca `stars`') | plt_lt + labs(title = 'Biblioteca `terra`')
  
# Extraindo uma parte (subset) do raster
# Definindo os limites que serão extraídos
x_min <- -47.1
x_max <- -47.05
y_min <- -24.2
y_max <- -24.15

# Extensão do recorte (área de interesse)
bboxs <- st_bbox(c(xmin = x_min, ymin = y_min, xmax = x_max, ymax = y_max)) %>% 
  st_as_sfc()  %>% 
  st_set_crs(4326)

# Vizualizando o trecho que será recortado
plt_lts1 <- ggplot() +
  geom_stars(data = lts) +
  geom_sf(data = bboxs, color = 'red', fill = 'green', alpha = 0.5) +
  scale_fill_viridis(option = "C")

plt_lts1

# Corta imagem dentro da area de interesse
lts_sub <-  st_crop(lts, bboxs)
lts_sub

# Plota objeto subset com a área de interesse
plt_lts_sub <- ggplot() +
  geom_stars(data = lts_sub) +
  coord_equal() +
  scale_fill_viridis(option = "C")

plt_lts1 | plt_lts_sub

(plt_lt1 + labs(title = 'Biblioteca `terra`')  | plt_lt_sub  + labs(title = 'Biblioteca `terra`')) /
  (plt_lts1  + labs(title = 'Biblioteca `stars`') | plt_lts_sub + labs(title = 'Biblioteca `stars`'))

# ---------------------------------------------------------------
# -------------------- Alterando a resolução espacial  ----------
# ---------------------------------------------------------------
# Alterando a resolução da imagem de um objeto `stars`

# 1. Formar um grid com os limites do objeto original e resolução desejada em dx e dy
resolucao_graus <- 0.001
grid = st_as_stars(st_bbox(lts_sub), dx = resolucao_graus, dy = resolucao_graus)
grid

lts_grid = st_warp(lts_sub, grid, method = "near", use_gdal = TRUE)

# ?st_warp # Veja o help para os métodos de interpolação

plt_lts_grid <- ggplot() +
  geom_stars(data = lts_grid) +
  coord_equal() +
  scale_fill_viridis(option = "C")

plt_lts_sub | plt_lts_grid

# Repetindo o procedimento na imagem completa
f = 40
res_x <- st_dimensions(lts)$x$delta * f # reduzindo a resolução por um fator f
res_y <- st_dimensions(lts)$y$delta * f # reduzindo a resolução por um fator f

grid_full = st_as_stars(st_bbox(lts), dx = res_x, dy = res_y)
grid_full

lts_grid_full = st_warp(lts, grid_full, method = "near", use_gdal = TRUE)

plt_lts_grid_full <- ggplot() +
  geom_stars(data = lts_grid_full) +
  coord_equal() +
  scale_fill_viridis(option = "C")

plt_lts1 | plt_lts_grid_full
