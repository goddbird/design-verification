// I2C UVM integration file
// Use this file as a compile entry point.

// Common components
`include "i2c_transaction.sv"
`include "i2c_monitor.sv"
`include "i2c_predictor.sv"
`include "i2c_env.sv"

// Driver selection (choose one)
`include "i2c_driver_clock_stretch.sv"
// `include "i2c_driver_basic.sv"

// Scoreboard selection (choose one)
`include "i2c_scoreboard_fifo.sv"
// `include "i2c_scoreboard_analysis_imp.sv"
