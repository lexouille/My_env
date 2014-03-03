******** Netlist associée

**/nfs/work/hardware/users/aferret/virtualbox/eldo/vco_carac.cir


******** DIVERS

.connect VSS 0

.connect SUB 0

**MODELS
*.include /work1/users/mbely/share/public/models/models_28_TT
.lib key=MOS '/work2/hardware/technologie/tsmc/28nm/PDK/HPL/k17/models/eldo/cln28hp_1d8_elk_v1d0_2p1_shrink0d9_embedded_usage.eldo' TTMacro_MOS_MOSCAP
.lib key=RES '/work2/hardware/technologie/tsmc/28nm/PDK/HPL/k17/models/eldo/cln28hp_1d8_elk_v1d0_2p1_shrink0d9_embedded_usage.eldo' TT_RES_BIP_DIO_DISRES


**MPRUNS
*.mprun host={mestor(8)} USE_LOCAL_HOST=no USE_SSH=YES
*.mprun host={acteon(4)} USE_LOCAL_HOST=no USE_SSH=YES
*.mprun host={patathor(10)} USE_LOCAL_HOST=no USE_SSH=YES
*.mprun host={artemis(8)} USE_LOCAL_HOST=no USE_SSH=YES

*.option nocatmx **Pas de merge des devices en parallele


**remplacements par les extracts

* include fichiers d'extraction

*changement subckt vco_v1, commenter le .subckt dans la liste
.include /nfs/work/hardware/users/aferret/virtualbox/Calibre/PEX/vco_v1.ext.dio.cc.redux.typ

*changement subckt b_vco_1, commenter le .subckt dans la liste
*.include /nfs/work/hardware/users/aferret/virtualbox/Calibre/PEX/b_vco_1.ext.dio.cc.typ


******** CONDITIONS INITIALES

.ic v(outp1)=0.85 v(outn1)=0


******** PARAMETRES

.param alim1=0.85
.param code=1
.param code_bias=1
.param nc=3000
.param wr=0.5u lr=5u

******** ANALYSES

** STEP

*.step param alim1 list 0.765 0.8075 0.85 0.8925 0.935
*.temp -30 45 125
.step param code_bias list 0 1 2 3
*.step param c list 100f 200f 300f 400f 500f 600f 700f 800f
*.step param (nc lr) list (4500 5u) (4500 10u) (4500 15u) (4500 20u) (3000 10u) (3000 15u)
*.step param (wr lr) list (1u 10u) (0.8u 8u) (0.6u 6u) (0.4u 4u)
.step param code list 0 8191
*.step param code list 0 1 2 3 4 5 6 7 8184 8185 8186 8187 8188 8189 8190 8191
*.step param code list file=/work/hardware/users/aferret/virtualbox/include/the.data


**** EXTRACT

*.extract tran label=duty_cycle_vco DTC(v(inp3,inn3), VTH=0, after=8n)
.extract tran label=duty_cycle_Dbuff DTC(v(outp1,outn1), VTH=0, after=8n)
.extract tran label=duty_cycle_buff DTC(v(outpb,outnb), VTH=0, after=8n)
.extract tran label=duty_cycle_buff_se DTC(v(outpb), VTH=alim1/2, after=8n)
*.EXTRACT tran label=fosc_vco WFREQ(v(inp3,inn3), 8n, 12n)
.EXTRACT tran label=fosc_buff WFREQ(v(outpb,outnb), 8n, 12n)

.EXTRACT FSST LABEL=FOSC1 FUND_OSC1
.extract tsst label=conso_tsst abs(average(I(VV1)))

.extract sstnoise label=noise1meg yval(DB(SPHI_SSB),1e6)

*.extract fsst label=KVCO deriv(extract(FOSC1))


**** PLOT
.plot tran v(outn1) v(outp1) v(outnb) v(outpb) v(outp1, outn1) v(outpb, outnb) v(inni) v(inpi)
.plotbus VFILT<12:0>
.plotbus VB<1:0>

.plot tran ix(RR1.INPI)

.plot tsst v(outn1) v(outp1) v(outnb) v(outpb) v(outp1, outn1) v(outpb, outnb)

.PLOT SSTNOISE DB(SPHI_SSB) DB(SPHI_SSB_THERMAL) DB(SPHI_SSB_FLICKER)

******** SIMULATIONS

.tran 12n 12n

.SST OSCIL NHARM_OSC1=10
.SSTNOISE V(outpb, outnb) DEC 3 1e4 1e8
.SSTPROBE outn1 outp1 FUND_OSC1
.option sst_accuracy=high
.OPTION SST_PHNOISE_SPEED=standard SSTNOISE_GLOBPART=0
.option SST_OSC_PHASE_SEQUENCE=seq_4

