// Set timescale
`timescale 1ns / 1ns

// Testbench Verilog code for up counter
module vending_tb();

reg clk;
reg paymentMethod;
reg [2:0] index;
reg [20:0] cost;
reg nickel, dime, quarter, dollar;

wire dispensed;
wire [8:0] change;
wire [3:0] dispensedIndex;

localparam CLK_PERIOD = 10;


vending dut(clk, index, paymentMethod, creditBalance, nickel, dime, quarter, cost, change, cancel, dispensed);

initial clk = 0;
always #CLK_PERIOD clk = ~clk;

// declare inventory
initial begin

	// enter what inventory is available by index.
	cost = {3'd150, 3'd100, 3'd200, 3'd100, 3'd000, 3'd000, 3'd000};	// 7 dollar values for the 7 indexes, 3'd000 = no item in stock

end

integer i;
initial begin

	// Select the product
	index = 2;

	// Insert coins
	for (i=0; i<=3; i=i+1) begin	// insert 4 nickels
		nickel=1;
		#5;
		nickel=0;
		#5;
	end
	
	$display ("Returned money:");
	$display (change);	// displaying returned money
	//if (
	$display ("Product dispensed:");
	
end

// Increment count

endmodule 
