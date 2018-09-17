library(httr)

url <- "http://www.cccc.cat/base-de-dades"
r <- GET(url)
status_code(r)
headers(r)
warn_for_status(r)

# contents
content(r)
content(r, 'text')
content(r, 'text', encoding = "UTF-8")
content(r, as = "parsed", encoding = "utf-8")
# trick to find out the encoding
stringi::stri_enc_detect(content(r, "raw"))

# raw content
bin <- content(r, 'raw')
writeBin(bin, "src.html")

# posting forms
fields <- list(
  'tipus' = 1,
  'filters[inici]' = '01/01/2000',
  'filters[fi]' = '31/12/2000',
  'filters[idColla][]' = 'bordegassos',
  # 'submit' = 'BUSCAR'
  'pag' = 2
)
r <- POST(url, 
          body = fields, 
          encode = 'form',
          user_agent('libcurl/7.43.0 r-curl/0.9.7 httr/1.2.1'),
          verbose())