.option hmax=1p eps=1e-6
.option be

**** CORNERS
*.alter FF
*.lib key=MOS '/work2/hardware/technologie/tsmc/28nm/PDK/HPL/k17/models/eldo/cln28hp_1d8_elk_v1d0_2p1_shrink0d9_embedded_usage.eldo' FFMacro_MOS_MOSCAP
*.lib key=RES '/work2/hardware/technologie/tsmc/28nm/PDK/HPL/k17/models/eldo/cln28hp_1d8_elk_v1d0_2p1_shrink0d9_embedded_usage.eldo' FF_RES_BIP_DIO_DISRES
*.end
*.alter SS
*.lib key=MOS '/work2/hardware/technologie/tsmc/28nm/PDK/HPL/k17/models/eldo/cln28hp_1d8_elk_v1d0_2p1_shrink0d9_embedded_usage.eldo' SSMacro_MOS_MOSCAP
*.lib key=RES '/work2/hardware/technologie/tsmc/28nm/PDK/HPL/k17/models/eldo/cln28hp_1d8_elk_v1d0_2p1_shrink0d9_embedded_usage.eldo' SS_RES_BIP_DIO_DISRES
*.end
*.alter FS
*.lib key=MOS '/work2/hardware/technologie/tsmc/28nm/PDK/HPL/k17/models/eldo/cln28hp_1d8_elk_v1d0_2p1_shrink0d9_embedded_usage.eldo' FSMacro_MOS_MOSCAP
*.lib key=RES '/work2/hardware/technologie/tsmc/28nm/PDK/HPL/k17/models/eldo/cln28hp_1d8_elk_v1d0_2p1_shrink0d9_embedded_usage.eldo' FS_RES_BIP_DIO_DISRES
*.end
*.alter SF
*.lib key=MOS '/work2/hardware/technologie/tsmc/28nm/PDK/HPL/k17/models/eldo/cln28hp_1d8_elk_v1d0_2p1_shrink0d9_embedded_usage.eldo' SFMacro_MOS_MOSCAP
*.lib key=RES '/work2/hardware/technologie/tsmc/28nm/PDK/HPL/k17/models/eldo/cln28hp_1d8_elk_v1d0_2p1_shrink0d9_embedded_usage.eldo' SF_RES_BIP_DIO_DISRES
*.end

*pour ne voir les variations que sur les mos et les moscap
*.alter SSmos
*.lib key=MOS '/work2/hardware/technologie/tsmc/28nm/PDK/HP/current/models/v1d0_2p1/eldo/cln28hp_1d8_elk_v1d0_2p1_shrink0d9_embedded_usage.eldo' SSMacro_MOS_MOSCAP
*.end
*.alter FFmos
*.lib key=MOS '/work2/hardware/technologie/tsmc/28nm/PDK/HP/current/models/v1d0_2p1/eldo/cln28hp_1d8_elk_v1d0_2p1_shrink0d9_embedded_usage.eldo' FFMacro_MOS_MOSCAP
*.end

**** Monte carlo
*.alter MC
*.lib key=MOS '/work2/hardware/technologie/tsmc/28nm/PDK/HP/current/models/v1d0_2p2/eldo/cln28hp_1d8_elk_v1d0_2p2_shrink0d9_embedded_usage.eldo' GlobalMC_LocalMC_MOS_MOSCAP
*.lib key=RES '/work2/hardware/technologie/tsmc/28nm/PDK/HP/current/models/v1d0_2p2/eldo/cln28hp_1d8_elk_v1d0_2p2_shrink0d9_embedded_usage.eldo' GlobalMC_LocalMC_RES_BIP_DIO_DISRES
*.MC 300 ALL nbbins=20
*.end
*.alter TT_MC
*.lib key=MOS '/work2/hardware/technologie/tsmc/28nm/PDK/HP/current/models/v1d0_2p2/eldo/cln28hp_1d8_elk_v1d0_2p2_shrink0d9_embedded_usage.eldo' TTGlobalCorner_LocalMC_MOS_MOSCAP
*.lib key=RES '/work2/hardware/technologie/tsmc/28nm/PDK/HP/current/models/v1d0_2p2/eldo/cln28hp_1d8_elk_v1d0_2p2_shrink0d9_embedded_usage.eldo' TT_RES_BIP_DIO_DISRES
*.MC 16 ALL nbbins=10
*.end
