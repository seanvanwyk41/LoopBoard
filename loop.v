module loop(aud_clk,							// in 		:Audio clock set to 48 Khz
				clk,								// in			:System clock set to 50 Mhz
				readdata,						// in [31:0]:Read data from sdram
				left_channel_audio_in,		// in [31:0]:Left audio channel in
				right_channel_audio_in,		// in [31:0]:Right channel audio in
				reset,							// in			:Async Reset
				record,							// in 		:Record
				channel,							// in [3:0]	:4 way channel Select
				play,								// in 		:Play read audio
				address_out,					// out[24:0]:Address to save audio to sram
				writedata,						// out[31:0]:Data to save on sram
				write_en,						// out		: whether or not to write to sdram
				left_channel_audio_out,		// out[31:0]:Left channel audio out
				right_channel_audio_out		// out[31:0]:Right channel audio out
);
	// inputs and out puts
	input aud_clk;
	input clk;
	input record;
	input [31:0] 	readdata;
	input	[31:0]	left_channel_audio_in;
	input	[31:0]	right_channel_audio_in;
	input reset;
	input play;
	input [3:0] channel;

	output		[24:0]	address_out;
	output reg	[31:0] 	writedata;
	output reg 				write_en;
	output 		[31:0]	left_channel_audio_out;
	output 		[31:0]	right_channel_audio_out;
	// registers
	reg [24:0] address;
	reg left;
	reg [2:0] counter; 
	reg [31:0] out;
	// Constants
	reg [24:0] max_address = 25'd3072000;
	reg [3:0]  switch_delay = 4'b0111;
	// Loop box registers
	reg [31:0] loop1_left_out;
	reg [31:0] loop2_left_out;
	reg [31:0] loop3_left_out;
	reg [31:0] loop4_left_out;
	reg [31:0] loop1_right_out;
	reg [31:0] loop2_right_out;
	reg [31:0] loop3_right_out;
	reg [31:0] loop4_right_out;
	// Set Address
	always @ (posedge aud_clk, negedge reset)
	begin
		if (!reset)
			address = 0;
		else if (address < max_address) address = ((play ^ record) && (|channel)) * (address + 8);
		else address = 0;
	end

	// Set Read data and write data
	always @ (posedge clk, negedge reset)
	begin
		if (!reset)
			begin
				counter <= 0;
			end
		else if (counter <= switch_delay)
			begin
				// Increment counter
				counter <= counter + 1;
				// read/write
				case (counter)
					// Loop 1
					3'b000: 
						begin
							loop1_left_out =  channel[0]* play * readdata;
							writedata = channel[0] * left_channel_audio_in;			// Works
							write_en = channel[0] && record;
						end
					3'b001:
						begin
							loop1_right_out = channel[1] * play * readdata;			// Doesnt work
							writedata = channel[0] * right_channel_audio_in;
							write_en = channel[0] && record;
						end
					// Loop 2
					3'b010:
						begin
							loop2_left_out = channel[1] * play * readdata;		 // Works
							writedata = channel[1] * left_channel_audio_in;
							write_en = channel[1] && record;
						end
					3'b011:
						begin
							loop2_right_out = channel[2] * play * readdata;		// Works
							writedata = channel[1] * right_channel_audio_in;
							write_en = channel[1] && record;
						end
					// Loop 3
					3'b100:
						begin
							loop3_left_out = channel[2] * play * readdata;		// Works
							writedata = channel[2] * left_channel_audio_in;
							write_en = channel[2] && record;
						end
					3'b101:
						begin
							loop3_right_out = channel[3] * play * readdata;
							writedata = channel[2] * right_channel_audio_in;	//Works
							write_en = channel[2] && record;
						end
					// Loop 4
					3'b110:
						begin
							
							loop4_left_out = channel[3] * play * readdata;
							writedata = channel[3] * left_channel_audio_in;  	// Works
							write_en = channel[3] && record;
						end
					3'b111:
						begin
							loop4_right_out = channel[0] * play * readdata;
							writedata = channel[3] * right_channel_audio_in;	// Plays loop 3
							write_en = channel[3] && record;
						end
					default:;
				endcase
			end
		else counter = 0;
	end
	assign left_channel_audio_out =  left_channel_audio_in+ loop4_left_out + loop3_left_out + loop2_left_out + loop1_left_out;
	assign right_channel_audio_out = right_channel_audio_in+loop4_right_out + loop3_right_out + loop2_right_out + loop1_right_out;
	assign address_out = address + counter;
endmodule 