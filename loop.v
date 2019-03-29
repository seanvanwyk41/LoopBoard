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
				right_channel_audio_out,	// out[31:0]:Right channel audio out
				count0,							// out 		:counter for the 0th channel
				count1,							// out 		:counter for the 1st channel
				count2,							// out 		:counter for the 2nd channel
				count3							// out 		:counter for the 3rd channel
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

	output reg	[24:0]	address_out;
	output reg	[31:0] 	writedata;
	output reg 				write_en;
	output 		[31:0]	left_channel_audio_out;
	output 		[31:0]	right_channel_audio_out;
	output 	 	[3:0]		count0;
	output  		[3:0]		count1;
	output  		[3:0]		count2;
	output 	 	[3:0]		count3;
	// registers
	reg [24:0] address0 = 0;
	reg [24:0] address1 = 1;
	reg [24:0] address2 = 2;
	reg [24:0] address3 = 3;
	reg left;
	reg [4:0] counter; 
	reg [31:0] out;
	// Constants
	reg [24:0] max_address = 25'd3072000;
	reg [4:0]  switch_delay = 5'b01111;
	// Loop box registers
	reg [31:0] loop1_left_out;
	reg [31:0] loop2_left_out;
	reg [31:0] loop3_left_out;
	reg [31:0] loop4_left_out;
	reg [31:0] loop1_right_out;
	reg [31:0] loop2_right_out;
	reg [31:0] loop3_right_out;
	reg [31:0] loop4_right_out;
	// Set Address Async counters
	always @ (posedge aud_clk, negedge reset)
	begin
		if (!reset)
			begin
				address0 = 0;
				address1 = 1;
				address2 = 2;
				address3 = 3;
			end 
		else 
			begin
				// Address 0
				if (address0 < max_address)
					address0 = ((play ^ record) && (channel[0])) * (address0 + 8);
				else 
					address0 = 0;
				// Address 1
				if (address1 < max_address)
					address1 = ((play ^ record) && (channel[1])) * (address1 + 8);
				else 
					address1 = 1;
				// Address 1
				if (address2 < max_address)
					address2 = ((play ^ record) && (channel[2])) * (address2 + 8);
				else 
					address2 = 2;
				// Address 3	
				if (address3 < max_address)
					address3 = ((play ^ record) && (channel[3])) * (address3 + 8);
				else 
					address3 = 3;
			end
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
					// Left
					// write
					3'b0000: 
						begin
							writedata = channel[0] * left_channel_audio_in;			// Works
							write_en = channel[0] && record;
							address_out = address0 + 1;
							
						end
					// Read
					3'b0001: 
						begin
							loop1_left_out =  channel[0]* play * readdata;
							
						end
					// Right
					// write
					3'b0010:
						begin
							writedata = channel[0] * right_channel_audio_in;
							write_en = channel[0] && record;
							address_out = address1;
						end
					// Read
					3'b0011:
						begin
							loop1_right_out = channel[0] * play * readdata;			// Doesnt work
							
						end
					// Loop 2
					// Left
					// write
					3'b0100:
						begin
							writedata = channel[1] * left_channel_audio_in;
							write_en = channel[1] && record;
							address_out = address1 + 1;
							
						end
					// Read
					3'b0101:
						begin
							loop2_left_out = channel[1] * play * readdata;		 // Works
							
					end
					// Right
					// write
					3'b0110:
						begin
							writedata = channel[1] * right_channel_audio_in;
							write_en = channel[1] && record;
							address_out = address2;
							
						end
					// Read
					3'b0111:
						begin
							loop2_right_out = channel[1] * play * readdata;		// Works
							
						end
					// Loop 3
					// Left
					// write
					3'b1000:
						begin
							writedata = channel[2] * left_channel_audio_in;
							write_en = channel[2] && record;
							address_out = address2+1;
							
						end
					// Read
					3'b1001:
						begin
							loop3_left_out = channel[2] * play * readdata;		// Works
							
						end
					// Right
					// write	end

					3'b1010:
						begin
							writedata = channel[2] * right_channel_audio_in;	//Works
							write_en = channel[2] && record;
							address_out = address3;
							
						end
					// Read
					3'b1011:
						begin
							loop3_right_out = channel[2] * play * readdata;
							
						end
					// Loop 4
					// Left
					// write
					3'b1100:
						begin
							writedata = channel[3] * left_channel_audio_in;  	// Works
							write_en = channel[3] && record;
							address_out = address3+1;
						end
					// Read
					3'b1101:
						begin
							
							loop4_left_out = channel[3] * play * readdata;
							
						end
					// Right
					// write
					3'b1110:
						begin
							writedata = channel[3] * right_channel_audio_in;	// Plays loop 3
							write_en = channel[3] && record;
							address_out = address0;
						end
					// Read
					3'b1111:
						begin
							loop4_right_out = channel[3] * play * readdata;
							
						end
					default:;
				endcase
			end
		else counter = 0;
	end
	assign count0 = (address0)/384000;
	assign count1 = (address1-1)/384000;
	assign count2 = (address2-2)/384000;
	assign count3 = (address3-3)/384000;
	assign left_channel_audio_out =  left_channel_audio_in+ loop4_left_out + loop3_left_out + loop2_left_out + loop1_left_out;
	assign right_channel_audio_out = right_channel_audio_in+loop4_right_out + loop3_right_out + loop2_right_out + loop1_right_out;
endmodule 