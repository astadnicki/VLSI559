// Set timescale
`timescale 1ns / 1ns

// Testbench Verilog code for up counter
module vending_tb();

reg clk;
reg rst;
reg paymentMethod;
reg [2:0] index;
reg [63:0] cost;
reg nickel, dime, quarter, dollar;
reg cancel;
reg [8:0] creditBalance;

wire dispensed;
wire [8:0] change;
wire [3:0] quart;
wire [2:0] dim;
wire [2:0] nick;
wire [2:0] pen;

localparam CLK_PERIOD = 10;


vending dut(clk, rst, index, paymentMethod, creditBalance, nickel, dime, quarter, dollar, cost, cancel, dispensed, quart, dim, nick, pen);

initial clk = 0;
always #CLK_PERIOD clk = ~clk;

// declare inventory
initial begin

	// enter what inventory is available by index
	cost = {8'b10010110, 8'b1100100, 8'b11001000, 8'b1100100, 8'b1100100, 8'b1100100, 8'b1100100, 8'b1100100};	

end

integer i;
initial begin

	cancel = 0;
	paymentMethod = 1;
	creditBalance = 8'b1100100 - 1;	//1 dollar
	rst = 0;

	// Select the product
	index = 2;
	
	
	rst = 1;
	#20;
	rst = 0;
	
	#15;

	// Insert coins
	for (i=0; i<=3; i=i+1) begin	// insert 4 nickels and 4 dollars
		nickel=1;
		dollar=1;
		$display("Money entered");
		#10;
		nickel=0;
		dollar=0;
		#10;
	end
	
	#10;
	cancel = 1;
	$display("cancel");
	#10;
	cancel = 0;
	
	for (i=0; i<=3; i=i+1) begin	// insert 4 nickels and 4 dollars
		nickel=1;
		dollar=1;
		$display("Money entered");
		#10;
		nickel=0;
		dollar=0;
		#10;
	end
	
	index=0;
	#10;
	index = 1;
	
	cancel = 1;
	#10;
	cancel = 0;
	
	

	
	
end

// Increment count

endmodule 
