// Assuming volume can be affected by dividing audio in by what's wanted
module Volume(
	// Input
	left_channel_audio_in,
	right_channel_audio_in,
	level, // 2 bits

	// Outputs
	left_channel_audio_out,
	right_channel_audio_out
);

	input [31:0] left_channel_audio_in;
	input [31:0] right_channel_audio_in;
	input [1:0] level;

	output reg [31:0] left_channel_audio_out;
	output reg [31:0] right_channel_audio_out;

	always@(*)
	begin
		case(level)
			2'b01: begin
				// 33% volume
				left_channel_audio_out = $unsigned($signed(left_channel_audio_in) / $signed(32'd3));
				right_channel_audio_out = $unsigned($signed(right_channel_audio_in) / $signed(32'd3));
			end
			2'b10: begin
				// 66% volume
				left_channel_audio_out = $unsigned($signed(left_channel_audio_in) / $signed(32'd3) * $signed(32'd2));
				right_channel_audio_out = $unsigned($signed(right_channel_audio_in) / $signed(32'd3) * $signed(32'd2));
			end
			2'b11: begin
				// Full volume
				left_channel_audio_out = left_channel_audio_in;
				right_channel_audio_out = right_channel_audio_in;
			end
			default: begin
				// No volume
				left_channel_audio_out = 32'b0;
				right_channel_audio_out = 32'b0;
			end
		endcase
	end
	
endmodule