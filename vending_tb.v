// Set timescale
`timescale 1ns / 1ns

// Testbench Verilog code for up counter
module vending_machine_tb();

reg clk;
reg clk2;

reg rst;
reg paymentMethod;
reg [3:0] index;
reg [63:0] cost;
reg [23:0] currentInventory;
reg nickel, dime, quarter, dollar;
reg cancel;
reg [8:0] creditBalance;

reg [1:0] se;
reg [5:0] si;

wire dispensed;
wire [31:0] change;
wire [8:0] quart;
wire [8:0] dim;
wire [8:0] nick;


localparam CLK_PERIOD = 1000;	// 1 MHz


vending_machine dut(clk, clk2, se, si, rst, index, paymentMethod, creditBalance, nickel, dime, quarter, dollar, cost, cancel, currentInventory, quart, dim, nick);
					 
initial clk = 0;
always #CLK_PERIOD clk = ~clk;


initial clk2 = 0;
always #(CLK_PERIOD/2) clk2 = ~clk2;

integer i;
initial begin

	// Scan initialization
	si = 0;
	se = 0;

	cost = {8'd125, 8'd110, 8'd100, 8'd150, 8'd200, 8'd100, 8'd300, 8'd200};
	currentInventory = {3'd4,3'd4,3'd4,3'd4,3'd4,3'd4,3'd4,3'd4};

	// Sets payment method to credit
	paymentMethod = 1;
	creditBalance = 9'd200;	//2 dollar
	rst = 0;
	cancel = 0;

	#(CLK_PERIOD);
	// Select the product (product 2)
	index = 2;

	// Resets to initialize registers
	rst = 1;
	#(2*CLK_PERIOD);
	rst = 0;
	#(2*CLK_PERIOD);
	
	// Insert coins
	for (i=0; i<=3; i=i+1) begin	// Insert 4 nickels and 4 dollars
		nickel=1;
		dollar=1;
		$display("Money entered");
		#(CLK_PERIOD);
		nickel=0;
		dollar=0;
		#(CLK_PERIOD);
	end
	
	#(2*CLK_PERIOD);
	
	// Sets payment method to cash
	paymentMethod = 0;
	index = 3;
	#(2*CLK_PERIOD);
	
	dollar=1;
	$display("Money entered");
	#(CLK_PERIOD);
	dollar=0;
	
	
	#(6*CLK_PERIOD);
	
	dollar=1;
	$display("Money entered");
	#(CLK_PERIOD);
	dollar=0;
	
	index = 5;
	
	#(20*CLK_PERIOD);
	
	// Times out cancel after it counter reaches ~40
	
	
end
endmodule 