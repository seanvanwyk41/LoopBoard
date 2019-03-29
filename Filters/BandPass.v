// Band pass filter is a combination of low pass and high pass filters
module BandPassFilter(
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

	output [31:0] left_channel_audio_out;
	output [31:0] right_channel_audio_out;

	// Wires
	wire [31:0] left_channel_audio_out_highpass;
	wire [31:0] right_channel_audio_out_highpass;

	HighPassFilter highpass(
		.left_channel_audio_in(left_channel_audio_out_in),
		.right_channel_audio_in(right_channel_audio_out_in),
		.reset(reset),
		.AUD_BCLK(AUD_BCLK),
		.AUD_DACLRCK(AUD_DACLRCK),
		.left_channel_audio_out(left_channel_audio_highpass),
		.right_channel_audio_out(right_channel_audio_highpass)
	);
	
	LowPassFilter lowpass(
		.left_channel_audio_in(left_channel_audio_highpass),
		.right_channel_audio_in(right_channel_audio_highpass),
		.reset(reset),
		.AUD_BCLK(AUD_BCLK),
		.AUD_DACLRCK(AUD_DACLRCK),
		.alpha_prime(32'd15),
		.left_channel_audio_out(left_channel_audio_out),
		.right_channel_audio_out(right_channel_audio_out)
	);
	
endmodule