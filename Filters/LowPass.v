// Based off formula from: https://en.wikipedia.org/wiki/Low-pass_filter#Simple_infinite_impulse_response_filter
module LowPassFilter(
	// Input
	left_channel_audio_in,
	right_channel_audio_in,
	reset,
	AUD_BCLK,
	AUD_DACLRCK,
	alpha_prime,

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

	input [31:0] alpha_prime;
	reg [31:0] previous_left_channel_audio_out = 32'd0;
	reg [31:0] previous_right_channel_audio_out = 32'd0;

	always @(*)
	begin
		// Wikipedia states:y[i] = y[i-1] + α * (x[i] - y[i-1])
		left_channel_audio_out = $unsigned($signed(previous_left_channel_audio_out) + ($signed(left_channel_audio_in) - $signed(previous_left_channel_audio_out)) / $signed(alpha_prime));
		right_channel_audio_out = $unsigned($signed(previous_right_channel_audio_out) + ($signed(right_channel_audio_in) - $signed(previous_right_channel_audio_out)) / $signed(alpha_prime));
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
				end
			end
	end
	
endmodule