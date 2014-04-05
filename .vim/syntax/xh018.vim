
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""" Fichier de configuration pour fonction en language SPICE
"""" Spécifique à la technologie xh018
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! Ndevice()
" Fonction de génération de devices

  let curline = line('.')
  echohl Title | echo g:spice_sep."\n"."ats130rf Device Generator\n".g:spice_sep | echohl None
  echo "Choose Device Type : \n  --> 1 : MOS transistor\n  --> 2 : Bipolar transistor\n  --> 3 : Capacitor\n  --> 4 : Resistor\n"
  let s:devtypei=input("")

  if s:devtypei==1
    let s:devname=input("Choose MOS name : ","X_")
    let s:mosdopei=input("\nChoose MOS type : \n  --> n : NMOS\n  --> p : PMOS\n","") | let s:devtype=s:mosdopei."mos"
    echo "\nChoose MOS transistor model : "
    echo "  --> 1 : GO1 Low Power MOS"
    echo "  --> 2 : GO1 Low Vt MOS"
    echo "  --> 3 : GO1 Isolated Low Power MOS"
    echo "  --> 4 : GO1 Isolated Low Vt MOS"
    echo "  --> 5 : GO2 Low Power MOS"
    echo "  --> 6 : GO2 Isolated Low Power MOS"
    echo "  --> 7 : GO2 Depletion MOS\n"
    let s:modeli=input("")
    if s:modeli==1 "GO1 Low Power MOS
      let s:mospin=Askpin("Drain Gate Source Bulk") | let s:mosmodel=s:mosdopei."e"
    elseif s:modeli==2 "GO1 Low Vt MOS
      let s:mospin=Askpin("Drain Gate Source Bulk") | let s:mosmodel=s:mosdopei."el"
    elseif s:modeli==3 "GO1 isolated MOS
      if s:mosdopei=="p"
        let s:mospin=Askpin("Drain Gate Source Bulk") | let s:mosmodel=s:mosdopei."ei"
      elseif s:mosdopei=="n"
        let s:iso=input("\nChoose type : \n  --> 1 : Simple isolation\n  --> 2 : In deep nwell\n  --> 3 : In deep nwell (m)\n","")
        if s:iso==1
          let s:mospin=Askpin("Drain Gate Source Bulk") | let s:mosmodel=s:mosdopei."ei"
        elseif s:iso==2
          let s:mospin=Askpin("Drain Gate Source n_Bulk Nwell Bulk") | let s:mosmodel=s:mosdopei."ei_6"
        elseif s:iso==3
          let s:mospin=Askpin("Drain Gate Source n_Bulk Nwell Bulk") | let s:mosmodel=s:mosdopei."ei_m_6"
        endif
      endif "Endif GO1 Isolated Low Power MOS
    elseif s:modeli==4 "GO1 Isolated Low Vt MOS
      if s:mosdopei=="p"
        let s:mospin=Askpin("Drain Gate Source Bulk") | let s:mosmodel=s:mosdopei."eli"
      elseif s:mosdopei=="n"
        let s:iso=input("\nChoose type : \n  --> 1 : Simple isolation\n  --> 2 : In deep nwell\n  --> 3 : In deep nwell (m)\n","")
        if s:iso==1
          let s:mospin=Askpin("Drain Gate Source Bulk") | let s:mosmodel=s:mosdopei."eli"
        elseif s:iso==2
          let s:mospin=Askpin("Drain Gate Source n_Bulk Nwell Bulk") | let s:mosmodel=s:mosdopei."eli_6"
        elseif s:iso==3
          let s:mospin=Askpin("Drain Gate Source n_Bulk Nwell Bulk") | let s:mosmodel=s:mosdopei."eli_m_6"
        endif
      endif "Endif GO1 Isolated Low t MOS
    elseif s:modeli==5 "GO2 Low Power MOS
      let s:mospin=Askpin("Drain Gate Source Bulk") | let s:mosmodel=s:mosdopei."e3"
    elseif s:modeli==6 "GO2 Isolated Low Power MOS
      if s:mosdopei=="p"
        let s:mospin=Askpin("Drain Gate Source Bulk") | let s:mosmodel=s:mosdopei."e3i"
      elseif s:mosdopei=="n"
        let s:iso=input("\nChoose type : \n  --> 1 : Simple isolation\n  --> 2 : In deep nwell\n  --> 3 : In deep nwell (m)\n","")
        if s:iso==1
          let s:mospin=Askpin("Drain Gate Source Bulk") | let s:mosmodel=s:mosdopei."e3i"
        elseif s:iso==2
          let s:mospin=Askpin("Drain Gate Source n_Bulk Nwell Bulk") | let s:mosmodel=s:mosdopei."e3i_6"
        elseif s:iso==3
          let s:mospin=Askpin("Drain Gate Source n_Bulk Nwell Bulk") | let s:mosmodel=s:mosdopei."e3i_m_6"
        endif
      endif "Endif GO2 Isolated Low Power MOS
    elseif s:modeli==7 "GO2 Depletion MOS ! NMOS only
      let s:iso=input("\nChoose type : \n  --> 1 : No isolation\n  --> 2 : In deep nwell\n  --> 3 : In deep nwell (m)\n","")
      if s:iso==1
        let s:mospin=Askpin("Drain Gate Source Bulk") | let s:mosmodel=s:mosdopei."d3"
      elseif s:iso==2
        let s:mospin=Askpin("Drain Gate Source n_Bulk Nwell Bulk") | let s:mosmodel=s:mosdopei."d3i_6"
      elseif s:iso==3
        let s:mospin=Askpin("Drain Gate Source n_Bulk Nwell Bulk") | let s:mosmodel=s:mosdopei."d3i_m_6"
      endif "Endif GO2 Depletion MOS
    endif "" Endif model
  let s:w=input("Select MOS width : ","") | let s:l=input("Select MOS length : ","") | let s:m=input("Select MOS multiple : ","1")
  let s:pin=join(s:mospin)
  call append(curline,s:devname." ".s:pin." ".s:mosmodel." w=".s:w." l=".s:l." par1=".s:m)
  endif "" Endif mos device


endfunction

function! Askpin(pinstring)
" Fonction qui demande les node name associés aux pins

  let id = 0 | let s:pinname=[] | let s:pinlist=split(a:pinstring)
  while id<len(s:pinlist)
    call add(s:pinname, input("Enter ".s:pinlist[id]." node name : ",s:pinlist[id]) )
    let id += 1
  endwhile
  return s:pinname

endfunction

