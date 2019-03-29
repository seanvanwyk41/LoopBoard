
module Project2 (
	// Inputs
	CLOCK_50,
	CLOCK_27,
	KEY,

	AUD_ADCDAT,

	// Bidirectionals
	AUD_BCLK,
	AUD_ADCLRCK,
	AUD_DACLRCK,

	I2C_SDAT,

	// Outputs
	AUD_XCK,
	AUD_DACDAT,
	HEX0,
	HEX1,
	HEX2,
	HEX3,
	HEX4,
	HEX5,
	HEX6,
	HEX7,
	I2C_SCLK,
	SW,
	LEDR,
	// Dram connections
	DRAM_CLK,
	DRAM_CKE,
	DRAM_ADDR,
	DRAM_BA,
	DRAM_CS_N,
	DRAM_CAS_N,
	DRAM_RAS_N,
	DRAM_WE_N,
	DRAM_DQ,
	DRAM_DQM);

	// SDRAM MASTER STUFF

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// SDRAM  interface stuff

output [12:0] DRAM_ADDR;
output [1:0] DRAM_BA;
output DRAM_CAS_N, DRAM_RAS_N, DRAM_CLK;
output DRAM_CKE, DRAM_CS_N, DRAM_WE_N;
output [3:0] DRAM_DQM;
inout [31:0] DRAM_DQ;

// Inputs
input				CLOCK_50;
input				CLOCK_27;
input		[3:0]	KEY;
input		[17:0]	SW;

input				AUD_ADCDAT;

// Bidirectionals
inout				AUD_BCLK;
inout				AUD_ADCLRCK;
inout				AUD_DACLRCK;

inout				I2C_SDAT;

// Outputs
output				AUD_XCK;
output				AUD_DACDAT;
output [6:0] HEX0;
output [6:0] HEX1;
output [6:0] HEX2;
output [6:0] HEX3;
output [6:0] HEX4;
output [6:0] HEX5;
output [6:0] HEX6;
output [6:0] HEX7;
output I2C_SCLK;
output [17:0] LEDR;
 
/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
// Internal Wires
wire					audio_in_available;
wire		[31:0]	left_channel_audio_in;
wire		[31:0]	right_channel_audio_in;
wire					read_audio_in;

wire					audio_out_allowed;
wire		[31:0]	left_channel_audio_out;
wire		[31:0]	right_channel_audio_out;
wire					write_audio_out;

// SDRAM STUFF
wire 					reset;
wire 					record;
wire 					play;

wire 		[24:0]	address;

wire 		[31:0] 	writedata;
wire 		[31:0] 	readdata;

// Internal Registers

reg [18:0] delay_cnt, delay;
reg snd;



/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/
// Assignments
assign reset = KEY[3];
assign play = SW[17];
assign LEDR[1] = reset;
assign LEDR[2] = play;
assign LEDR[3] = record;

 

// This is important I think
assign read_audio_in	= audio_in_available & audio_out_allowed;
assign write_audio_out = audio_in_available & audio_out_allowed;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/
wire [31:0] left_audio_cccor_out;
wire [31:0] right_audio_cccor_out;
wire [31:0] left_audio_filters_out;
wire [31:0] right_audio_filters_out;
wire [31:0] left_audio_volume_out;
wire [31:0] right_audio_volume_out;
wire [1:0] volume_display;

wire [3:0] count0;
wire [3:0] count1;
wire [3:0] count2;
wire [3:0] count3;

// hex display settings
hex_display h7(0,HEX7);
hex_display h0(0,HEX6);
hex_display h6(volume_display,HEX5);
hex_display h5(0,HEX4);
hex_display h4(count3,HEX3);
hex_display h3(count2,HEX2);
hex_display h2(count1,HEX1);
hex_display h1(count0,HEX0);

// Filter Controller
AllFilters filters(
	.left_channel_audio_in(left_channel_audio_in),
	.right_channel_audio_in(right_channel_audio_in),
	.filter_choice(SW[6:5]),
	.reset(reset),
	.AUD_BCLK(AUD_BCLK),
	.AUD_ADCLRCK(AUD_ADCLRCK),
	.AUD_DACLRCK(AUD_DACLRCK),
	.left_channel_audio_out(left_audio_filters_out),
	.right_channel_audio_out(right_audio_filters_out)
);

// Cutoff controller 
CutOffCutOnRepeat cccor(
	.left_channel_audio_in(left_audio_filters_out),
	.right_channel_audio_in(right_audio_filters_out),
	.interval_time(SW[8:7]),
	.CLOCK_50(CLOCK_50),
	.left_channel_audio_out(left_audio_cccor_out),
	.right_channel_audio_out(right_audio_cccor_out)
);

