module gcd_ctrl
	(input start				,
	input reset_n				,
	input clk					,
	input registers_equal		,
	input register_a_smaller	,
	output swap_registers		,
	output subtract_registers	,
	output done_flag			);

	enum logic [1:0] {
		TEST = 2'h0,
		SWAP = 2'h1,
		SUBT = 2'h2,
		DONE = 2'h3
	} ps, ns;

	//ps
	always_ff @(posedge clk, negedge reset_n) begin
		if (~reset_n)			ps <= DONE;
		else					ps <= ns;
	end

	always_comb
		case (ps)
			DONE:	if (start)						ns = TEST;
					else							ns = DONE;
			TEST:	if (registers_equal)			ns = DONE;
					else if (register_a_smaller)	ns = SWAP;
					else 							ns = SUBT;
			SWAP:									ns = SUBT;
			SUBT:									ns = TEST;
		endcase

	assign swap_registers		= (ns == SWAP);
	assign subtract_registers	= (ns == SUBT);
	assign done_flag			= (ns == DONE && ps == TEST);

endmodule
