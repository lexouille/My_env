"""""""" Fichier de configuration de VIM pour la syntaxe ELDO """"""""

"Ignore Maj / Min
syntax case ignore

"Options de folding
set foldmethod=syntax
"Folds initialement fermés
set foldlevel=0
"syntax region s_ckt start="\.subckt" end="\.ends" fold
"syntax sync fromstart
"syntax region s_ckt start="\.define_testbench" end="\.end_define_testbench" fold
"syntax sync fromstart
"Perso, change la couleur quand foldé
"highlight Folded cterm=bold ctermfg=34 ctermbg=none

"COMMENTS
syntax match s_comment "^\*.*"
syntax match s_comment "[ ] +*\*.*"
syntax match s_comment "[ ] +!.*"

"ELDO COMMANDS
syntax match s_cmd "^\.AC +"
syntax match s_cmd "^\.AGE"
syntax match s_cmd "^\.CHECKSOA"
syntax match s_cmd "^\.DC"
syntax match s_cmd "^\.DCMISMATCH"
syntax match s_cmd "^\.DEX"
syntax match s_cmd "^\.DSP"
syntax match s_cmd "^\.DSPMOD"
syntax match s_cmd "^\.FOUR"
syntax match s_cmd "^\.LSTB"
syntax match s_cmd "^\.MC"
syntax match s_cmd "^\.NOISE"
syntax match s_cmd "^\.NOISETRAN"
syntax match s_cmd "^\.OP"
syntax match s_cmd "^\.OPTFOUR"
syntax match s_cmd "^\.OPTIMIZE"
syntax match s_cmd "^\.OPTNOISE"
syntax match s_cmd "^\.PZ"
syntax match s_cmd "^\.RAMP"
syntax match s_cmd "^\.SENS"
syntax match s_cmd "^\.SENSAC"
syntax match s_cmd "^\.SENSPARAM"
syntax match s_cmd "^\.SNF"
syntax match s_cmd "^\.SOLVE"
syntax match s_cmd "^\.TF"
syntax match s_cmd "^\.TRAN"
syntax match s_cmd "^\.WCASE"
syntax match s_cmd "^\.EXTRACT"
syntax match s_cmd "^\.COMCHAR"
syntax match s_cmd "^\.DEFMAC"
syntax match s_cmd "^\.DEFPLOTDIG"
syntax match s_cmd "^\.DEFWAVE"
syntax match s_cmd "^\.EQUIV"
syntax match s_cmd "^\.EXTMOD"
syntax match s_cmd "^\.EXTRACT"
syntax match s_cmd "^\.FFILE"
syntax match s_cmd "^\.IPROBE"
syntax match s_cmd "^\.MEAS"
syntax match s_cmd "^\.MONITOR"
syntax match s_cmd "^\.NET"
syntax match s_cmd "^\.NEWPAGE"
syntax match s_cmd "^\.NOCOM"
syntax match s_cmd "^\.NOTRC"
syntax match s_cmd "^\.OP_DISPLAY"
syntax match s_cmd "^\.PLOT"
syntax match s_cmd "^\.PLOTBUS"
syntax match s_cmd "^\.PRINT"
syntax match s_cmd "^\.PRINTBUS"
syntax match s_cmd "^\.PRINTFILE"
syntax match s_cmd "^\.PROBE"
syntax match s_cmd "^\.PROBEBUS"
syntax match s_cmd "^\.WIDTH"
syntax match s_cmd "^\.CALL_TCL"
syntax match s_cmd "^\.CHECKBUS"
syntax match s_cmd "^\.CONSO"
syntax match s_cmd "^\.CORREL"
syntax match s_cmd "^\.DATA"
syntax match s_cmd "^\.DISCARD"
syntax match s_cmd "^\.DISFLAT"
syntax match s_cmd "^\.DISTRIB"
syntax match s_cmd "^\.FFILE"
syntax match s_cmd "^\.FILTER"
syntax match s_cmd "^\.FORCE"
syntax match s_cmd "^\.FUNC"
syntax match s_cmd "^\.GUESS"
syntax match s_cmd "^\.IC"
syntax match s_cmd "^\.INIT"
syntax match s_cmd "^\.LOAD"
syntax match s_cmd "^\.LOTGROUP"
syntax match s_cmd "^\.MCMOD"
syntax match s_cmd "^\.MODDUP"
syntax match s_cmd "^\.MPRUN"
syntax match s_cmd "^\.NODESET"
syntax match s_cmd "^\.NWBLOCK"
syntax match s_cmd "^\.OPTION"
syntax match s_cmd "^\.OPTPWL"
syntax match s_cmd "^\.OPTWIND"
syntax match s_cmd "^\.PARAM"
syntax match s_cmd "^\.PARAMDEX"
syntax match s_cmd "^\.RESTART"
syntax match s_cmd "^\.SAVE"
syntax match s_cmd "^\.SETBUS"
syntax match s_cmd "^\.SETSOA"
syntax match s_cmd "^\.START_TIME"
syntax match s_cmd "^\.STEP"
syntax match s_cmd "^\.SUBDUP"
syntax match s_cmd "^\.TABLE"
syntax match s_cmd "^\.TEMP"
syntax match s_cmd "^\.TSAVE"
syntax match s_cmd "^\.USE"
syntax match s_cmd "^\.GUESS"
syntax match s_cmd "^\.USE_TCL"
syntax match s_cmd "^\.A2D"
syntax match s_cmd "^\.ADDLIB"
syntax match s_cmd "^\.ckt"
syntax match s_cmd "^\.AGE_LIB"
syntax match s_cmd "^\.AGEMODEL"
syntax match s_cmd "^\.ALTER"
syntax match s_cmd "^\.BIND"
syntax match s_cmd "^\.BINDSCOPE"
syntax match s_cmd "^\.CHRENT"
syntax match s_cmd "^\.CHRSIM"
syntax match s_cmd "^\.CONNECT"
syntax match s_cmd "^\.D2A"
syntax match s_cmd "^\.DEFAULT"
syntax match s_cmd "^\.DEFMOD"
syntax match s_cmd "^\.MODEL"
syntax match s_cmd "^\.DEL"
syntax match s_cmd "^\.DSPF_INCLUDE"
syntax match s_cmd "^\.END"
syntax match s_cmd "^\.ENDL"
syntax match s_cmd "^\.ENDS"
syntax match s_cmd "^\.GLOBAL"
syntax match s_cmd "^\.HIER"
syntax match s_cmd "^\.IGNORE_DSPF_ON_NODE"
syntax match s_cmd "^\.DSPF_INCLUDE"
syntax match s_cmd "^\.INCLUDE"
syntax match s_cmd "^\.LIB"
syntax match s_cmd "^\.LOOP"
syntax match s_cmd "^\.MALIAS"
syntax match s_cmd "^\.MODEL"
syntax match s_cmd "^\.MAP_DSPF_NODE_NAME"
syntax match s_cmd "^\.MODEL"
syntax match s_cmd "^\.MODLOGIC"
syntax match s_cmd "^\.MSELECT"
syntax match s_cmd "^\.PART"
syntax match s_cmd "^\.PROTECT"
syntax match s_cmd "^\.SCALE"
syntax match s_cmd "^\.SELECT_DSPF_ON_NODE"
syntax match s_cmd "^\.DSPF_INCLUDE"
syntax match s_cmd "^\.SETKEY"
syntax match s_cmd "^\.SIGBUS"
syntax match s_cmd "^\.SINUS"
syntax match s_cmd "^\.ENDS"
syntax match s_cmd "^\.TITLE"
syntax match s_cmd "^\.TOPCELL"
syntax match s_cmd "^\.TVINCLUDE"
syntax match s_cmd "^\.UNPROTECT"
syntax match s_cmd "^\.USEKEY"
syntax match s_cmd "^\.VEC"

