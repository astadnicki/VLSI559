// Set timescale
`timescale 1ns / 1ns

// Testbench Verilog code for up counter
module vending_tb();

reg clk;
reg paymentMethod;
reg [32:0] index;
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


vending dut(clk, index, paymentMethod, creditBalance, nickel, dime, quarter, dollar, cost, cancel, dispensed, quart, dim, nick, pen);

initial clk = 0;
always #CLK_PERIOD clk = ~clk;

// declare inventory
initial begin

	// enter what inventory is available by index.
	cost = {8'b10010110, 8'b1100100, 8'b11001000, 8'b1100100, 8'b1100100, 8'b1100100, 8'b1100100, 8'b1100100};	

end

integer i;
initial begin

	cancel = 0;
	paymentMethod = 0;
	creditBalance = 8'b1100100;

	// Select the product
	index = 2;

	// Insert coins
	for (i=0; i<=3; i=i+1) begin	// insert 4 nickels
		nickel=1;
		dollar=1;
		#15;
		nickel=0;
		dollar=0;
		#15;
	end
	
	#15;
	cancel = 1;
	$display("cancel");
	#15;
	cancel = 0;
	

	
	
end

// Increment count

endmodule 
