* spice tbench
.include models_hdl
.include osc.cir
.include tbench.cir

vddgo1 dvddgo1 0 dc 1.5
vss dvss 0 dc 0
vid_en id_en 0 pwl 0 0 10n 0 10.1n 1.5

* Command file 
.INCLUDE adms.converters
.option search = /nfs/work-crypt/ic/common/altis/1.2.2/eldo/models/
.option search = /nfs/work-crypt/ic/usr/aferret/altis/simulation/include
.lib include.inc common

.lib include.inc mostyp
.lib include.inc btyp
.lib include.inc rtyp
.lib include.inc ctyp


.tran 0.5u 0.5u 
.end
