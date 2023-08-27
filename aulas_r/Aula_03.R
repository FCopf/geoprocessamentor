#----------------------------------------------------------
#                  GEOPROCESSAMENTO - BICT Mar
#----------------------------------------------------------
# Docente: Fabio Cop
#
# Aula 3: Manipulação de atributos espaciais em tabelas
#----------------------------------------------------------

# Pacotes utilizados
library(tidyverse)
library(sf)
library(patchwork)
library(scales)

# Script
# Lendo a base de dados
# Fontes: 
# - https://www.ibge.gov.br/estatisticas/sociais/populacao/22827-censo-demografico-2022.html
# - https://www.ibge.gov.br/geociencias/organizacao-do-territorio/malhas-territoriais/15774-malhas.html

munibge <- read_csv('dados/municipios_ibge2022.csv', col_types = cols(uf_cod = 'c'))
sprj_poly <- st_read('dados/SP_RJ/SP_RJ.shp')

# Estrutura da tabela de atributos
glimpse(sprj_poly)

# Plota poligonos com limites de municípios
ggplot(sprj_poly) +
  geom_sf()

# Plota poligonos com limites de municípios identificando os estados
ggplot(sprj_poly, aes(color = SIGLA_UF)) +
  geom_sf()

# Formata o mapa
# Define cores em função dos estados
uf_palette <- c('RJ' = '#1f77b4',
                'SP' = '#2ca02c')

ggplot(sprj_poly, aes(fill = SIGLA_UF)) +
  geom_sf() +
  labs(fill = '') +
  scale_fill_manual(values = uf_palette) +
  theme_bw() +
  theme(legend.position = "bottom")

# ------ Unificando o data frame por estado ------ 
uf_poly <- sprj_poly %>%
  group_by(SIGLA_UF) %>%
  summarize() %>%
  st_union(by_feature = TRUE)

uf_poly

# Mapa dos estados
ggplot(uf_poly, aes(fill = SIGLA_UF)) +
  geom_sf() +
  labs(fill = '') +
  scale_fill_manual(values = uf_palette) +
  theme_bw() +
  theme(legend.position = "bottom")

# ------ Unificando sprj_poly com dados municipais de `munibge` ------

# Cria coluna com código completo de município
munibge2 <- munibge %>% 
  unite(mun_cod_c, uf_cod, municipio_cod, sep = '') %>% 
  select(-area_km2)

# Unifica com dados do IBGE cm função `left_join`
sprj_poly_e <- sprj_poly %>% 
  left_join(munibge2, by = join_by(CD_MUN == mun_cod_c,
                                   NM_MUN == municipio,
                                   SIGLA_UF == uf)) %>% 
  mutate(densidade_2022 = round(populacao_2022/AREA_KM2,2),
         crescimento = populacao_2022-populacao_2010,
         cresc_percentual = round((populacao_2022/populacao_2010 - 1) * 100, 2),
         .before = geometry)

# Verfica novo data.frame
glimpse(sprj_poly_e)

# Mapa final
# Gráfico sprj_poly_e + uf_poly
br <- c(1, 100, 1000, 5000, 10000)
plt_se <- ggplot() +
  geom_sf(data = sprj_poly_e, aes(fill = densidade_2022), color = 'grey') +
  geom_sf(data = uf_poly, aes(color = SIGLA_UF), fill = NA, linewidth = 0.25) +
  labs(title = 'Densidade populacional',
       fill = expression('Hab/Km'^2)) +
  scale_color_manual(values = uf_palette) +
  theme_bw() +
  guides(color = 'none') +
  scale_fill_gradient(low = "white", high = "brown", trans = 'sqrt',
                      breaks = br,
                      labels = scales::comma(br)) +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5))


plt_se

ggsave(filename = 'Densidade_sprj.png', plot = plt_se, width = 8, height = 6)
