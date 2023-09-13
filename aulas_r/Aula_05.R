#----------------------------------------------------------
#                  GEOPROCESSAMENTO - BICT Mar
#----------------------------------------------------------
# Docente: Fabio Cop
#
# Aula 5: Dados matriciais do tipo raster
#         A biblioteca `stars`
#         https://r-spatial.github.io/stars/index.html
#----------------------------------------------------------
# Pacotes utilizados
library(tidyverse)
library(patchwork)
library(sf)
library(viridis)
library(stars) # para dados em raster

#------------------
# Script
# =======================================================
# 1. Dados matriciais no R
# =======================================================
# 1.1. Estrutura de uma matriz
m1 <- matrix(data = c(2,4,6,8,10,12), nrow = 3, ncol = 2, byrow = FALSE)
dim(m1)
m1

vetor <- sample(100, size = 30)
m <- matrix(data = vetor, nrow = 5)
m
dim(m)
m[1,]
m[,1]
m[c(1,3), c(4,5)]

# 1.2. Operações em matrizes
m + 1000 # Soma com uma constante
m * 2 # Multiplicação
m^2 # Potência
t(m)

#m + m1 # Matrizes de dimensões não compatíveis não podem ser somandas/subtraídas, etc

# 1.3. Visualizando uma matriz
m
image(m, col = gray.colors(9))
image(m, col = heat.colors(9))
image(m, col = terrain.colors(9))
cold_palette <- colorRampPalette(c("lightblue", "red"))
image(m, col = cold_palette(9))

# =======================================================
# 2. A BIBLIOTECA `stars` 
# =======================================================
# 2.1. Transformando uma matriz em um objeto da classe `stars`
m36 <- matrix(1:36, ncol = 6)
m36
class(m36)
ms <- st_as_stars(m36)
ms
class(ms)

par(mfrow = c(1,2))
image(m36, axes = TRUE, col = cold_palette(9))
image(ms, text_values = TRUE, axes = TRUE, col = cold_palette(9))

# 2.2. Atributos em um raster da classe `stars`
names(ms)
ms$A1
ms$A1[1,]
ms$A1[,1]
ms$A1[1:3,2:4]
class(ms$A1[1:3,2:4])

# 2.3. Dimensões em um raster da classe `stars`
st_dimensions(ms)
st_dimensions(ms)[[1]]
st_dimensions(ms)[['X1']]
st_dimensions(ms)['X1']
st_dimensions(ms)['X2']
st_dimensions(ms)$X2$from
st_dimensions(ms)$X2$to

# 2.4. Carregando um arquivo raster
#---------------------------------
# Modelo Digital de Terreno - Imagem Shuttle Radar Topography Mission (SRTM)
# Resolução espacial: 30 metros
# Representação digital do terreno a partir de dados coletados pela missão
#    "Shuttle Radar Topography Mission" (SRTM), NASA - fevereiro de 2000.
#---------------------------------
srtmDem <- read_stars('dados/dem_srtm_30m.tif')

# 2.4.1.Estrutura do arquivo
srtmDem

# 2.4.2. Alterando o nome do(s) atributo(s)
names(srtmDem)
srtmDem <- setNames(srtmDem, 'dem')
srtmDem

# 2.4.3. Acessando os valores do(s) atributos
srtmDem$dem %>% str()
dim(srtmDem$dem)
srtmDem$dem[1:10, 1:10]
srtmDem$dem[1:10, 1:5]

# 2.4.4. Acessando as dimensões
st_dimensions(srtmDem)
st_dimensions(srtmDem)['x']
st_dimensions(srtmDem)['y']
st_dimensions(srtmDem)$x$from
st_dimensions(srtmDem)$x$to
st_dimensions(srtmDem)$x$offset
st_dimensions(srtmDem)$x$delta
st_dimensions(srtmDem)$x$refsys

# 2.4.5. Plotando a imagem
plt_srtmDem <- ggplot() +
  geom_stars(data = srtmDem) +
  coord_equal() +
  scale_fill_viridis(option = "D")

plt_srtmDem

