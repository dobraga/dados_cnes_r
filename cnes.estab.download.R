cnes.estab.download = function(UF_sel,comp_sel="Atual",ses=NULL,dir = tempdir()){
  
  if(is.null(ses)){stop("FALTA CONEXÃO")}
  
  UF_sel = stringr::str_to_upper(UF_sel)
  
  ses$go("http://cnes.datasus.gov.br/pages/estabelecimentos/extracao.jsp")
  
  ufs = "Selecione"
  
  while(length(ufs)==1){
    ufs = ses$getSource() %>% 
      read_html() %>% 
      html_nodes(xpath = '/html/body/div[2]/main/div/div[2]/div/form/div[1]/select[1]/option') %>% 
      html_text()
  }
  
  if(! UF_sel %in% ufs[-1]){
    stop("ERRO AO SELECIONAR UF")
  }
  
  if(comp_sel != "Atual"){
    comp = ses$getSource() %>% 
      read_html() %>% 
      html_nodes(xpath = '/html/body/div[2]/main/div/div[2]/div/form/div[2]/div[1]/div/select/option') %>% 
      html_text() 
    
    if(! comp_sel %in% comp){
      stop("ERRO AO SELECIONAR COMPETÊNCIA")
    }
  }
  
  pos.uf = match(UF_sel,ufs)
  pos.comp = match(comp_sel,comp)
  
  comp_sel.num = comp_sel %>% 
    str_extract_all("[0-9]") %>% 
    unlist() %>% paste(collapse="") %>% 
    as.numeric()
  
  pesq.el = ses$findElements(xpath = '/html/body/div[2]/main/div/div[2]/div/form/div[1]/select[1]/option')
  pesq.el[[pos.uf]]$click()
  
  comp.el = ses$findElements(xpath = '/html/body/div[2]/main/div/div[2]/div/form/div[2]/div[1]/div/select/option')
  comp.el[[pos.comp]]$click()
  
  download = ses$findElement(xpath = '/html/body/div[2]/main/div/div[2]/div/form/div[2]/div[2]/div/button')
  download$click()
  
  link = ""
  
  while(link==""){
    link = ses$getSource() %>% 
      read_html() %>% 
      html_node(xpath='//*[@id="myModal"]/div/div/div[3]/a') %>% 
      html_attr("href")
  }
  
  dest = paste(dir,paste0(comp_sel.num,"_estab_",UF_sel,".zip"),sep = "\\")
  
  download.file(link,
                destfile = dest,
                mode = "wb",
                quiet = T)
  
  a = unzip(dest,exdir = dir)
  
  b = paste(dir,paste0(comp_sel.num,"_estab_",UF_sel,".csv"),sep = "\\")
  
  invisible(file.rename(a,b))
  
  return(b)
}
