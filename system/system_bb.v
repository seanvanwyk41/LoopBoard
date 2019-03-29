
module system (
	clk_clk,
	reset_n_reset_n,
	sdram_address,
	sdram_byteenable_n,
	sdram_chipselect,
	sdram_writedata,
	sdram_read_n,
	sdram_write_n,
	sdram_readdata,
	sdram_readdatavalid,
	sdram_waitrequest,
	sdram_wire_addr,
	sdram_wire_ba,
	sdram_wire_cas_n,
	sdram_wire_cke,
	sdram_wire_cs_n,
	sdram_wire_dq,
	sdram_wire_dqm,
	sdram_wire_ras_n,
	sdram_wire_we_n);	

	input		clk_clk;
	input		reset_n_reset_n;
	input	[24:0]	sdram_address;
	input	[3:0]	sdram_byteenable_n;
	input		sdram_chipselect;
	input	[31:0]	sdram_writedata;
	input		sdram_read_n;
	input		sdram_write_n;
	output	[31:0]	sdram_readdata;
	output		sdram_readdatavalid;
	output		sdram_waitrequest;
	output	[12:0]	sdram_wire_addr;
	output	[1:0]	sdram_wire_ba;
	output		sdram_wire_cas_n;
	output		sdram_wire_cke;
	output		sdram_wire_cs_n;
	inout	[31:0]	sdram_wire_dq;
	output	[3:0]	sdram_wire_dqm;
	output		sdram_wire_ras_n;
	output		sdram_wire_we_n;
endmodule
