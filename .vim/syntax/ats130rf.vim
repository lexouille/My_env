
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""" Fichier de configuration pour fonction en laguage SPICE
"""" Spécifique à la technologie xh018
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! Ndevice()
" Fonction de génération de devices

  echohl Title | echo "****************************************" | echohl None
  echohl Title | echo "ats130rf Device Generator" | echohl None
  echohl Title | echo "****************************************" | echohl None

  echo "Choose Device Type: "
  echo "  --> 1 : MOS transistor"
  echo "  --> 2 : Bipolar transistor"
  echo "  --> 3 : Capacitor"
  echo "  --> 4 : Resistor"
  let s:devtypei=input("")


  if s:devtypei==1
    let s:devtype="mos"
    redraw
    echohl Title | echo "****************************************" | echohl None
    echohl Title | echo "ats130rf Device Generator" | echohl None
    echohl Title | echo "MOS transistor" | echohl None
    echohl Title | echo "****************************************" | echohl None
    echo "Choose MOS transistor model: "
    echo "  --> 1 : GO1 Low Power MOS"
    echo "  --> 2 : GO1 Low Vt MOS"
    echo "  --> 3 : GO1 Isolated Low Power MOS"
    echo "  --> 4 : GO1 Isolated Low Vt MOS"
    echo "  --> 5 : GO2 Low Power MOS"
    echo "  --> 6 : GO2 Isolated Low Power MOS"
    echo "  --> 7 : GO2 Depletion MOS"
    let s:mostypei=input("")

echo g:spice_sep

endfunction

