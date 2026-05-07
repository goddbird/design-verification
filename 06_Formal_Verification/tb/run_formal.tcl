clear -all
analyze -sv ../rtl/fifo.sv
elaborate -top fifo
clock CLK
reset -expression {RESETn == 0}
prove -all