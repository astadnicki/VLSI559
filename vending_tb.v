// Set timescale
`timescale 1ns / 1ns

// Testbench Verilog code for up counter
module vending_machine_tb();

reg clk;
reg clk2;
wire gclk;

reg rst;
reg paymentMethod;
reg [3:0] index;
reg [63:0] cost;
reg [23:0] currentInventory;
reg nickel, dime, quarter, dollar;
reg cancel;
reg [8:0] creditBalance;

reg [4:0] se;
reg [101:0] si;

wire dispensed;
wire [8:0] change;
wire [4:0] quart;
wire [4:0] dim;
wire [4:0] nick;

localparam CLK_PERIOD = 1000;	// 1 MHz


vending_machine dut(clk, clk2, se, si, rst, index, paymentMethod, creditBalance, nickel, dime, quarter, dollar, cost, cancel, currentInventory, quart, dim, nick, gclk);
					 
initial clk = 0;
always #CLK_PERIOD clk = ~clk;


initial clk2 = 0;
always #(CLK_PERIOD/2) clk2 = ~clk2;

integer i;
initial begin

	si = 0;
	se = 0;

	cost = {8'd100, 8'd100, 8'd100, 8'd100, 8'd100, 8'd100, 8'd100, 8'd100};
	currentInventory = {3'd4,3'd4,3'd4,3'd4,3'd4,3'd4,3'd4,3'd4};

	paymentMethod = 1;
	creditBalance = 9'd200;	//2 dollar
	rst = 0;

	#(CLK_PERIOD);
	// Select the product
	index = 2;

	rst = 1;
	#(2*CLK_PERIOD);
	rst = 0;
	#(2*CLK_PERIOD);
	
	// Insert coins
	for (i=0; i<=3; i=i+1) begin	// insert 4 nickels and 4 dollars
		nickel=1;
		dollar=1;
		$display("Money entered");
		#(CLK_PERIOD);
		nickel=0;
		dollar=0;
		#(CLK_PERIOD);
		//if (i== 1) cancel = 1;
	end
	
	#(2*CLK_PERIOD);
	
	paymentMethod = 0;
	index = 1;
	
	#(4*CLK_PERIOD);
	
	index = 3;
	
	//cancel = 1;
	
	#(20*CLK_PERIOD);
	
	for (i=0; i<=3; i=i+1) begin	// insert 4 nickels and 4 dollars
		nickel=1;
		dollar=1;
		$display("Money entered");
		#(CLK_PERIOD);
		nickel=0;
		dollar=0;
		#(CLK_PERIOD);
	end
end

endmodule 