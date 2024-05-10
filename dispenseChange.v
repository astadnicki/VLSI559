module dispenseChange(change, rst, quarters, dimes, nickels);

input [31:0] change;
input rst;
output reg [8:0] quarters;
output reg [8:0] dimes;
output reg [8:0] nickels;

localparam QUARTER = 25;
localparam DIME = 10;
localparam NICKEL = 5;

// Combinational logic	
always @(*) begin
	if (rst) begin
		quarters = 8'b0;
		dimes = 8'b0;
		nickels = 8'b0;
	end else begin
		quarters = change / QUARTER;
		dimes = (change % QUARTER) / DIME;
		nickels = ((change % QUARTER) % DIME) / NICKEL;

		$display("Quarters: %d, Dimes: %d, Nickels: %d", quarters, dimes, nickels);
	end
	
end
	

endmodule 