"ELDO RF COMMANDS
syntax match s_cmd "^\.SST"
syntax match s_cmd "^\.SST OSCIL"
syntax match s_cmd "^\.SST PLL"
syntax match s_cmd "^\.SST STABIL"
syntax match s_cmd "^\.SSTAC"
syntax match s_cmd "^\.SSTXF"
syntax match s_cmd "^\.SSTNLCONTRIB"
syntax match s_cmd "^\.SSTSENSRLC"
syntax match s_cmd "^\.SSTNOISE"
syntax match s_cmd "^\.SSTPROBE"
syntax match s_cmd "^\.SNF"
syntax match s_cmd "^\.WCASE"
syntax match s_cmd "^\.MC"
syntax match s_cmd "^\.MODSST"
syntax match s_cmd "^\.PART MODSST"
syntax match s_cmd "^\.RFBLOCK"
syntax match s_cmd "^\.CHRSIM"
syntax match s_cmd "^\.AGE"
syntax match s_cmd "^\.OP RF"


"COMMANDS OPTIONS & ARGUMENTS : ELDO 

syntax keyword s_option ABSTOL
syntax keyword s_option ABSVAR
syntax keyword s_option ACCSEMICOL
syntax keyword s_option ACDERFUNC
syntax keyword s_option ACM
syntax keyword s_option ACOUT
syntax keyword s_option ACSIMPROG
syntax keyword s_option ADJSTEPTRAN
syntax keyword s_option ADMS_FAST_PARSE
syntax keyword s_option ADMSBS
syntax keyword s_option AEX
syntax keyword s_option AIDSTP
syntax keyword s_option ALIGNEXT
syntax keyword s_option ALTER_NOMINAL_TEXT
syntax keyword s_option ALTER_SUFFIX
syntax keyword s_option ALTINC
syntax keyword s_option AMMETER
syntax keyword s_option ANALOG
syntax keyword s_option ASCII
syntax keyword s_option ASCIIPLOT
syntax keyword s_option ASPEC
syntax keyword s_option AUTOSTOP
syntax keyword s_option AUTOSTOPMODULO
syntax keyword s_option BE
syntax keyword s_option BLK_SIZE
syntax keyword s_option BLOCKS
syntax keyword s_option IEM
syntax keyword s_option NEWTON
syntax keyword s_option BSIM3VER
syntax keyword s_option BSLASHCONT
syntax keyword s_option CAPANW
syntax keyword s_option CAPTAB
syntax keyword s_option CARLO_GAUSS
syntax keyword s_option METHOD
syntax keyword s_option POST_DOUBLE
syntax keyword s_option COMPAT
syntax keyword s_option COMPMOD
syntax keyword s_option COMPNET
syntax keyword s_option MOTOROLA
syntax keyword s_option SDA
syntax keyword s_option SPI3ASC
syntax keyword s_option SPI3BIN
syntax keyword s_option SPI3NOCOMPLEX
syntax keyword s_option SPICEDC
syntax keyword s_option SPIOUT
syntax keyword s_option USE_SPECTRE_CONSTANT
syntax keyword s_option WSF
syntax keyword s_option WSFASCII
syntax keyword s_option CHECKDUPL
syntax keyword s_option COMPEXUP
syntax keyword s_option CONTINUE_INCLUDE
syntax keyword s_option DOTNODE
syntax keyword s_option EXTERR
syntax keyword s_option KEEPDANGLING
syntax keyword s_option KEEPSHORTED
syntax keyword s_option LOOPV0
syntax keyword s_option MTHREAD
syntax keyword s_option NOALTINCEX
syntax keyword s_option NOACT0
syntax keyword s_option NOBSLASHCONT
syntax keyword s_option NOCMPUNIX
syntax keyword s_option NOELDOLOGIC
syntax keyword s_option NOERR_XPINSMISMATCH
syntax keyword s_option NOKEYWPARAMSST
syntax keyword s_option NOMATSING
syntax keyword s_option NOSSTKEYWORD
syntax keyword s_option NOZSINXX
syntax keyword s_option PARHIER
syntax keyword s_option PATTERN_MAX_ALLOWED_COEFF
syntax keyword s_option PEVFLY
syntax keyword s_option POWNEG0
syntax keyword s_option QUOTREL
syntax keyword s_option QUOTSTR
syntax keyword s_option STOPONFIRSTERROR
syntax keyword s_option STRICT
syntax keyword s_option SUBALEV
syntax keyword s_option SUBFLAGPAR
syntax keyword s_option USEFIRSTDEF
syntax keyword s_option USETHREAD
syntax keyword s_option USE_LOCATION_MAP
syntax keyword s_option VOLTAGE_LOOP_SEVERITY
syntax keyword s_option WARN2ERR
syntax keyword s_option XBYNAME
syntax keyword s_option CHGTOL
syntax keyword s_option DVDT
syntax keyword s_option EPS
syntax keyword s_option FASTRLC
syntax keyword s_option FLUXTOL
syntax keyword s_option FREQSMP
syntax keyword s_option FROM_TO
syntax keyword s_option FT
syntax keyword s_option HMAX
syntax keyword s_option HMIN
syntax keyword s_option HRISEFALL
syntax keyword s_option INCLIB
syntax keyword s_option ITL1
syntax keyword s_option ITL3
syntax keyword s_option ITL4
syntax keyword s_option ITL6
syntax keyword s_option ITL7
syntax keyword s_option ITL8
syntax keyword s_option ITOL
syntax keyword s_option LIBINC
syntax keyword s_option LIMNWRMOS
syntax keyword s_option LVLTIM
syntax keyword s_option MAXNODES
syntax keyword s_option MAXSTEP
syntax keyword s_option MAXTRAN
syntax keyword s_option MAXV
syntax keyword s_option NETSIZE
syntax keyword s_option NGTOL
syntax keyword s_option NMAXSIZE
syntax keyword s_option NOCONVASSIST
syntax keyword s_option NODCPOWNEG
syntax keyword s_option NOLAT
syntax keyword s_option NONWRMOS
syntax keyword s_option NOQTRUNC
syntax keyword s_option NOSWITCH
syntax keyword s_option PCS
syntax keyword s_option PCSSIZE
syntax keyword s_option PCSPERIOD
syntax keyword s_option PIVREL
syntax keyword s_option PIVTOL
syntax keyword s_option PSOSC
syntax keyword s_option QTRUNC
syntax keyword s_option RATPRINT
syntax keyword s_option RELTOL
syntax keyword s_option RELTRUNC
syntax keyword s_option RELVAR
syntax keyword s_option SAMPLE
syntax keyword s_option SPLITC
syntax keyword s_option STARTSMP
syntax keyword s_option STEP
syntax keyword s_option TIMESMP
syntax keyword s_option TRTOL
syntax keyword s_option TUNING
syntax keyword s_option UNBOUND
syntax keyword s_option VMAX
syntax keyword s_option VMIN
syntax keyword s_option VNTOL
syntax keyword s_option WDB_IDELTA
syntax keyword s_option WDB_VDELTA
syntax keyword s_option WDB_NOSYNCHRO
syntax keyword s_option XA
syntax keyword s_option CPTIME
syntax keyword s_option DEFAULTFALLTIME
syntax keyword s_option DEFAULTRISETIME
syntax keyword s_option DEFPTNOM
syntax keyword s_option DSCGLOB
syntax keyword s_option DSPF_LEVEL
syntax keyword s_option FALL_TIME
syntax keyword s_option FLOATGATE0
syntax keyword s_option FLOATGATECHECK
syntax keyword s_option FLOATGATERR
syntax keyword s_option HIGHVOLTAGE
syntax keyword s_option HIGHVTH
syntax keyword s_option ICDC
syntax keyword s_option ICDEV
syntax keyword s_option INTERP
syntax keyword s_option LICN
syntax keyword s_option LOWVOLTAGE
syntax keyword s_option LOWVTH
syntax keyword s_option M53
syntax keyword s_option MC_IGNORE_BINNING
syntax keyword s_option MMSMOOTH
syntax keyword s_option MMSMOOTHEPS
syntax keyword s_option NOICNODE
syntax keyword s_option NOLICN
syntax keyword s_option NOLTEDISC
syntax keyword s_option NOMEMSTP
syntax keyword s_option PARAMOPT_NOINITIAL
syntax keyword s_option PODEV
syntax keyword s_option RANDMC
syntax keyword s_option RGND
syntax keyword s_option RGNDI
syntax keyword s_option RISE_TIME
syntax keyword s_option SIGTAIL
syntax keyword s_option STATISTICAL
syntax keyword s_option TEMP_UNIT
syntax keyword s_option TNOM
syntax keyword s_option TPIEEE
syntax keyword s_option ULOGIC
syntax keyword s_option ZOOMTIME
syntax keyword s_option DEFAD
syntax keyword s_option DEFAS
syntax keyword s_option DEFL
syntax keyword s_option DEFNRD
syntax keyword s_option DEFNRS
syntax keyword s_option DEFPD
syntax keyword s_option DEFPS
syntax keyword s_option DEFW
syntax keyword s_option ELDOMOS
syntax keyword s_option FNLEV
syntax keyword s_option GMIN
syntax keyword s_option GMIN_BJT_SPICE
syntax keyword s_option GMINDC
syntax keyword s_option GRAMP
syntax keyword s_option GENK
syntax keyword s_option KLIM
syntax keyword s_option KWSCALE
syntax keyword s_option IBIS_SEARCH_PATH
syntax keyword s_option MAXADS
syntax keyword s_option MAXL
syntax keyword s_option MAXPDS
syntax keyword s_option MAXW
syntax keyword s_option MINADS
syntax keyword s_option MINL
syntax keyword s_option MINPDS
syntax keyword s_option MINRACC
syntax keyword s_option MINRESISTANCE
syntax keyword s_option MINRVAL
syntax keyword s_option MINW
syntax keyword s_option MNUMER
syntax keyword s_option MOD4PINS
syntax keyword s_option MODWL
syntax keyword s_option MODWLDOT
syntax keyword s_option NGATEDEF
syntax keyword s_option NOACDERFUNC
syntax keyword s_option NOAUTOCTYPE
syntax keyword s_option NOKWSCALE
syntax keyword s_option NWRMOS
syntax keyword s_option PGATEDEF
syntax keyword s_option RAILINDUCTANCE
syntax keyword s_option RAILRESISTANCE
syntax keyword s_option REDUCE
syntax keyword s_option RESNW
syntax keyword s_option RMMINRVAL
syntax keyword s_option RMOS
syntax keyword s_option RSMALL
syntax keyword s_option RZ
syntax keyword s_option SCALE
syntax keyword s_option SCALEBSIM
syntax keyword s_option SCALM
syntax keyword s_option SHRINK_FACTOR
syntax keyword s_option SOIBACK
syntax keyword s_option SPMODLEV
syntax keyword s_option TMAX
syntax keyword s_option TMIN
syntax keyword s_option USEDEFAP
syntax keyword s_option VBICLEV
syntax keyword s_option WARNING_DEVPARAM
syntax keyword s_option WARNMAXV
syntax keyword s_option WL
syntax keyword s_option YMFACT
syntax keyword s_option ZDETECT
syntax keyword s_option RC_REDUCE
syntax keyword s_option RC_REDUCE_AGGRESSIVENESS
syntax keyword s_option RC_REDUCE_FMAX
syntax keyword s_option RC_REDUCE_METHOD
syntax keyword s_option RC_REDUCE_PORT
syntax keyword s_option RC_REDUCE_KEEP_OUTPUTS
syntax keyword s_option RC_REDUCE_KEEP_NODE
syntax keyword s_option RC_REDUCE_KEEP_INST
syntax keyword s_option RC_REDUCE_MAX_CAP
syntax keyword s_option RC_REDUCE_MAX_IND
syntax keyword s_option RC_REDUCE_MAX_RES
syntax keyword s_option FLICKER_NOISE
syntax keyword s_option IKF2
syntax keyword s_option JTHNOISE
syntax keyword s_option THERMAL_NOISE
syntax keyword s_option NOISE_SGNCONV
syntax keyword s_option NONOISE
syntax keyword s_option DCSIMPROG
syntax keyword s_option ENGNOT
syntax keyword s_option INGOLD
syntax keyword s_option MAXTOTWARN
syntax keyword s_option MAXWARN
syntax keyword s_option MSGBIAS
syntax keyword s_option MSGNODE
syntax keyword s_option NOTRCLIB
syntax keyword s_option NOWARN
syntax keyword s_option NUMDGT
syntax keyword s_option PRINTLG
syntax keyword s_option VERBOSE
syntax keyword s_option WBULK
syntax keyword s_option CAPTAB
syntax keyword s_option CONTINUOUS_FFT
syntax keyword s_option DEFRMSNTR
syntax keyword s_option DISPLAY_CARLO
syntax keyword s_option DUMP_EXTRACT
syntax keyword s_option DUMP_MCINFO
syntax keyword s_option EXTCGS
syntax keyword s_option EXTFILE
syntax keyword s_option EXTMKSA
syntax keyword s_option EXTRACT_VECT_AXIS
syntax keyword s_option HISTLIM
syntax keyword s_option HISTO_ZERO
syntax keyword s_option INPUT
syntax keyword s_option INFOMC
syntax keyword s_option JWDB_ACTRAN_USE_TIME
syntax keyword s_option JWDB_EVENT
syntax keyword s_option JWDB_EXTENSIONS
syntax keyword s_option JWDB_PERCENT
syntax keyword s_option KEEP_DSPF_NODE
syntax keyword s_option KEEP_HMPFILE
syntax keyword s_option LCAPOP
syntax keyword s_option LIMPROBE
syntax keyword s_option LIST
syntax keyword s_option MAX_CHECKBUS
syntax keyword s_option MAX_DSPF_PLOT
syntax keyword s_option MC_NOMINAL_OP
syntax keyword s_option MEASFILE
syntax keyword s_option NEWACCT
syntax keyword s_option NOASCII
syntax keyword s_option NOASCIIPLOT
syntax keyword s_option NOBOUND_PHASE
syntax keyword s_option NODCINFOTAB
syntax keyword s_option NODE
syntax keyword s_option NODEFRMSNTR
syntax keyword s_option NOEXTRACTCOMPLEX
syntax keyword s_option NOMOD
syntax keyword s_option NOOP
syntax keyword s_option NOPAGE
syntax keyword s_option NOSIZECHK
syntax keyword s_option NOSMKMCWC
syntax keyword s_option NOSTATP
syntax keyword s_option NOTRC
syntax keyword s_option NOWAVECOMPLEX
syntax keyword s_option NOXTABNOISE
syntax keyword s_option OPTYP
syntax keyword s_option OUT_RESOL
syntax keyword s_option OUT_SMP
syntax keyword s_option OUT_STEP
syntax keyword s_option PARAMETRIC_ACTRAN
syntax keyword s_option POST
syntax keyword s_option PRINT_ACOP
syntax keyword s_option PRINTFILE_STEP
syntax keyword s_option PRINTFILE_FREQ_STEP
syntax keyword s_option PRINTFILE_TIME_STEP
syntax keyword s_option SIMUDIV
syntax keyword s_option STAT
syntax keyword s_option TEMPCOUK
syntax keyword s_option TIMEDIV
syntax keyword s_option VBCSAT
syntax keyword s_option VXPROBE
syntax keyword s_option WRITE_ALTER_NETLIST
syntax keyword s_option OPSELDO_ABSTRACT
syntax keyword s_option OPSELDO_DETAIL
syntax keyword s_option OPSELDO_DISPLAY_GOALFITTING
syntax keyword s_option OPSELDO_FORCE_GOALFITTING
syntax keyword s_option OPSELDO_JWDB_RUN
syntax keyword s_option OPSELDO_NETLIST
syntax keyword s_option OPSELDO_NO_DUPLICATE
syntax keyword s_option OPSELDO_NOGOALFITTING
syntax keyword s_option OPSELDO_OUTER
syntax keyword s_option OPSELDO_OUTPUT
syntax keyword s_option RESET_MULTIPLE_RUN
syntax keyword s_option COU
syntax keyword s_option CSDF
syntax keyword s_option FSDB
syntax keyword s_option FSDB_SINGLE_FILE
syntax keyword s_option INFODEV
syntax keyword s_option INFOMOD
syntax keyword s_option ISDB
syntax keyword s_option ITRPRT
syntax keyword s_option JWDB
syntax keyword s_option NOAEX
syntax keyword s_option NOCKRSTSAVE
syntax keyword s_option NOCOU
syntax keyword s_option NOIICXNAME
syntax keyword s_option NOJWDB
syntax keyword s_option NOPROBEOP
syntax keyword s_option OUT_ABSTOL
syntax keyword s_option OUT_REDUCE
syntax keyword s_option OUT_RELTOL
syntax keyword s_option PROBE
syntax keyword s_option PROBEOP
syntax keyword s_option PROBEOP2
syntax keyword s_option PROBEOPX
syntax keyword s_option PSF
syntax keyword s_option PSF_ALL_FILES
syntax keyword s_option PSF_FULLNAME
syntax keyword s_option PSF_NODEVICE_NOISE
syntax keyword s_option PSF_VERSION
syntax keyword s_option PSF_WRITE_ALL
syntax keyword s_option PSFASCII
syntax keyword s_option SAVETIME
syntax keyword s_option CSHUNT
syntax keyword s_option DCPART
syntax keyword s_option DIGITAL
syntax keyword s_option DPTRAN
syntax keyword s_option GEAR
syntax keyword s_option GNODE
syntax keyword s_option GSHUNT
syntax keyword s_option MAXORD
syntax keyword s_option NODCPART
syntax keyword s_option NODEFNEWTON
syntax keyword s_option NORMOS
syntax keyword s_option OSR
syntax keyword s_option PSTRAN
syntax keyword s_option SMOOTH
syntax keyword s_option TRAP
syntax keyword s_option D2DMVL9BIT
syntax keyword s_option DEFA2D
syntax keyword s_option DEFD2A
syntax keyword s_option DEFCONVMSG
syntax keyword s_option DYND2ALOG
syntax keyword s_option DYND2ALOG2
syntax keyword s_option FS_SOLVE_AMS_NODES
syntax keyword s_option FS_PARTITIONING
syntax keyword s_option FS_PARTITION_DEBUG
syntax keyword s_option MIXEDSTEP
syntax keyword s_option NO_FS_VA
syntax keyword s_option PARTGATE_AMS_ALL
syntax keyword s_option PARTVDD
syntax keyword s_option PARTVDD_AMS_ALL
syntax keyword s_option CTEPREC
syntax keyword s_option DCLOG
syntax keyword s_option EPSO
syntax keyword s_option MAXNODEORD
syntax keyword s_option NODUPINSTERR
syntax keyword s_option NOELDOSWITCH
syntax keyword s_option NOFNSIEM
syntax keyword s_option NOINIT
syntax keyword s_option SEARCH
syntax keyword s_option VAMAXEXP
syntax keyword s_option ZCHAR


