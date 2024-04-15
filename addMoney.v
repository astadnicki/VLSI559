module addMoney(clk, currentBalance, dollar, quarter, dime, nickel, newBalance);

input clk;
input wire dollar, quarter, dime, nickel;
input wire [8:0] currentBalance;
output reg [8:0] newBalance;

initial begin
	newBalance = 9'b0;
end

always @(negedge clk) begin
	newBalance = currentBalance;
	if (nickel)  newBalance = newBalance + 3'b101; 	// add 5 to money 
	if (dime) newBalance = newBalance + 4'b1010;  // add 10 to money
	if (quarter) newBalance = newBalance + 5'b11001;		// add 25 to money
	if (dollar) newBalance = newBalance + 7'b1100100; 	// add 100 to money
	$display("newBalance: %d", newBalance);
end

endmodule
