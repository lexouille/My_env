Netlist_name user_name

********************************************************************************
**** Search path for technology 
********************************************************************************
.option search = searchpath

********************************************************************************
**** General option for simulation
********************************************************************************
.option
+ nowarn=240
+ nowarn=252
+ nowarn=255
+ nowarn=902
+ nowarn=209
+ alter_nominal_text=nom
+probeop2
+ aex=2 alignext
+ tuning = accurate ! global accuracy parameter => fast standard accurate vhigh
*+ premier ! Only for gig netlist to improve CPU Time

********************************************************************************
**** Netlist call. Text / schematic or PLS
********************************************************************************
.include ./netlist.cir

********************************************************************************
**** Custom Models, Technology model file(optional, see end of file PVT section)
********************************************************************************
*.include techfile_path/modelfile
*.lib /nfs/work-crypt/ic/common/altis/1.2.2/eldo/models/include.eldo nom
*.lib /nfs/work-crypt/ic/common/altis/1.2.2/eldo/models/include.eldo fs
*.lib /nfs/work-crypt/ic/common/altis/1.2.2/eldo/models/include.eldo sf
*.lib /nfs/work-crypt/ic/common/altis/1.2.2/eldo/models/include.eldo fast
*.lib /nfs/work-crypt/ic/common/altis/1.2.2/eldo/models/include.eldo slow


********************************************************************************
**** Global input definition
********************************************************************************
**** Voltage domain
.param vddgo1=1.5 vddgo2=2.5 vddio=3.3
vavddgo1 avddgo1 avss dc vddgo1
vavddgo2 avddgo2 avss dc vddgo2
vdvddgo1 dvddgo1 dvss dc vddgo1
vdvddgo2 dvddgo2 dvss dc vddgo2
vddio vddio iovss dc vddio
.connect avss 0
.connect dvss 0
.connect iovss 0
**** Temperature
.param tval=25
.temp tval

********************************************************************************
**** Testbenches definitions
********************************************************************************

.define_testbench Operating_Point

*****************************************
* Inputs definition
*****************************************

*****************************************
* Simulation parameters
*****************************************

*****************************************
* Run simulation option
*****************************************
.op

*****************************************
* Probing
*****************************************
.probe op vtop
*.probe op v
.probe op i

*****************************************
* Outputs list
*****************************************

*****************************************
* Extraction function
*****************************************

.end_define_testbench

.define_testbench DC_Analysis

*****************************************
* Inputs definition
*****************************************

*****************************************
* Simulation parameters
*****************************************

*****************************************
* Run simulation option
*****************************************
.dc

*****************************************
* Probing
*****************************************
.probe dc vtop
*.probe dc v
.probe dc i

*****************************************
* Outputs list
*****************************************

*****************************************
* Extraction function
*****************************************

.end_define_testbench

.define_testbench Transient_Analysis

*****************************************
* Inputs definition
*****************************************
Vckin IN dvss DC 0 PULSE 
+ (0 vddio 0 10p 10p {(1/100Meg-10p-10p)*50/100} {1/100Meg})

*****************************************
* Simulation parameters
*****************************************
.param cload=50f

*****************************************
* Run simulation option
*****************************************
.tran tprint tstop
.param tprint=0.1n tstop=100n

*****************************************
* Probing
*****************************************
.probe tran vtop
*.probe v
*.probe tran i
.setbus B_Vckin IN
.plotbus B_Vckin vth*{0+(0+vddgo1)/2}

*****************************************
* Outputs list
*****************************************
Cout out dvss cload

*****************************************
* Extraction function
*****************************************
.extract label=tup trise(v(out), vh={0.9*vddio}, vl={0.1*vddio})
.extract label=tdown tfall(v(out), vh={0.9*vddio}, vl={0.1*vddio})

.end_define_testbench

.define_testbench AC_Analysis

*****************************************
* Inputs definition
*****************************************

*****************************************
* Simulation parameters
*****************************************

*****************************************
* Run simulation option
*****************************************
.AC

*****************************************
* Probing
*****************************************
.probe ac vtop
*.probe ac v
.probe ac i

*****************************************
* Outputs list
*****************************************

*****************************************
* Extraction function
*****************************************

.end_define_testbench

.define_testbench SOA_check

*****************************************
* Inputs definition
*****************************************

*****************************************
* Simulation parameters
*****************************************

*****************************************
* Run simulation option
*****************************************
.checksoa

*****************************************
* Probing
*****************************************
.probe vtop
*.probe v
.probe i

*****************************************
* Outputs list
*****************************************

*****************************************
* Extraction function
*****************************************

.end_define_testbench

********************************************************************************
**** Testbench call
********************************************************************************
.Operating_Point
.DC_Analysis
.Transient_Analysis
.AC_Analysis
.SOA_check

********************************************************************************
**** User defined stuff
********************************************************************************

********************************************************************************
**** Global parameters & PVT variations
********************************************************************************
*.step param vddgo1 list 1.35 1.5 1.65
*.step param vddgo2 list 2.25 2.5 2.75
*.step param vddio list 2.97 3.3 3.63
*.step param (vddgo1 vddgo2 vddio) list (1.35 2.25 2.97) (1.5 2.5 3.3) (1.65 2.75 3.63)
*.step param tval list 0 25 50

.lib include.inc common

.lib include.inc mostyp
.lib include.inc btyp
.lib include.inc rtyp
.lib include.inc ctyp

.end