"COMMANDS OPTIONS & ARGUMENTS : ELDO RF

syntax keyword s_option AUTOSTOP
syntax keyword s_option FOUR_SOURCE_DELAY
syntax keyword s_option IMPROVED_SSTNOISE_PERF
syntax keyword s_option MODSST_EPS
syntax keyword s_option MODSST_CENTRAL_FUND_OSCxx
syntax keyword s_option MODSST_FULL_DISPLAY
syntax keyword s_option MODSST_FFT_FUND_FREQ
syntax keyword s_option MODSST_FFT_NHARM
syntax keyword s_option MODSST_FFT_TSTART
syntax keyword s_option MODSST_FULL_DISPLAY_FORCED
syntax keyword s_option MODSST_HMAX
syntax keyword s_option MODSST_HMIN
syntax keyword s_option MODSST_USE_AVERAGE_FUND_OSC
syntax keyword s_option NO_SST
syntax keyword s_option RF_PARTITIONING_MODE
syntax keyword s_option RF_PARTITIONING_THRESHOLD
syntax keyword s_option SST_ABSTOL
syntax keyword s_option SST_ACCURACY
syntax keyword s_option SST_AT_TIME
syntax keyword s_option SST_CIRCUIT_TYPE
syntax keyword s_option SST_CONVERGENCE_HELP
syntax keyword s_option SST_ESTIM_ACCURACY
syntax keyword s_option SST_F0_ABSTOL
syntax keyword s_option SST_F0_RELTOL
syntax keyword s_option SST_FULL_DISPLAY
syntax keyword s_option SST_KEEP_OPTIONS_FOR_SWEEP
syntax keyword s_option SST_MAX_LINITER
syntax keyword s_option SST_MEMESTIM
syntax keyword s_option SST_MEMORY_COMPRESS
syntax keyword s_option SST_MTHREAD
syntax keyword s_option SST_NBTHREAD
syntax keyword s_option SST_NDIM_FFT
syntax keyword s_option SST_NODIVERGENCE
syntax keyword s_option SST_NOLIMIT_LINITER
syntax keyword s_option SST_NPER
syntax keyword s_option SST_NPT
syntax keyword s_option SST_NTONE_PROCEDURE_IFUND_FOR_
syntax keyword s_option RESTART
syntax keyword s_option SST_OSC_KEEP_PHASE_SEQUENCE
syntax keyword s_option SST_OSC_PHASE_SEQUENCE SST_OVRSMP
syntax keyword s_option SST_PHNOISE_SPEED SST_PLL_VCO_WITH_GLOBAL_SPECTRUM
syntax keyword s_option SST_PRECONDITION
syntax keyword s_option SST_RAMPING_FACTOR
syntax keyword s_option SST_RESTART
syntax keyword s_option SST_SPECTRUM
syntax keyword s_option SST_T0HF
syntax keyword s_option SST_TOT_TIME_POINTS_LIMIT
syntax keyword s_option SST_TRAN_NPER
syntax keyword s_option SST_TSTART
syntax keyword s_option SST_TSTOP
syntax keyword s_option SST_UIC
syntax keyword s_option SST_USE_NTONE_PROCEDURE
syntax keyword s_option SST_VERBOSE
syntax keyword s_option SSTNLCONTRIB_FILE
syntax keyword s_option SSTNOISE_CONTRIB_TYPE
syntax keyword s_option SSTNOISE_EXCLUDE_DEVICES
syntax keyword s_option SSTNOISE_FILE
syntax keyword s_option SSTNOISE_GLOBPART
syntax keyword s_option SSTNOISE_INCLUDE_DEVICES
syntax keyword s_option SSTNOISE_SORT_ABS
syntax keyword s_option SSTNOISE_SORT_CRITER
syntax keyword s_option SSTNOISE_SORT_NBMAX
syntax keyword s_option SSTNOISE_SORT_REL
syntax keyword s_option SSTSENSRLC_FILE
syntax keyword s_option TUNING

