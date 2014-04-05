
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""" Fichier de génération des devices du fichier netlist.cir
"""" Généré par le script perl
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

command! -nargs=0 Nsubckt :call Nsubckt()
function! Nsubckt()
" Fonction de génération de devices

  let curline = line('.')
  echohl Title | echo g:spice_sep."\n"."Specific Device Generator\n".g:spice_sep | echohl None
  echo "Choose subckt to instanciate\n"