# Adiciona linhas de grid
add_grid_lines <- function(p) {
  p + geom_hline(yintercept = seq(-24.2, -23.65, 0.05),
           color = "white", 
           linewidth = 0.2) +
  geom_vline(xintercept = seq(-47.3, -46.15, 0.05),
             color = "white", 
             linewidth = 0.2) +
    scale_y_continuous(breaks = seq(-25, 20, by = 0.05)) +
    scale_x_continuous(breaks = seq(-50, 50, by = 0.05))
}

# Imagen com latitude e lingitude
add_grid_lines(plt_srtmDem)

# 2.4.6. Extraindo uma parte (subset) do raster
# Definindo os limites que serão extraídos
x_min <- -47.1
x_max <- -47.05
y_min <- -24.2
y_max <- -24.15

# Extensão do recorte (Área de interesse)
bbox_sf <- st_bbox(c(xmin = x_min, ymin = y_min, xmax = x_max, ymax = y_max)) %>%
  st_as_sfc()  %>% 
  st_set_crs(st_crs(srtmDem)) # Ajusta à mesma projeção do srtmDem

bbox_sf

# Vizualizando o trecho que será recortado
plt_srtmDem_box <- ggplot() +
  geom_stars(data = srtmDem) +
  geom_sf(data = bbox_sf, color = 'darkgreen', fill = 'red', alpha = 0.5) +
  scale_fill_viridis(option = "D")

plt_srtmDem_box

# Corta imagem dentro da area de interesse
srtmDem_rec <-  st_crop(srtmDem, bbox_sf)
srtmDem_rec
srtmDem  # Comparando com a imagem inteira

# Plota objeto recortado na área de interesse
plt_srtmDem_rec <- ggplot() +
  geom_stars(data = srtmDem_rec) +
  coord_equal() +
  scale_fill_viridis(option = "D")

plt_srtmDem_box | plt_srtmDem_rec

# 2.4.7. Alterando a resolução espacial  

# 1. Defina a resolução final em x e y e crie um grid com os limites do objeto 
#    original e resolução desejada
srtmDem
res_final <- 0.0005 # Em graus  Teste res_final = dyorig * 2
grid = st_as_stars(st_bbox(srtmDem_rec), dx = res_final, dy = res_final)
grid

srtmDem_modif = st_warp(srtmDem_rec, grid, method = "cubic", use_gdal=TRUE)
srtmDem_modif
srtmDem_rec
# ?st_warp # Veja o help para os métodos de interpolação

plt_srtmDem_modif <- ggplot() +
  geom_stars(data = srtmDem_modif) +
  coord_equal() +
  scale_fill_viridis(option = "D")

plt_srtmDem_rec | plt_srtmDem_modif

# 2. Repetindo o procedimento na imagem completa
dxorig <- st_dimensions(srtmDem_rec)$x$delta  # dimensão original em x
dxorig
dyorig <- st_dimensions(srtmDem_rec)$y$delta  # dimensão original em y
dyorig

fac = 40 # Diminuindo a resolução por um fator igual a fac
res_x <- dxorig * fac 
res_y <- dxorig * fac 

grid_fullImg = st_as_stars(st_bbox(srtmDem), dx = res_x, dy = res_y)
grid_fullImg

srtmDem_Full = st_warp(srtmDem, grid_fullImg, method = "near", use_gdal = TRUE)

plt_srtmDem_fullImg <- ggplot() +
  geom_stars(data = srtmDem_Full) +
  coord_equal() +
  scale_fill_viridis(option = "D")

plt_srtmDem | plt_srtmDem_fullImg

# 3. Inserindo o raster em um poligono da classe sf
sp_poly <- st_read('dados/SP_RJ/SP_RJ.shp') %>% 
  filter(SIGLA_UF == 'SP') %>% 
  st_transform(st_crs(srtmDem))

br <- c(1, 10, 100, 1000)
ggplot() +
  geom_stars(data = srtmDem_Full) +
  geom_sf(data = sp_poly, fill = NA, color = 'black') +
  scale_fill_gradient(low = "white", high = "darkgreen", 
                      trans = 'log', breaks = br) +
  labs(fill = 'Elevação (m)') +
  theme_bw()

# 4. Salvando a imagem em Geotiff
write_stars(srtmDem, 'dados/srtmDem_original.tiff')
write_stars(srtmDem_Full, 'dados/srtmDem_Full_resized.tiff')