" Notes perso
syntax keyword s_option DC
syntax keyword s_option AC
syntax keyword s_option FOUR
syntax keyword s_option MA
syntax keyword s_option PHNOISE
syntax keyword s_option PHN_FLOOR
syntax keyword s_option PHN_CORNER
syntax keyword s_option PHN_LEVEL
syntax keyword s_option PHN_SLOPE
syntax keyword s_option NOISE
syntax keyword s_option TABLE
syntax keyword s_option INTREP
syntax keyword s_option RPORT
syntax keyword s_option IPORT

syntax keyword s_option incr
syntax keyword s_option dec
syntax keyword s_option lin

syntax keyword s_option tran
syntax keyword s_option tsst
syntax keyword s_option fsst
syntax keyword s_option sstac
syntax keyword s_option sstxf
syntax keyword s_option sstnoise
syntax keyword s_option label
syntax keyword s_option param

syntax keyword s_operator DB
syntax keyword s_operator SPHI
syntax keyword s_operator SPHI_SSB
syntax keyword s_operator SPHI_SSB_THERMAL
syntax keyword s_operator SPHI_SSB_FLICKER
syntax keyword s_operator SPHI_VCO
syntax keyword s_operator SPHI_PFD
syntax keyword s_operator SPHI_DIV

syntax keyword s_operator ONOISE
syntax keyword s_operator INOISE

