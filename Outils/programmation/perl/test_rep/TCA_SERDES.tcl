#!/usr/bin/env tclsh
#include <tcl.h>


## Registre(Reg_name) [list Position Size Default_Value]
set regw(isolation_n) 		[list 0   1  01  ]
set regw(TxClkPolarity) 	[list 1   1  00  ]
set regw(TxPisoSelTxSync) 	[list 2   2  11  ]
set regw(TxCtrlMain) 		[list 14  4  01  ]

##################################################################################################################################################################
## Verification user param function
##################################################################################################################################################################
proc Check_Registre {Name Val} {
	global regw ;## defini le tableau contenant tout les registre existant
	## Test d'existence du registre a configurer	
	if { [info exists regw($Name)] } {
		## Le registre existe !
		## A partir de la taille du registre, on determine sa valeur max associable
		## Puis on la compare a celle de l'utilisateur
		set Size [lindex $regw($Name) 1]
		set nVal_Tot [expr int([expr pow(2,$Size)])] ;## Calcul le nbr de valeur configurable à partir de la taille du registre (2^regsize)
		set Reg_Val_Max [format %.X [expr $nVal_Tot-1]]  ;## Calcul de la valeur max configurable à partir du nbr de valeur configurable
		## Test de la valeur a configurer
		if { $Val > $Reg_Val_Max } {
			puts "Error"; puts "The value $Val that you try to set on '$Name' is not consistent"; 
			puts "The maximum value you can set for '$Name' is 0x$Reg_Val_Max !"; puts "END Script"; exit; } 
	} else {
		## Le registre n'existe pas !
		puts "Error"; puts "$Name do not exit"; puts "END script"; exit; } 
}


##################################################################################################################################################################
## Register value modification function
##################################################################################################################################################################
proc Set_Register {init_reg reg_name reg_val} { 
	global regw ;## defini le tableau contenant tout les registre existant

	Check_Registre $reg_name $reg_val
	
	set reg_pos  [lindex $regw($reg_name) 0]
	set reg_size [lindex $regw($reg_name) 1]
	
	puts "\#\#\#\#\#\#\#\#\#\#\#\# Entering Set_Register function: \#\#\#\#\#\#\#\#\#\#\#\#"
	
	puts "Initial Register : [format %.16X $init_reg]"
	puts "Register to set: $reg_name"
	puts "Value to set: $reg_val"
	puts "Register Position: $reg_pos, Size: $reg_size"
	
	set init_mask 0x0000000000000000
	set overwrite_reg $reg_val
	for {set k 0} {$k < $reg_size} {incr k} {
		set init_mask [expr $init_mask << 0x1]
		incr init_mask 0x1
	}
	
	for {set k 0} {$k < $reg_pos} {incr k} {
		set init_mask [expr $init_mask << 0x1]
		set overwrite_reg [expr $overwrite_reg << 0x1]
	}

	set mask [expr ~ $init_mask]

	puts "Register Mask : [format %.16X $mask]"
  	puts "Valeur finale de overwrite_reg : [format %.16X $overwrite_reg]"
	
	set regf [expr $init_reg & $mask]
	puts "First: Register final: Register initial & Mask : [format %.16X $regf]"
	
	set regf [expr $regf | $overwrite_reg]
	puts "Second Register final: Registre final | Overwrite_reg : [format %.16X $regf]"
	
	puts "\#\#\#\#\#\#\#\#\#\#\#\# Exiting mod_register function \#\#\#\#\#\#\#\#\#\#\#\#"; puts "\n"
	
	return $regf
}


##################################################################################################################################################################
## Set Register default_value function
##################################################################################################################################################################
proc bin2hex {bin} {
	set t {
		0000 0 0001 1 0010 2 0011 3 0100 4 0101 5 0110 6 0111 7
		1000 8 1001 9 1010 a 1011 b 1100 c 1101 d 1110 e 1111 f
	}
	if {[set diff [expr {4-[string length $bin]%4}]] != 4} {
		set bin [format %0${diff}d$bin 0]
	}
	return [string map $t $bin]
}

proc Set_Register_to_Default {init_reg} { 
	global regw ;## defini le tableau contenant tout les registre existant
	
	foreach reg [array names regw] {
		set reg_Default_Val  [bin2hex [lindex $regw($reg) 2]]
		
		set init_reg [Set_Register $init_reg $reg $reg_Default_Val]
	}
	return $init_reg
}

##################################################################################################################################################################
## Debug function
##################################################################################################################################################################
proc Debug_Reg {} { 
	global regw ;## defini le tableau contenant tout les registre existant
	
	puts "Debug start :\n"
	foreach reg [array names regw] {
		set reg_pos  [lindex $regw($reg) 0]
		set reg_size [lindex $regw($reg) 1]
		set reg_Default_Val  [lindex $regw($reg) 2]
		
		set init_mask 0x0000000000000000	
		for {set k 0} {$k < $reg_size} {incr k} {
			set init_mask [expr $init_mask << 0x1]
			incr init_mask 0x1
		}
		for {set k 0} {$k < $reg_pos} {incr k} {
			set init_mask [expr $init_mask << 0x1]
		}
		set mask [expr ~ $init_mask]
		puts "Register: $reg"
		puts "Register Size: $reg_size"
		puts "Register Position: $reg_pos"
		puts "Default_Value: $reg_Default_Val"
		puts "Mask corresponding to Register : [format %.16x $mask]"
		puts "\n"
	}
	puts "Debug end !"
}

##################################################################################################################################################################
## Config
##################################################################################################################################################################
set reg0 0x0000000000000000
set reg1 0x0000000000000000
set reg2 0x0000000000000000
set reg3 0x0000000000000000

##set reg0 [Set_Register $reg0 isolation_n 0x1]
##set reg0 [Set_Register $reg0 TxClkPolarity 0x0]
##set reg0 [Set_Register $reg0 TxPisoSelTxSync 0x3]
##set reg0 [Set_Register $reg0 TxCtrlMain 0xf]

set reg0 [Set_Register_to_Default $reg0]

##Debug_Reg 

puts "Reg_final : [format %.16X $reg0]"
