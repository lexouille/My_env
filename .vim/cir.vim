" Mon fichier de types de fichiers
if exists("did_load_filetypes")
  finish
endif
augroup filetypedetect
  au! BufRead,BufNewFile *.cir setfiletype cir
augroup END

