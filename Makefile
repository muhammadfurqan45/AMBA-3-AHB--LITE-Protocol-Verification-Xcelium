# note: '\' means newline of same command

##TB_INPUT = tb_AR_FV.v

TB_INPUT = top.sv

default: PAR 

#=============== Place+Route: ===================#

# PARzero should almost always work.
# PAR runs with typical delay model

PARzero:
	xrun $(TB_INPUT) +ncaccess+r +nc64bit +delay_mode_zero +v2k -l PARzero.log &

PARnoTime:
	ncvrilog $(TB_INPUT) +ncaccess+r +nc64bit +notimingcheck +v2k -l PARzero.log &

PAR: 

	xrun $(TB_INPUT) +access+r -64bit -l PAR.log &


