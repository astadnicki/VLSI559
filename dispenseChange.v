module dispenseChange(change, quarters, dimes, nickels);
	input [8:0] change;
	output reg [3:0] quarters;
	output reg [5:0] dimes;
	output reg [7:0] nickels;
	
	reg [8:0] changeReg;
	
	/*always @* begin
		quarters = $floor(change/25);
		dimes = $floor((change%25)/10);
	end*/
	

endmodule 