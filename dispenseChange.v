module dispenseChange(change, quarters, dimes, nickels, pennies);

input [8:0] change;
output reg [3:0] quarters;
output reg [2:0] dimes;
output reg [2:0] nickels;
output reg [2:0] pennies;

localparam QUARTER = 25;
localparam DIME = 10;
localparam NICKEL = 5;
	
always @(change) begin
	quarters = change / QUARTER;
	dimes = (change % QUARTER) / DIME;
	nickels = ((change % QUARTER) % DIME) / NICKEL;
	pennies = (((change % QUARTER) % DIME) % NICKEL);
end
	

endmodule 