syntax keyword s_operator D_WA
syntax keyword s_operator DTC
syntax keyword s_operator SLEWRATE
syntax keyword s_operator TCROSS
syntax keyword s_operator TINTEG
syntax keyword s_operator TPD
syntax keyword s_operator TPDUU
syntax keyword s_operator TPDUD
syntax keyword s_operator TPDDU
syntax keyword s_operator TPDDD
syntax keyword s_operator TPERIOD
syntax keyword s_operator TRISE
syntax keyword s_operator TFALL
syntax keyword s_operator VALAT
syntax keyword s_operator AVERAGE
syntax keyword s_operator COMPRESS
syntax keyword s_operator CROSSING
syntax keyword s_operator DCM
syntax keyword s_operator DISTO
syntax keyword s_operator EVAL
syntax keyword s_operator FAIL
syntax keyword s_operator FALLING
syntax keyword s_operator INTEG
syntax keyword s_operator KFACTOR
syntax keyword s_operator LOCAL_MAX
syntax keyword s_operator LOCAL_MIN
syntax keyword s_operator MAXGMVT
syntax keyword s_operator MAX
syntax keyword s_operator MEAN
syntax keyword s_operator MIN
syntax keyword s_operator MODPAR
syntax keyword s_operator OPMODE
syntax keyword s_operator PASS
syntax keyword s_operator PVAL
syntax keyword s_operator RISING
syntax keyword s_operator RMS
syntax keyword s_operator SLOPE
syntax keyword s_operator VDSATC
syntax keyword s_operator VTC
syntax keyword s_operator WFREQ
syntax keyword s_operator WINTEG
syntax keyword s_operator XCOMPRESS
syntax keyword s_operator XDOWN
syntax keyword s_operator XMAX
syntax keyword s_operator XMIN
syntax keyword s_operator XTHRES
syntax keyword s_operator XUP
syntax keyword s_operator XYCOND
syntax keyword s_operator YVAL
syntax keyword s_operator SQRT
syntax keyword s_operator LOG
syntax keyword s_operator LOG10
syntax keyword s_operator DB
syntax keyword s_operator EXP
syntax keyword s_operator COS
syntax keyword s_operator SIN
syntax keyword s_operator TAN
syntax keyword s_operator ACOS
syntax keyword s_operator ASIN
syntax keyword s_operator ATAN
syntax keyword s_operator COSH
syntax keyword s_operator SINH
syntax keyword s_operator TANH
syntax keyword s_operator SGN
syntax keyword s_operator SIGN
syntax keyword s_operator SIGN
syntax keyword s_operator PWR
syntax keyword s_operator POW
syntax keyword s_operator ABS
syntax keyword s_operator INT
syntax keyword s_operator TRUNC
syntax keyword s_operator ROUND
syntax keyword s_operator CEIL
syntax keyword s_operator FLOOR
syntax keyword s_operator DMIN
syntax keyword s_operator DMAX
syntax keyword s_operator DERIV
syntax keyword s_operator REAL
syntax keyword s_operator IMAG
syntax keyword s_operator MAGNITUDE
syntax keyword s_operator CONJ
syntax keyword s_operator COMPLEX


