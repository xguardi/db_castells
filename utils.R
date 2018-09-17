short_full <- function(short, status) {
  if (status == 'Carregat') {
    x = paste0(short, "(c)")
  } else if (status == 'Intent') {
    x = paste0("i", short)
  } else if (status == 'Intent desmuntat') {
    x = paste0("id, short")
  } else {
    x = short
  }
  return(x)
}