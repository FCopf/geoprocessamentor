#----------------------------------------------------------
#                  GEOPROCESSAMENTO - BICT Mar
#----------------------------------------------------------
# Docente: Fabio Cop
#
# Aula 2: Manipulação de atributos não espaciais em tabelas
#----------------------------------------------------------

# --------- Pacotes utilizados ---------
library(tidyverse)

# --------- Script ---------
# Lendo a base de dados
# Fonte: https://www.ibge.gov.br/estatisticas/sociais/populacao/22827-censo-demografico-2022.html
munibge <- read_csv('dados/municipios_ibge2022.csv', col_types = cols(uf_cod = 'c'))

# ------------- Descrevendo o data frame ------------------
dim(munibge) # Dimensões da tabela
glimpse(munibge) # Descrição dos atributos (colunas)

# Contando número de estados
munibge %>% 
  distinct(uf) %>% 
  count()

# Contando número de municipios pelo nome
munibge %>% 
  distinct(municipio) %>% 
  count() 

# Contando número de municipios pelo código
munibge %>% 
  select(municipio_cod) %>% 
  count()

# Verificando nomes repetidos
munibge %>% 
  count(municipio) %>% 
  arrange(desc(n))

# ------------- Filtrando linhas ------------------
acre <- munibge %>% 
  filter(uf == 'AC')

# ------------- Ordenando linhas ------------------
acre %>% arrange(populacao_2022)
acre %>% arrange(desc(populacao_2022))

# ------------- Sumarisando um data frame ------------------
acre %>% 
  summarise(populacao_total = sum(populacao_2022))

# Mais de uma estatística descritiva para a coluna
acre %>% 
  summarise(populacao_total = sum(populacao_2022),
            populacao_media = mean(populacao_2022))

# Mais de uma coluna
acre %>% 
  summarise(across(c(area_km2, populacao_2010, populacao_2022, domicilios_2022), ~sum(.)))

# Todas as colunas numericas
acre %>% 
  summarise(across(where(is.numeric), ~sum(.)))

# Todas as colunas com tamanhos populacionais
acre %>% 
  summarise(across(starts_with('populacao'), ~sum(.)))

# ------------- Sumarisando um data frame por grupos ------------------
estados <- munibge %>% 
  group_by(uf) %>% 
  summarise(across(where(is.numeric), ~sum(.)))

# ------------- Criando colunas ------------------
capitais <- munibge %>% 
  filter(capital == 'sim')

# Crescimento entre 2010 e 2022
capitais <- capitais %>% 
  mutate(crescimento = populacao_2022-populacao_2010) %>% 
  mutate(cresc_percentual = round((populacao_2022/populacao_2010 - 1) * 100, 2)) %>% 
  mutate(densidade_2022 = round(populacao_2022/area_km2,2)) %>% 
  arrange(desc(densidade_2022))

#---------------- Graficos ------------------------------------------
# Tamanho populacional em 2022
ggplot(capitais, aes(y = populacao_2022/1000, x = reorder(municipio, -populacao_2022))) +
  geom_col(fill = 'darkblue') +
  labs(y = "Habitantes (x 1,000)", x = '') +
  scale_y_continuous(breaks = seq(0, 12000, by = 1000),
                     labels = scales::comma) +
  theme_classic(base_size = 15) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Crescimento comparado a 2010
ggplot(capitais, aes(y = cresc_percentual, x = reorder(municipio, -cresc_percentual))) +
  geom_col(fill = 'darkblue') +
  labs(y = "Crescimento em 2022 (% de 2010)", x = '') +
  scale_y_continuous(breaks = seq(-10, 50, by = 5),
                     labels = scales::comma) +
  theme_classic(base_size = 15) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Densidade populacional
ggplot(capitais, aes(y = densidade_2022, x = reorder(municipio, -densidade_2022))) +
  geom_col(fill = 'darkblue') +
  labs(y = expression("Densidade populacional (Hab/km"^"2"*")"), x = '') +
  scale_y_continuous(breaks = seq(0, 10000, by = 500),
                     labels = scales::comma) +
  theme_classic(base_size = 15) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
  