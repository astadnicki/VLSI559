module dispenseChange(change, quarters, dimes, nickels, pennies);

input [8:0] change;
output reg [3:0] quarters;
output reg [2:0] dimes;
output reg [2:0] nickels;
output reg [2:0] pennies;
	
always @* begin
	quarters = change / 25;
	dimes = (change % 25) / 10;
	nickels = ((change % 25) % 10) / 5;
	pennies = (((change % 25) % 10) % 5);
end
	

endmodule 
