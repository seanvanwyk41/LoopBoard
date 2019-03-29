module AllFilters(
	// Inputs
	left_channel_audio_in,
	right_channel_audio_in,
	filter_choice,
	reset,
	
	// Bidirectional
	AUD_BCLK,
	AUD_ADCLRCK,
	AUD_DACLRCK,
	
	// Outputs
	left_channel_audio_out,
	right_channel_audio_out
);

// Inputs
input [31:0] left_channel_audio_in;
input [31:0] right_channel_audio_in;
input [1:0] filter_choice;
input reset;

// Bidirectional - input and output
inout AUD_BCLK;
inout AUD_ADCLRCK;
inout AUD_DACLRCK;

// Outputs
output reg [31:0] left_channel_audio_out;
output reg [31:0] right_channel_audio_out;

// Wires
wire [31:0] left_channel_audio_out_lowpass;
wire [31:0] right_channel_audio_out_lowpass;
wire [31:0] left_channel_audio_out_highpass;
wire [31:0] right_channel_audio_out_highpass;
wire [31:0] left_channel_audio_out_bandpass;
wire [31:0] right_channel_audio_out_bandpass;

// Mux (sort of) to choose which filter to implement
always@(*)
begin
	case(filter_choice)
		2'b01: begin
			left_channel_audio_out = left_channel_audio_out_lowpass;
			right_channel_audio_out = right_channel_audio_out_lowpass;
		end
		2'b10: begin
			left_channel_audio_out = left_channel_audio_out_highpass;
			right_channel_audio_out = right_channel_audio_out_highpass;
		end
		2'b11: begin
			left_channel_audio_out = 32'b11111111111111111111111111;
			right_channel_audio_out = right_channel_audio_out_bandpass;
		end
		default: begin
			left_channel_audio_out = left_channel_audio_in;
			right_channel_audio_out = right_channel_audio_in;
		end
	endcase
end

LowPassFilter lowpass(
	.left_channel_audio_in(left_channel_audio_in),
	.right_channel_audio_in(right_channel_audio_in),
	.reset(reset),
	.AUD_BCLK(AUD_BCLK),
	.AUD_DACLRCK(AUD_DACLRCK),
	.alpha_prime(32'd10),
	.left_channel_audio_out(left_channel_audio_out_lowpass),
	.right_channel_audio_out(right_channel_audio_out_lowpass)
);

HighPassFilter highpass(
	.left_channel_audio_in(left_channel_audio_in),
	.right_channel_audio_in(right_channel_audio_in),
	.reset(reset),
	.AUD_BCLK(AUD_BCLK),
	.AUD_DACLRCK(AUD_DACLRCK),
	.left_channel_audio_out(left_channel_audio_out_highpass),
	.right_channel_audio_out(right_channel_audio_out_highpass)
);

BandPassFilter bandpass(
	.left_channel_audio_in(left_channel_audio_in),
	.right_channel_audio_in(right_channel_audio_in),
	.reset(reset),
	.AUD_BCLK(AUD_BCLK),
	.AUD_DACLRCK(AUD_DACLRCK),
	.left_channel_audio_out(left_channel_audio_out_bandpass),
	.right_channel_audio_out(right_channel_audio_out_bandpass)
);

endmodule