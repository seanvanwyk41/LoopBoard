	system u0 (
		.clk_clk             (<connected-to-clk_clk>),             //        clk.clk
		.reset_n_reset_n     (<connected-to-reset_n_reset_n>),     //    reset_n.reset_n
		.sdram_address       (<connected-to-sdram_address>),       //      sdram.address
		.sdram_byteenable_n  (<connected-to-sdram_byteenable_n>),  //           .byteenable_n
		.sdram_chipselect    (<connected-to-sdram_chipselect>),    //           .chipselect
		.sdram_writedata     (<connected-to-sdram_writedata>),     //           .writedata
		.sdram_read_n        (<connected-to-sdram_read_n>),        //           .read_n
		.sdram_write_n       (<connected-to-sdram_write_n>),       //           .write_n
		.sdram_readdata      (<connected-to-sdram_readdata>),      //           .readdata
		.sdram_readdatavalid (<connected-to-sdram_readdatavalid>), //           .readdatavalid
		.sdram_waitrequest   (<connected-to-sdram_waitrequest>),   //           .waitrequest
		.sdram_wire_addr     (<connected-to-sdram_wire_addr>),     // sdram_wire.addr
		.sdram_wire_ba       (<connected-to-sdram_wire_ba>),       //           .ba
		.sdram_wire_cas_n    (<connected-to-sdram_wire_cas_n>),    //           .cas_n
		.sdram_wire_cke      (<connected-to-sdram_wire_cke>),      //           .cke
		.sdram_wire_cs_n     (<connected-to-sdram_wire_cs_n>),     //           .cs_n
		.sdram_wire_dq       (<connected-to-sdram_wire_dq>),       //           .dq
		.sdram_wire_dqm      (<connected-to-sdram_wire_dqm>),      //           .dqm
		.sdram_wire_ras_n    (<connected-to-sdram_wire_ras_n>),    //           .ras_n
		.sdram_wire_we_n     (<connected-to-sdram_wire_we_n>)      //           .we_n
	);

