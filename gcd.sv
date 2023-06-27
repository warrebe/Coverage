	module gcd(	input [31:0] a_in,          //operand a
			input [31:0] b_in,          //operand b
			input start,                //validates the input data
			input reset_n,              //reset
			input clk,                  //clock
			output reg [31:0] result,  //output of GCD engine
			output reg done);          //validates output value

	logic			registers_equal		;
	logic			register_a_smaller	;
	logic			swap_registers		;
	logic			subtract_registers	;
	logic			done_flag			;
	logic	[31:0]	register_b			;

	//register_b
	always_ff @(posedge clk, negedge reset_n) begin
		if (~reset_n)					register_b <= 0;
		else if (start)					register_b <= b_in;
		else if (swap_registers)		register_b <= result;
	end

	//result
	always_ff @(posedge clk, negedge reset_n) begin
		if (~reset_n)					result <= 0;
		else if (start)					result <= a_in;
		else if (swap_registers)		result <= register_b;
		else if (subtract_registers)	result <= result - register_b;
	end

	//done
	always_ff @(posedge clk, negedge reset_n) begin
		if (~reset_n)					done <= 0;
		else if (done_flag)				done <= 1;
		else							done <= 0;
	end

	assign registers_equal		= (result == register_b);
	assign register_a_smaller	= (result < register_b);

	gcd_ctrl gcd_ctrl_0(
		.start					,
		.reset_n				,
		.clk					,
		.registers_equal		,
		.register_a_smaller		,
		.swap_registers			,
		.subtract_registers		,
		.done_flag				);
	
endmodule
