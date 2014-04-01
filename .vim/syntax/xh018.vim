
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""" Fichier de configuration pour fonction en laguage SPICE
"""" Spécifique à la technologie xh018
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! Ndevice()
" Fonction de génération de devices

  echohl Title | echo g:spice_sep."\n"."ats130rf Device Generator\n".g:spice_sep | echohl None

  echo "Choose Device Type : "
  echo "  --> 1 : MOS transistor"
  echo "  --> 2 : Bipolar transistor"
  echo "  --> 3 : Capacitor"
  echo "  --> 4 : Resistor"
  let s:devtypei=input("")

  if s:devtypei==1
    echo "Choose MOS type : "
    echo "  --> 1 : NMOS"
    echo "  --> 2 : PMOS"
    let s:mosdopei=input("")
    let s:devtype=s:mosdopei."mos"
    echo "Choose MOS transistor model : "
    echo "  --> 1 : GO1 Low Power MOS"
    echo "  --> 2 : GO1 Low Vt MOS"
    echo "  --> 3 : GO1 Isolated Low Power MOS"
    echo "  --> 4 : GO1 Isolated Low Vt MOS"
    echo "  --> 5 : GO2 Low Power MOS"
    echo "  --> 6 : GO2 Isolated Low Power MOS"
    echo "  --> 7 : GO2 Depletion MOS"
    let s:mosmodeli=input("")
  endif "" Endif mos device

echo g:spice_sep

endfunction

function! Askpin(pinstring)
" Fonction qui demande les node name associés aux pins

  let id = 0 | let s:pinname=[] | let s:pinlist=split(a:pinstring)
  while id<len(s:pinlist)
    call add(s:pinname, input("Enter ".s:pinlist[id]." node name : ","") )
    let id += 1
  endwhile
  return s:pinname

endfunction

