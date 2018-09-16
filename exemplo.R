######################
# PACOTES UTILIZADOS #
######################
library(webdriver)
library(rvest)
library(tidyverse)
library(leaflet)

pjs <- run_phantomjs()
ses <- Session$new(port = pjs$port)

ufs = c('ACRE','ALAGOAS','AMAPA','AMAZONAS','BAHIA','CEARA','DISTRITO FEDERAL',
        'ESPIRITO SANTO','GOIAS','MARANHAO','MATO GROSSO','MATO GROSSO DO SUL',
        'MINAS GERAIS','PARA','PARAIBA','PARANA','PERNAMBUCO','PIAUI','RIO DE JANEIRO',
        'RIO GRANDE DO NORTE','RIO GRANDE DO SUL','RONDONIA','RORAIMA','SANTA CATARINA',
        'SAO PAULO','SERGIPE','TOCANTINS')

#################
# PROFISSIONAIS #
#################
arqs.prof = ufs[1] %>% 
  lapply(function(x) cnes.prof.download(UF_sel=x,ses=ses)) %>% 
  unlist()

prof = arqs.prof %>%
  map_df(~read_csv2(file = .x,col_types = cols(.default = "c")))

####################
# ESTABELECIMENTOS #
####################
arqs.estab = ufs[1] %>% 
  lapply(function(x) cnes.estab.download(UF_sel=x,ses=ses)) %>% 
  unlist()

estab = arqs.estab %>%
  map_df(~read_csv2(file = .x,col_types = cols(.default = "c"))) %>% 
  mutate(LATITUDE = as.numeric(LATITUDE),
         LONGITUDE = as.numeric(LONGITUDE))

##################################
# REMOVENDO ARQUIVOS TEMPORÁRIOS #
##################################
ses$delete()
pjs$process$kill()

file.remove(dir(tempdir(),full.names = T))


####################
# EXEMPLOS LEAFLET #
####################

estab.naomit = na.omit(estab %>% select(CNES,`NOME FANTASIA`,LATITUDE,LONGITUDE))

# Distribuição de estabelecimentos de saude
leaflet() %>% 
  addTiles('http://mt.google.com/vt/lyrs=m&x={x}&y={y}&z={z}') %>% 
  setView(lat = mean(estab$LATITUDE,na.rm=T),
          lng = mean(estab$LONGITUDE,na.rm=T),
          zoom = 7) %>% 
  addAwesomeMarkers(data = estab.naomit,
                    lat = ~LATITUDE,
                    lng = ~LONGITUDE,
                    popup = paste("<p>CNES:",estab.naomit$CNES,"<br />",
                                  "Nome fantasia:",estab.naomit$`NOME FANTASIA`,"</p>"),
                    clusterOptions = markerClusterOptions()
                    )

# Estabelecimentos com mais de um funcionário

qtd_prof = prof %>% 
  group_by(CNES) %>% 
  summarise(n=n())

skimr::skim(qtd_prof) 

sel.cnes = qtd_prof %>% 
  filter(n>1)

maiores.cnes = estab.naomit %>% 
  inner_join(sel.cnes,by="CNES")

leaflet() %>% 
  addTiles('http://mt.google.com/vt/lyrs=m&x={x}&y={y}&z={z}') %>% 
  setView(lat = mean(estab$LATITUDE,na.rm=T),
          lng = mean(estab$LONGITUDE,na.rm=T),
          zoom = 7) %>% 
  addCircles(data = maiores.cnes,
             lat = ~LATITUDE,
             lng = ~LONGITUDE,
             radius = ~n, 
             stroke = F,
             popup = paste("<p>CNES:",maiores.cnes$CNES,"<br />",
                           "Nome fantasia:",maiores.cnes$`NOME FANTASIA`,"<br />",
                           maiores.cnes$n,"funcionários","</p>"))

