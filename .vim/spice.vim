
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""" Fichier de configuration pour fonction en laguage SPICE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Chargement des commandes SPICE à l'ouverture d'un .cir
"autocmd BufNewfile,BufRead *.cir,*.sp,*.cdl,*.inc,*.pex,*.pxi,*.typ,*.lib,*.mod,*.ext,*.ckt,*.sp2,*.sp3,carac,netlist call SpiceMappings()
"autocmd BufNewFile,BufRead *.cir,*.sp,*.cdl,*.inc,*.pex,*.pxi,*.typ,*.lib,*.mod,*.ext,*.ckt,*.sp2,*.sp3,carac,netlist call SpiceInit()
" Ici, le call du SpiceInit ne fonctionne plus très bien .... et il faut le
" mettre à la fin sans autocmd ... call ... ??

let g:spice_sep="****************************************"

function! SpiceInit()

  call SpiceMappings()
  let s:pwd = getcwd() 
  let s:ls = split(globpath('.','*'),'\n')
  echo "Checking current directory for specific files ..."
  echo "-->Directory name : ".s:pwd
  let vimfile=[]
  call add(vimfile,glob('`find . -maxdepth 1 -type f -name \.tech.vim`') )
  call add(vimfile,glob('`find . -maxdepth 1 -type f -name \.subckt.vim`') )
  call map(vimfile, "substitute(v:val, '\./', '', 'g')" ) "On greppe les fichiers spéxiaux
  if len(vimfile)>0
    let id=0
    while id<len(vimfile)
      "source vimfile[id]
      if vimfile[id]==".tech.vim"
        source ./.tech.vim
        echohl Title | echo "Found specific ".vimfile[id]." file in working directory ... load done"
      elseif vimfile[id]==".subckt.vim"
        source ./.subckt.vim
        echohl Title | echo "Found specific ".vimfile[id]." file in working directory ... load done"
      endif
      let id += 1
    endwhile
  endif

endfunction

function! SpiceMappings()
  echohl Title | echo "Loading Spice functions ... done." | echohl None <CR>
  command! -nargs=0 Nmos :call NewMOS()
  command! -nargs=0 Nsub :call Newsubckt()
  command! -nargs=0 Nvs :call NewVSource()
  " Old functions call
  "command! -nargs=0 Vs :call NewVoltageSource()
  "command! -nargs=0 Testwrap :call Testwrap()
  "command! -nargs=0 Returntest :call Return_test()
  "sleep 1
  echo ""
endfunction

function! Eldo_string_wrap(string2print)
  " Fonction de découpage des strings en tableaux de strings de longueur max
  " 80. Pas testé avec des mots de plus de 80, mais bon
  " Oui je sais je suis maniaque et j'aime les rayures parallèles des zèbres
  " ET ALORS ?
  " Debug
  "echo a:string2print
  let s:list2print=[]
  let s:listsplit=split(a:string2print) "split du string d'entrée. !\n non fonctionnel
  let s:listindex=0
  let s:listlength=len(s:listsplit)
  while s:listlength>0 "tant que la list de sortie comporte au moins un mot
    let s:stringindex=0
    while s:stringindex < s:listlength
      "echo join(s:listsplit[0:s:stringindex]) len(join(s:listsplit[0:s:stringindex]))
      let s:stringindex += 1
      if len(join(s:listsplit[0:s:stringindex])) > 80
        break "Si la longeur de la string suivante >80, on sort
      endif
    endwhile
    call add(s:list2print,join(s:listsplit[0:s:stringindex-1]))
    call remove(s:listsplit, 0, s:stringindex-1) "On ajoute la string courante à la liste de sortie et on enlève la string de la liste d'entrée
    if len(s:listsplit)==0
      break
    endif
    call insert(s:listsplit, '+' ,0) "On insère le + de continuation de ligne d'ELDO
    let s:listlength=len(s:listsplit)
    let s:listindex += 1
  endwhile
  " Debug
  "echo s:list2print
  return s:list2print
endfunction

function! NewMOS()
" Fonction de generation des MOS générique
" Syntax ELDO type
" X_MOSNAME DRAIN GATE SOURCE SUBSTRATE l=l_val w=w_val model=model_name

  let curline = line('.')
  echohl Title | echo 'MOS Generator' | echohl None
  echo 'Choose MOS type : '
  echo '1: NMOS'
  echo '2: PMOS'
  let dopagei=input('')
  if dopagei==1
    let dopage='N'
    elseif dopagei==2
    let dopage='P'
    endif
  echo '\nChoose MOS model : '
  let modeli=input('')
  let name = input('MOS Name : ','')
  let drain = input('Drain node name : ','')
  let gate = input('Gate node name : ','')
  let source = input('Source node name : ','')
  let bulk = input('Bulk node name : ','')
  let w = input('MOS Width : ','')
  let l = input('MOS Length : ','')
  call append(curline,'m_'.dopage.'_'.name.' '.drain.' '.gate.' '.source.' '.bulk.' model='.model.' '.'l='.l.' w='.w)

endfunction


function! Newsubckt()
" Fonction de generation de subckt
" Syntaxe ELDO type 
" .subckt name
" + ! Pin List
" + pinlist
" + ! Param List
" + pinlist
" + ! Comments
"
" .ends

  let curline = line('.')
  echohl Title | echo "Subciruits Generator" | echohl None

  let subcktname = input("Subckt name : ","")
  let portlist = input("Port list : ","")
  let paramlist = input("Param list : ","")
  let portlist = "+ ".portlist
  let paramlist = "+ ".paramlist
  call append(curline,".subckt ".subcktname)
  let curline +=1
  call append(curline,"+ ! Pin List")
  let curline +=1
  let s:port2print=Eldo_string_wrap(portlist)
  let s:index=0
  while s:index<len(s:port2print)
    call append(curline+s:index,s:port2print[s:index])
    let s:index +=1
  endwhile
  let curline += s:index
  call append(curline,"+ ! Param List")
  let curline += 1
  let s:param2print=Eldo_string_wrap(paramlist)
  let s:index=0
  while s:index<len(s:param2print)
    call append(curline+s:index,s:param2print[s:index])
    let s:index +=1
  endwhile
  let curline += s:index
  call append(curline,"+ ! Comments")
  call append(curline+2,".ends")
 
  " Old function
  "let s:string2print='.subckt '.subcktname."\n"."+ ! Pin List"."\n".portlist."\n"."+ ! Param List"."\n".paramlist."\n.ends"
  "echo s:string2print
  "let s:list2print=Eldo_string_wrap(s:string2print)
  "echo s:list2print
  "let s:index=0
  "while s:index<len(s:list2print)
    "call append(curline+s:index,s:list2print[s:index])
    "let s:index +=1
  "endwhile
  "call append(curline,'.subckt '.subcktname.' '.portlist )
  "call append(curline+1,' ')
  "call append(curline+2,'.ends')
  "call append(curline+3,' ')

endfunction

function! NewVSource()
  let curline = line('.')
  echohl Title | echo "************************" | echohl None
  echohl Title | echo "Voltage Source Generator" | echohl None
  echohl Title | echo "************************" | echohl None

  echo "Choose Voltage Source Type: "
  echo "1: DC Voltage Source"
  echo "2: AC VOltage Source"
  echo "3: PULSE Voltage Source"
  echo "4: Single Ended Clock"
  echo "5: Differential Clock"
  echo "6: BUS Generator"
  echo "7: Digital Ramp"
  echo "8: Analog Ramp"
  let vstypei=input("")

  redraw
  echohl Title | echo "************************" | echohl None
  echohl Title | echo "Voltage Source Generator" | echohl None
  echohl Title | echo "************************" | echohl None

  if vstypei==1

    echohl Title | echo "DC Voltage Source" | echohl None
    let vstype="DC"
    let name = input("Source Name : ","V")
    let vp = input("Positive Node : ")
    let vn = input("Negative Node : ","0")
    let dc_val = input("DC Value : ")
    let s:toprint=name." ".vp." ".vn. " DC ".dc_val
    "call append(curline, name.' '.vp.' '.vn.' DC '.dc_val)
    call append(curline, s:toprint)

    elseif vstypei==2

    echohl Title | echo "AC Voltage Source" | echohl None
    let vstype="AC"
    let name = input("Source Name : ","V")
    let vp = input("Positive Node : ")
    let vn = input("Negative Node : ","0")
    let dc_val = input("DC Value : ")
    let ac_val = input("AC Magnitude Value : ","1")
    let ac_phase = input("AC Phase Value : ","0")
    call append(curline, name.' '.vp.' '.vn.' DC '.dc_val.' AC '.ac_val.' '.ac_phase)

    elseif vstypei==3

    echohl Title | echo "PULSE Voltage Source" | echohl None
    let vstype="PULSE"
    let name = input("Source Name : ","V")
    let vp = input("Positive Node : ")
    let vn = input("Negative Node : ","0")
    let dc_val = input("DC Value : ")
    let vlow = input("Low Voltage Value : ","0")
    let vhigh = input("High Voltage Value : ")
    let tp  = input("Period Value : ")
    let tw  = input("Pulse Width Value : ")
    let td  = input("Delay Value : ","0")
    let tr  = input("Rising time : ","1n")
    let tf  = input("Falling time : ","1n")

    call append(curline, name.' '.vp.' '.vn.' DC '.dc_val.' PULSE ')
    call append(curline+1, '+ ('.vlow.' '.vhigh.' '.td.' '.tr.' '.tf.' '.tw.' '.tp.')')

    elseif vstypei==4

    echohl Title | echo "Single Ended Clock" | echohl None
    let vstype="SECLOCK"
    let name = input("Source Name : ","V")
    let vp = input("Positive Node : ")
    let vn = input("Negative Node : ","0")
    let dc_val = input("DC Value : ")
    let vlow = input("Low Voltage Value : ","0")
    let vhigh = input("High Voltage Value : ")
    let freq  = input("Frequency Value : ")
    let dtc  = input("Duty Cycle (%) : ")
    let td  = input("Delay Value : ","0")
    let tr  = input("Rising time : ","1n")
    let tf  = input("Falling time : ","1n")

    call append(curline, name.' '.vp.' '.vn.' DC '.dc_val.' PULSE ')
    call append(curline+1, '+ ('.vlow.' '.vhigh.' '.td.' '.tr.' '.tf.' {(1/'.freq.'-'.tr.'-'.tf.')*'.dtc.'/100}'.' {1/' . freq . '})')

    echo "Ploting options : "
    echo "1 : Plot analog"
    echo "2 : Plot digital"
    echo "3 : Both"
    let plotoption= input("")

      if plotoption==1
        call append(curline+2, '.plot tran v('.vp.')')
        elseif plotoption==2
        call append(curline+2, '.setbus B_'.name.' '.vp)
        call append(curline+3, '.plotbus B_'.name.'vth={'.dc_val.'+('.vlow.'+'.vhigh.')/2}')
        elseif plotoption==3
        call append(curline+2, '.plot tran v('.vp.')')
        call append(curline+3, '.setbus B_'.name.' '.vp)
        call append(curline+4, '.plotbus B_'.name.' vth={'.dc_val.'+('.vlow.'+'.vhigh.')/2}')
      endif

    elseif vstypei==5

    echohl Title | echo "Differential Clock" | echohl None
    let vstype="DCLOCK"
    let name = input("Source Name : ","V")
    let vn1 = input("Node1 : ")
    let vn2 = input("Node2 : ")
    "let vmc = input("Common Mode Node : ","0")
    let dc_val = input("DC Value : ")
    let vlow = input("Low Voltage Value : ","0")
    let vhigh = input("High Voltage Value : ")
    let freq  = input("Frequency Value : ")
    let dtc  = input("Duty Cycle (%) : ")
    let td  = input("Delay Value : ","0")
    let tr  = input("Rising time : ","1n")
    let tf  = input("Falling time : ","1n")
    let no  = input("Non Overlapping time : ","0")

    call append(curline, name.'_1 '.vn1.' 0 DC '.dc_val.' PULSE ' )
    call append(curline+1, '+ ('.vlow.' '.vhigh.' '.td.' '.tr.' '.tf.' {(1/'.freq.'-'.tr.'-'.tf.'-'.no.')*'.dtc.'/100}'.' {1/'.freq.'})' )
    call append(curline+2, name.'_2 '.vn2.' 0 DC '.dc_val.' PULSE ' )
    call append(curline+3, '+ ('.vhigh.' '.vlow.' '.td.' '.tr.' '.tf.' {(1/'.freq.'-'.tr.'-'.tf.'-'.no.')*'.dtc.'/100}'.' {1/'.freq.'})' )

    echo "Ploting options : "
    echo "1 : Plot analog"
    echo "2 : Plot digital"
    echo "3 : Both"
    echo "4 : None"
    let plotoption = input("")

      if plotoption==1
        call append(curline+4, '.plot tran v('.vn1.') v('.vn2.')')
        elseif plotoption==2
        call append(curline+4, '.setbus B_'.name.'_1 '.vn1)
        call append(curline+5, '.setbus B_'.name.'_2 '.vn2)
        call append(curline+6, '.plotbus B_'.name.'_1 '.'vth={'.dc_val.'+('.vlow.'+'.vhigh.')/2}')
        call append(curline+7, '.plotbus B_'.name.'_2 '.'vth={'.dc_val.'+('.vlow.'+'.vhigh.')/2}')
        elseif plotoption==3
        call append(curline+4, '.plot tran v('.vn1.') v('.vn2.')')
        call append(curline+5, '.setbus B_'.name.'_1 '.vn1)
        call append(curline+6, '.setbus B_'.name.'_2 '.vn2)
        call append(curline+7, '.plotbus B_'.name.'_1 '.'vth={'.dc_val.'+('.vlow.'+'.vhigh.')/2}')
        call append(curline+8, '.plotbus B_'.name.'_2 '.'vth={'.dc_val.'+('.vlow.'+'.vhigh.')/2}')
      endif

    elseif vstypei==6

    echohl Title | echo "Bus Generator" | echohl None
    let vstype="BUS"
    let name = input("BUS Name : ")
    let id1 = input("Index 1 : ","0")
    let id2 = input("Index 2 : ")
    let vlow = input("Low Voltage Value : ","0")
    let vhigh = input("High Voltage Value : ")
    let thold  = input("Hold Value : ")
    let td  = input("Delay Value : ","0")
    let tr  = input("Rising time : ","1n")
    let tf  = input("Falling time : ","1n")
    let base  = input("Base (BIN, OCT, HEX, DEC) : ")
    
    call append(curline, '.sigbus ' . name)
    exe "normal j$a "
    for id in range(id1, id2)
      exe "normal a" . name
      exe "normal a<"
      exe "normal a" . id
      exe "normal a>"
      exe "normal a "
    endfor
    call append(curline+1, '+ vhi='.vhigh.' vlo='.vlow.' tfall='.tf.' trise='.tr)
    call append(curline+2, '+ thold='.thold.' tdelay='.td)
    call append(curline+3, '+ base='.base)

    echo "BUS Definition Mode : "
    echo "1 : Decimal Pattern Mode"
    echo "2 : List Pattern Mode"
    echo "3 : Timing/Value Mode"
    echo "4 : Associated Filename"
    let busmodeoption= input("")

      if busmodeoption==1
        let pat = input("Pattern Name : ")
        call append(curline+4, '+ pattern $('.pat.')')
        elseif busmodeoption==2
        let patlist = input("Pattern List : ")
        call append(curline+4, '+ pattern '.patlist )
        elseif busmodeoption==3
        let tvlist = input("Timing/Value List : ")
        call append(curline+4, '+ pattern '.tvlist )
        elseif busmodeoption==4
        let filename = input("Filename : ")
        call append(curline+4, '+ file= '.filename )
      endif

    echo "Periodic BUS ? : "
    echo "1 : Yes"
    echo "2 : No"
    let busperiod = input("")

      if busperiod==1
        call append(curline+5, '+ p')
      endif

    echo "Plot BUS ? : "
    echo "1 : Yes"
    echo "2 : No"
    let busplot = input("")

      if busplot==1
        call append(curline+6, '.plotbus '.name.' vth={('.vhigh.'+'.vlow.')/2')
      endif

    endif

endfunction

call SpiceInit()

" Fonctions de J
"function! Test()
  "echohl Title | echo 'Affectation et affichage' | echohl None
  "let tab1d = [ 23 , 13 ]
  "let tab2d = [ [ 16 , 18 ] , [ 12 , 17 ] ]
  "echo 'tab1d[0] : ' . tab1d[0]
  "echo 'tab1d[1] : ' . tab1d[1]
  "echo 'tab2d[0][1] : ' . tab2d[0][1]
  "for s in tab2d[1]
    "echo ' tab2d[1][' . index(tab2d[1],s) . '] ' . s
  "endfor
  "echohl Title | echo 'Ending tests' | echohl None
"endfunction

"function! Table(title, nb, ...)
  "echohl Title
  "echo a:title
  "echo 'Salut les loulous'
  "echohl None
  "echo a:0 . ' items:'
  "for s in a:000
    "echon ' ' . s
  "endfor
"endfunction

"function! NewVoltageSource()
  "let curline = line('.')
  "let name = input('Source Name : ','V')
  "let vp = input('Positive node : ','')
  "let vn = input('Negative node : ','0')
  "let amp = input('Amplitude : ')
  "let tp  = input('Period : ')
  "let tw  = input('Pulse width : ',tp/2)
  "let td  = input('Delay : ','0')
  "let tr  = input('Rising time : ','1n')
  "let tf  = input('Falling time : ','1n')
  "call append(curline,name.' '.vp.' '.vn.' ( 0 '.amp.' '.td.' '.tr.' '.tf.' '.tw.' '.tp.' )')
"endfunction

"" Fonction pour le debug de Eldo_string_wrap
"function! Return_test()
  "let s:temp=Eldo_string_wrap('Fiiiiirst toto qhiu toto titi tata testetautres etontestedefairebcccccppppplllluuuuusssss long pour voir')
  "let curline = line('.')
  "let s:index=0
  "while s:index<len(s:temp)
    "call append(curline+s:index,s:temp[s:index])
    "let s:index +=1
  "endwhile
  "" Debug
  ""echo 'Print done'
  ""echo s:temp
"endfunction

" Test pour la fonction de wrap
"function! Testwrap()
  "let curline=line('.')
  "let s:stringi80="Ceci est une string de longeur inferieure a 80 : 62 exactement"
  "let s:strings80="Ceci est une string de longeur superieure a 80 je rajoutte des trucs pour ça : 92 exactement"
  "let s:strings160="Ceci est une string de longeur superieure a 160 je rajoutte des trucs pour ca, vraiiiiiiiiiiiiment plein alleeeeeeeeeeeezzzzzzzzzz, encooooooorrrrreeeeeeee : 172 exactement"

  "let j=0
  "let s:lists160=split(s:strings160)
  "let s:len1=len(s:lists160)
  "let toprint=[]
  "while len(s:lists160)>0
    "let i=0
    "while i < s:len1
      "echo join(s:lists160[0:i]) len(join(s:lists160[0:i]))
      "let i += 1
      "if len(join(s:lists160[0:i]))>80
        "break
      "endif
    "endwhile
    "call add(toprint,join(s:lists160[0:i-1]))
    "call remove(s:lists160, 0, i-1)
    "let s:len1=len(s:lists160)
    "let j += 1
  "endwhile
  "echo toprint
  
  "let s:lists80=split(s:strings80)
  "let s:len1=len(s:lists80)
  "let toprint=[]
  "while len(s:lists80)>0
    "let i=0
    "while i < s:len1
      "echo join(s:lists80[0:i]) len(join(s:lists80[0:i]))
      "let i += 1
      "if len(join(s:lists80[0:i]))>80
        "break
      "endif
    "endwhile
    "call add(toprint,join(s:lists80[0:i-1]))
    "call remove(s:lists80, 0, i-1)
    "if len(s:lists80)==0
      "break
    "endif
    "call insert(s:lists80, '+' ,0)
    "let s:len1=len(s:lists80)
    "let j += 1
  "endwhile
  "echo toprint

  ""while i < s:len1
    ""echo join(s:listi80[0:i]) len(join(s:listi80[0:i]))
    ""let i += 1
  ""endwhile
  ""call append(curline,s:stringi80)
  ""call append(curline+1,s:strings80)
  ""call append(curline+2,s:strings160)
"endfunction

" Old function de génération des MOS pour techno TSMC N28
"function! NewMOS()
"" Fonction de generation des MOS
"" Syntax ELDO type
"" X_MOSNAME DRAIN GATE SOURCE SUBSTRATE l=l_val w=w_val m=m_val nf=nf_val
"" A adapter en fonction des technos, ici exemple TSMCN28

  "let curline = line('.')
  "echohl Title | echo 'MOS Generator' | echohl None

  "echo 'Choose MOS type : '
  "echo '1: NMOS'
  "echo '2: PMOS'
  "let dopagei=input('')
  "if dopagei==1
    "let dopage='N'
    "elseif dopagei==2
    "let dopage='P'
    "endif

  "' Noms des modeles - a adapter en fonction des devices disponibles, de la
  "' techno tsmc n28
  "echo '\nChoose MOS model : '
  "echo '1:' . dopage . 'CH_MAC'
  "echo '2:' . dopage . 'CH_LVT_MAC'
  "echo '3:' . dopage . 'CH_HVT_MAC'
  "echo '4:' . dopage . 'CH_18_MAC'
  "echo '5:' . dopage . 'CH_18UD15_MAC'
  "let modeli=input('')
  "if modeli==1
    "let model='CH_MAC'
    "elseif modeli==2
    "let model='CH_LVT_MAC'
    "elseif modeli==3
    "let model='CH_HVT_MAC'
    "elseif modeli==4
    "let model='CH_18_MAC'
    "elseif modeli==5
    "let model='CH_18UD15_MAC'
    "endif

  "let name = input('MOS Name : ','')
  "let drain = input('Drain node name : ','')
  "let gate = input('Gate node name : ','')
  "let source = input('Source node name : ','')
  "let bulk = input('Bulk node name : ','')
  "let w = input('MOS Width : ','')
  "let l = input('MOS Length : ','')
  "let m = input('MOS in parallel : ','1')
  "let nf = input('MOS gate fingers : ','1')

  "call append(curline,'XM'.dopage.name.' '.drain.' '.gate.' '.source.' '.bulk.' '.dopage.model.' '.'l='.l.' w='.w.' m='.m.' nf='.nf )

"endfunction

