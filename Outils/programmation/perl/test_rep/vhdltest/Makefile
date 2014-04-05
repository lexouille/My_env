WORK=${WORK_DIR}/osc_work
LIB_NAME=work
SRC_DIR=/nfs/work-crypt/ic/usr/aferret/altis/simulation/osc/eldoD/schematic/netlist/model

all: ${WORK}/${LIB_NAME}/${LIB_NAME}.analog.done 

${WORK}/${LIB_NAME}/${LIB_NAME}.analog.done:${SRC_DIR}/osc_spice.v ${SRC_DIR}/osc.cir ${SRC_DIR}/osc.vhd 
	@mkdir -p ${WORK}
	cd ${WORK} && cp ${SRC_DIR}/tbench.cmd .
	cd ${WORK} && cp ${SRC_DIR}/osc.cir .
	cd ${WORK} && cp ${SRC_DIR}/tbench.cir .
	cd ${WORK} && cp ${SRC_DIR}/adms.converters .
	cd ${WORK} && cp ${SRC_DIR}/models_hdl .
	cd ${WORK} && ( test -d ${LIB_NAME} || valib ${LIB_NAME} )
	cd ${WORK} && vacom -work ${LIB_NAME} ${SRC_DIR}/osc.vhd
	#cd ${WORK} && valog -work ${LIB_NAME} ${SRC_DIR}/osc_spice.v -ms
	#cd ${WORK} && vlog -work ${LIB_NAME} ${SRC_DIR}/tbench.v
	#cd ${WORK} && vaspi -work ${LIB_NAME} osc_spice osc@${SRC_DIR}/osc.cir
	cd ${WORK} && vasim -cmd tbench.cmd -ms +notimingchecks -t ps
	@touch $@
clean:
	@rm -rf ${WORK}/${LIB_NAME}

