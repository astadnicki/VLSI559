module dispenseChange(change, rst, quarters, dimes, nickels);

input [8:0] change;
input rst;
output reg [4:0] quarters;
output reg [4:0] dimes;
output reg [4:0] nickels;

localparam QUARTER = 25;
localparam DIME = 10;
localparam NICKEL = 5;

// Combinational logic	
always @(*) begin
	if (rst) begin
		quarters = 5'b0;
		dimes = 5'b0;
		nickels = 5'b0;
	end else begin
		quarters = change / QUARTER;
		dimes = (change % QUARTER) / DIME;
		nickels = ((change % QUARTER) % DIME) / NICKEL;

		$display("Quarters: %d, Dimes: %d, Nickels: %d", quarters, dimes, nickels);
	end
	
end
	

endmodule 