// Volume Controller
AudioVolume volume(
	.left_channel_audio_in(left_audio_cccor_out),
	.right_channel_audio_in(right_audio_cccor_out),
	.level(SW[11:10]),
	.clock(CLOCK_50),
	.left_channel_audio_out(left_audio_volume_out),
	.right_channel_audio_out(right_audio_volume_out),
	.volume(volume_display)
);
 
// Loop controllers
loop l0 (			
.aud_clk						(AUD_ADCLRCK),						// in 		:Audio clock set to 48 Khz
.clk							(CLOCK_50),						// in			:System clock set to 50 Mhz
.readdata					(readdata),						// in [31:0]:Read data from sdram
.record						(SW[16]),
.left_channel_audio_in	(left_audio_volume_out),		// in [31:0]:Left audio channel in
.right_channel_audio_in	(right_audio_volume_out),	// in [31:0]:Right channel audio in
.reset						(reset),							// in			:Async Reset
.channel						(SW[3:0]),							// in [3:0]	:4 way channel Select
.play							(play),							// in 		:Play read audio
.address_out				(address),						// out[24:0]:Address to save audio to sram
.writedata					(writedata),					// out[31:0]:Data to save on sram
.write_en					(record),						// out		: whether or not to write to sdram
.left_channel_audio_out	(left_channel_audio_out),	// out[31:0]:Left channel audio out
.right_channel_audio_out(right_channel_audio_out),	// out[31:0]:Right channel audio out
.count0						(count0),						// out 		:counter for the 0th channel
.count1						(count1),						// out 		:counter for the 1st channel
.count2						(count2),						// out 		:counter for the 2nd channel
.count3						(count3)							// out 		:counter for the 3rd channel
);				
 
// Sdram module
system u0 (
	.clk_clk             (CLOCK_50),       //        clk.clk
	.reset_n_reset_n     (reset),     		//    reset_n.reset_n
	.sdram_address       (address),       	//      sdram.address
	.sdram_byteenable_n  (4'b0000),  		//           .byteenable_n
	.sdram_chipselect    (1'b0),    			//           .chipselect
	.sdram_writedata     (writedata),     	//           .writedata
	.sdram_read_n        (~play),        	//           .read_n
	.sdram_write_n       (~record),       	//           .write_n
	.sdram_readdata      (readdata),      	//           .readdata
	.sdram_readdatavalid (), 					//           .readdatavalid
	.sdram_waitrequest   (),   			  	//           .waitrequest
	.sdram_wire_addr     (DRAM_ADDR),    	// sdram_wire.addr
	.sdram_wire_ba       (DRAM_BA),       	//           .ba
	.sdram_wire_cas_n    (DRAM_CAS_N),    	//           .cas_n
	.sdram_wire_cke      (DRAM_CKE),     	//           .cke
	.sdram_wire_cs_n     (DRAM_CS_N),    	//           .cs_n
	.sdram_wire_dq       (DRAM_DQ),       	//           .dq
	.sdram_wire_dqm      (DRAM_DQM),      	//           .dqm
	.sdram_wire_ras_n    (DRAM_RAS_N),    	//           .ras_n
	.sdram_wire_we_n     (DRAM_WE_N)      	//           .we_n
);
 assign DRAM_CLK = CLOCK_50;
 
// Audio Configuration Stuff 
Audio_Controller Audio_Controller (
	// InputsHEX0
	.CLOCK_50						(CLOCK_50),
	.reset						(~reset),

	.clear_audio_in_memory		(),
	.read_audio_in				(read_audio_in),
	
	.clear_audio_out_memory		(),
	.left_channel_audio_out		(left_channel_audio_out),
	.right_channel_audio_out	(right_channel_audio_out),
	.write_audio_out			(write_audio_out),

	.AUD_ADCDAT					(AUD_ADCDAT),

	// Bidirectionals
	.AUD_BCLK					(AUD_BCLK),
	.AUD_ADCLRCK				(AUD_ADCLRCK),
	.AUD_DACLRCK				(AUD_DACLRCK),


	// Outputsd9000000
	.audio_in_available			(audio_in_available),
	.left_channel_audio_in		(left_channel_audio_in),
	.right_channel_audio_in		(right_channel_audio_in),

	.audio_out_allowed			(audio_out_allowed),

	.AUD_XCK					(AUD_XCK),
	.AUD_DACDAT					(AUD_DACDAT),

);


avconf #(.USE_MIC_INPUT(1)) avc (
	.I2C_SCLK					(I2C_SCLK),
	.I2C_SDAT					(I2C_SDAT),
	.CLOCK_50					(CLOCK_50),
	.reset						(~reset)
);




endmodule






