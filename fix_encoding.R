library(stringr)

# fixes the encoding problems from the raw data
fix_encoding <- function(x) {
  
  x <- str_replace_all(x, "Ã\u0087", "Ç")
  x <- str_replace_all(x, "Ã\u0091", "Ñ")
  x <- str_replace_all(x, "Ã\u0080", "À")
  x <- str_replace_all(x, "Ã\u0081", "Á")
  x <- str_replace_all(x, "Ã\u0088", "È")
  x <- str_replace_all(x, "Ã\u0089", "É")
  x <- str_replace_all(x, "Ã\u008d", "Í")
  x <- str_replace_all(x, "Ã\u008f", "Ï")
  x <- str_replace_all(x, "Ã\u0092", "Ò")
  x <- str_replace_all(x, "Ã\u0093", "Ó")
  x <- str_replace_all(x, "Ã\u009a", "Ú")
  x <- str_replace_all(x, "Ã\u009c", "Ü")
  x <- str_replace_all(x, "Ã©", "é")
  x <- str_replace_all(x, "Ã³", "ò")
  x <- str_replace_all(x, "Ãº", "ú")
  x <- str_replace_all(x, "Ã¡", "ç")
  x <- str_replace_all(x, "Ã§", "ç")
  x <- str_replace_all(x, "Â·", "í")
  x <- str_replace_all(x, "Â´", "'")
  
  # Custom stuff
  x <- str_replace_all(x, "SarriÃ", "Sarrià")
  x <- str_replace_all(x, "de GrÃ", "de Grà")
  x <- str_replace_all(x, "de GavÃ", "de Gavà")
  x <- str_replace_all(x, "de CornellÃ", "de Cornellà")
  x <- str_replace_all(x, "de RubÃ", "de Rubí")
  x <- str_replace_all(x, "d'EramprunyÃ", "d'Eramprunyà")
  x <- str_replace_all(x, "Sant MagÃ", "Sant Magí")
  
  return(x)
  
}

# DEBUG
# x <- unique(data_refined$colla)
# x <- fix_encoding(x)
# y <- x[17]
# str_match(y, "Sant MagÃ", "Sant Magí")
# str_replace_all(y, "Sant MagÃ", "Sant Magí")
# str_conv(y, 'ISO-8859-1')