" Definition des devices dans eldo :
" Commence par Cxx Dxx Exx ... etc
syntax match s_device "^[CDEGIJKLMPQRSTUVWXY]\S*[ ]"

" Numbers, all with engineering suffixes and optional units
"floating point number, with dot, optional exponent
syn match s_number  "\<[0-9]\+\.[0-9]*\(e[-+]\=[0-9]\+\)\=\(meg\=\|[afpnumkg]\)\="
"floating point number, starting with a dot, optional exponent
syn match s_number  "\.[0-9]\+\(e[-+]\=[0-9]\+\)\=\(meg\=\|[afpnumkg]\)\="
"integer number with optional exponent
syn match s_number  "\<[0-9]\+\(e[-+]\=[0-9]\+\)\=\(meg\=\|[afpnumkg]\)\="



"highlight link s_comment ignore
"highlight link s_ckt structure
"highlight link s_cmd function
"highlight link s_device comment
"highlight link s_option type 
"highlight link s_number number
"highlight link s_operator macro

highlight s_comment ctermfg=242
highlight s_ckt ctermfg=28
highlight s_cmd ctermfg=14 cterm=bold
highlight s_device ctermfg=32 cterm=bold
highlight s_option ctermfg=176 
highlight s_number ctermfg=185
highlight s_operator ctermfg=140


"""" Liste des types prédéfinis
"Comment
"Constant
"String
"Character
"Number
"Boolean
"Float
"Identifier
"Function
"Statement
"Conditional
"Repeat
"Label
"Operator
"Keyword
"Exception
"PreProc
"Include
"Define
"Macro
"PreCondit
"Type
"StorageClass
"Structure
"Typedef
"Special
"SpecialChar
"Tag
"Delimiter
"SpecialComment
"Debug
"Underlined
"Ignore
"Error
"Todo
