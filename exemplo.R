######################
# PACOTES UTILIZADOS #
######################
library(webdriver)
library(rvest)
library(tidyverse)

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
arqs.prof = ufs[1:2] %>% 
  lapply(function(x) cnes.prof.download(UF_sel=x,ses=ses)) %>% 
  unlist()

prof = arqs.prof %>%
  map_df(~read_csv2(file = .x,col_types = cols(.default = "c")))

####################
# ESTABELECIMENTOS #
####################
arqs.estab = ufs[1:2] %>% 
  lapply(function(x) cnes.estab.download(UF_sel=x,ses=ses)) %>% 
  unlist()

estab = arqs.estab %>%
  map_df(~read_csv2(file = .x,col_types = cols(.default = "c")))
