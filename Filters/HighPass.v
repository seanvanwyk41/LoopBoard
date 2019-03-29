// Based off formula from: https://en.wikipedia.org/wiki/High-pass_filter#Algorithmic_implementation
module HighPassFilter(
	// Input
	left_channel_audio_in,
	right_channel_audio_in,
	reset,
	AUD_BCLK,
	AUD_DACLRCK,

	// Outputs
	left_channel_audio_out,
	right_channel_audio_out
);

	input [31:0] left_channel_audio_in;
	input [31:0] right_channel_audio_in;
	input reset;
	input AUD_BCLK;
	input AUD_DACLRCK;

	output reg [31:0] left_channel_audio_out;
	output reg [31:0] right_channel_audio_out;

	reg [31:0] alpha_prime = 32'd60; // alpha prime is 60 so alpha is 0.6
	reg [31:0] previous_left_channel_audio_in = 32'd0;
	reg [31:0] previous_right_channel_audio_in = 32'd0;
	reg [31:0] previous_left_channel_audio_out = 32'd0;
	reg [31:0] previous_right_channel_audio_out = 32'd0;

	always @(*)
	begin
		// Wikipedia states:y[i] = α * (y[i-1] + x[i] - x[i-1])
		left_channel_audio_out = $unsigned(($signed(previous_left_channel_audio_out) + $signed(left_channel_audio_in) - $signed(previous_left_channel_audio_in)) / $signed(alpha_prime));
		right_channel_audio_out = $unsigned(($signed(previous_right_channel_audio_out) + $signed(right_channel_audio_in) - $signed(previous_right_channel_audio_in)) / $signed(alpha_prime));
		//left_channel_audio_out = left_channel_audio_in;
		//right_channel_audio_out = right_channel_audio_in;
	end

	// Need to store the previous audio out
	always @(posedge AUD_BCLK or negedge reset)
	begin
		if(reset == 1'b0)
			begin
				previous_left_channel_audio_out <= 32'd0;
				previous_right_channel_audio_out <= 32'd0;
			end
		else
			begin
				if(AUD_DACLRCK == 1'b1)
				begin
					previous_left_channel_audio_out <= left_channel_audio_out;
					previous_right_channel_audio_out <= right_channel_audio_out;
					previous_left_channel_audio_in <= left_channel_audio_in;
					previous_right_channel_audio_in <= right_channel_audio_in;
				end
			end
	end
	
endmodule