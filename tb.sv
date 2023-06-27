`timescale 1ns/1ns

module tb; //testbench module 

integer input_file, output_file, in, out;
integer i;
integer file, results, comparison;

parameter CYCLE = 100; 

reg clk, reset_n;
reg start, done;
reg [31:0] a_in, b_in; 
reg [31:0] result;

// GCD calc variables
int temp_a;
int temp_b;
int standard;

//clock generation for write clock
initial begin
  clk <= 0; 
  forever #(CYCLE/2) clk = ~clk;
end

class Random;
	rand bit[15:0] a;
	rand bit[15:0] b;
	constraint a_con {a < 500; a > 0;}  // Cant be 500 as b>0 and a+b = 500
	constraint b_con {b > 0; b < 500;} // Cant be 0 else FSM breaks
	constraint ab_sum {a + b == 500;}	 
endclass

// Function to calculate the GCD using Euclidean algorithm
function automatic int gcd(int a, int b);
	while (b != 0) begin
      		int temp;
      		temp = a % b;
      		a = b;
      		b = temp;
    	end
    	return a;
endfunction	

gcd gcd_0(.*); 
Random cts = new;

//********************** Part 1.1 *********************************************
//release of reset_n relative to two clocks
initial begin
    input_file  = $fopen("input_data", "rb");
    if (input_file==0) begin 
      $display("ERROR : CAN NOT OPEN input_file"); 
    end
    output_file = $fopen("output_data", "wb");
    if (output_file==0) begin 
      $display("ERROR : CAN NOT OPEN output_file"); 
    end
    a_in='x;
    b_in='x;
    start=1'b0;
    reset_n <= 0;
    #(CYCLE * 1.5) reset_n = 1'b1;
	
  #(CYCLE*4);  
  while (!$feof(input_file)) begin 
    file = $fscanf(input_file, "%d %d", a_in, b_in);
    start = 1'b1;
    #(CYCLE);
    start = 1'b0;
    while (done != 1'b1) #(CYCLE);
    $fwrite(output_file, "%d %d %d\n", a_in, b_in, result);
    #(CYCLE*2); 
  end
//********************** Part 1.2 *********************************************
    input_file  = $fopen("post_input_data", "rb");
    if (input_file==0) begin
      $display("ERROR : CAN NOT OPEN input_file");
    end
    a_in='x;
    b_in='x;
    start=1'b0;
    reset_n <= 0;
    #(CYCLE * 1.5) reset_n = 1'b1; 

  #(CYCLE*4);  
  while (!$feof(input_file)) begin
    file = $fscanf(input_file, "%d %d", a_in, b_in);
    start = 1'b1;
    #(CYCLE);
    start = 1'b0;
    while (done != 1'b1) #(CYCLE);
    #(CYCLE*2);
  end

//********************* Part 2 ***********************************************
   results = $fopen("random-outputs.txt", "wb");
    if (results==0) begin
      $display("ERROR : CAN NOT OPEN results file");
    end
    a_in='x;
    b_in='x;
    start=1'b0;
    reset_n <= 0;
    #(CYCLE * 1.5) reset_n = 1'b1; 
	
  i = 0;
  #(CYCLE*4);  
  while (i < 502) begin
    cts.randomize();
    a_in = cts.a;
    b_in = cts.b;
    start = 1'b1;
    #(CYCLE);
    start = 1'b0;
    while (done != 1'b1) #(CYCLE);
    $fwrite(results, "%d %d %d\n", a_in, b_in, result);
    #(CYCLE*2);
    i += 1;
  end
//********************** Part 3 *********************************************
    input_file  = $fopen("input_data", "rb");
    if (input_file==0) begin 
      $display("ERROR : CAN NOT OPEN input_file"); 
    end
    comparison = $fopen("comparison.rpt", "wb");
    if (results==0) begin
      $display("ERROR : CAN NOT OPEN comparison file");
    end
    a_in='x;
    b_in='x;
    start=1'b0;
    reset_n <= 0;
    #(CYCLE * 1.5) reset_n = 1'b1; 
	
  #(CYCLE*4);  
  while (!$feof(input_file)) begin
    file = $fscanf(input_file, "%d %d", a_in, b_in);
    start = 1'b1;
    #(CYCLE);
    start = 1'b0;
    while (done != 1'b1) #(CYCLE);
    // Calculate Standard for behavioral comparison
    temp_a = a_in;
    temp_b = b_in;
    // Perform Euclid's algorithm  
    if (temp_b > temp_a) begin
	standard = temp_a;
	temp_a = temp_b;
	temp_b = standard;
    end
    standard = gcd(temp_a, temp_b);
    if (result == standard) $fwrite(comparison, "%d %d match\n", a_in, b_in);
    else $fwrite(comparison, "%d %d gcd: %d behavioral: %d\n", a_in, b_in, result, standard, comparison);
    #(CYCLE*2);
  end
  //********************** Part 3 (Random) *********************************************
    input_file  = $fopen("random-outputs.txt", "rb");
    if (input_file==0) begin 
      $display("ERROR : CAN NOT OPEN input_file"); 
    end
    a_in='x;
    b_in='x;
    start=1'b0;
    reset_n <= 0;
    #(CYCLE * 1.5) reset_n = 1'b1; 
	
  #(CYCLE*4);  
  while (!$feof(input_file)) begin
    file = $fscanf(input_file, "%d %d %*d", a_in, b_in);
    start = 1'b1;
    #(CYCLE);
    start = 1'b0;
    while (done != 1'b1) #(CYCLE);
    // Calculate Standard for behavioral comparison
    temp_a = a_in;
    temp_b = b_in;
    // Perform Euclid's algorithm  
    if (temp_b > temp_a) begin
	standard = temp_a;
	temp_a = temp_b;
	temp_b = standard;
    end
    standard = gcd(temp_a, temp_b);
    if (result == standard) $fwrite(comparison, "%d %d match\n", a_in, b_in);
    else $fwrite(comparison, "%d %d gcd: %d behavioral: %d\n", a_in, b_in, result, standard, comparison);
    #(CYCLE*2);
  end
$stop;
$fclose(input_file);
end

endmodule
