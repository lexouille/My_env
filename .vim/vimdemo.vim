"Notes sur les fonctions :
"
"! après function pour les écraser si elles exsitent déjà au moment du source


function! Demo()
let curline = getline ('.')
call inputsave()
let name = input('Enter name :')
call inputrestore()
call setline('.', curline . ' ' . name)
!ls
:r /nfs/home/aferret/Documents/TravailEnCours/temp.cir
":!awk -f vclock.awk -v arg1=0 -v arg2=0 -v arg3=vddgo1 -v arg4=10p -v arg5=5p -v arg6=5p temp.cir > temptor.cir
:exec "awk -f vclock.awk -v arg1=0 -v arg2=0 -v arg3=vddgo1 -v arg4=10p -v arg5=5p -v arg6=5p temp.cir > temptor.cir"
:r temptor.cir
echo("SC done")
echo name
:!echo @name
endfunction

function! Clock()
let dc_clock = input('Enter DC OFFSET Value : ')
let v0_val = input('Enter VLow Value : ')
let v1_val = input('Enter VHigh Value : ')
let td_val = input('Enter Delay Value : ')
let tr_val = input('Enter Rise Time Value : ')
let tf_val = input('Enter Fall time Value : ')
let freq_val = input('Enter Frequency Value : ')
":!awk -f vclock.awk -v arg1=dc_clock -v arg2=v0_val -v arg3=v1_val -v arg4=td_val -v arg5=tr_val -v arg6=tf_val temp.cir > temptor.cir
:exec ":!awk -f vclock.awk -v arg1=" . dc_clock . " -v arg2=" . v0_val . " -v arg3=" . v1_val . " -v arg4=" . td_val . " -v arg5=" . tr_val . " -v arg6=" . tf_val . " -v arg7=" . freq_val . " temp.cir > temptor.cir"
:r temptor.cir
:!rm temptor.cir
echo("Clock Gen done")
endfunction

