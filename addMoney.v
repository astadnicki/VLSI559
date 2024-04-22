module addMoney(clk, rst, state, cancelled, paymentMethod, storeCost, curIndex, credBalance, dollar, quarter, dime, nickel, reduceInventoryDone, reduceInventory, change, cancelledDone);

input clk;
input rst;
input [1:0] state;
input cancelled;
input paymentMethod;
input [63:0] storeCost;
input [3:0] curIndex;
input [8:0] credBalance;
input dollar, quarter, dime, nickel;
input reduceInventoryDone;

output reg reduceInventory;
output reg [8:0] change;
output reg cancelledDone;

reg [8:0] newBalance;
reg [8:0] newCredit;
reg enoughMoney;

localparam num_items = 8;

reg dollar_o, quarter_o, dime_o, nickel_o;
reg [63:0] itemCost;

reg reduceInventoryFlag;

reg [3:0] prevIndex;		
reg boughtProduct;

integer j;
initial begin

	// Initialization
	newBalance = 0;
	newCredit = 0;
	enoughMoney = 0;
	reduceInventory = 0;
	reduceInventoryFlag = 0;
	cancelledDone = 0;
	boughtProduct = 0;
	
	// Initialize coin regs
	nickel_o = 0;
	quarter_o = 0;
	dime_o = 0;
	dollar_o = 0;
end

// Sequential Logic
always @(posedge clk) begin

	if (rst) begin
		// Store item cost into register from scan flip flop
		itemCost <= storeCost;
	end
	
	// Money detection
	if (nickel)  nickel_o <= 1; 	// nickel detected 
	else nickel_o <= 0;
	
	if (dime) dime_o <= 1;  		// dime detected
	else dime_o <= 0;
	
	if (quarter) quarter_o <= 1;	// quarter detected
	else quarter_o <= 0;
	
	if (dollar) dollar_o <= 1; 	// dollar detected
	else dollar_o <= 0;
	
	if ((state == 2'b01) && (~cancelled && ~cancelledDone)) begin		// In state 1 and not in middle of cancelling a product
		if (~paymentMethod) begin		// cash payment
			if (newBalance >= itemCost[curIndex*8+:8]) begin
				enoughMoney <= 1;
			end else begin
				enoughMoney <= 0;
			end
		end else begin																	//  credit card payment
			if (newCredit >= itemCost[curIndex*8+:8]) begin
				enoughMoney <= 1;
			end else begin
				enoughMoney <= 0;
			end
		end
	end
		
end
	
// Combinational logic	
always @(state, rst, enoughMoney, cancelled, cancelledDone, reduceInventory, nickel_o, dime_o, quarter_o, dollar_o) begin

	if (rst) begin
		// Store credit from company
		newCredit = credBalance;
	end
	
		if ((~reduceInventory && ~reduceInventoryDone) && (~cancelled && ~cancelledDone)) begin	// Not in the middle of dispensing or cancelling a product
			if (~paymentMethod) begin		// cash payment
				if (enoughMoney) begin
					newBalance = newBalance - itemCost[curIndex*8+:8];
					reduceInventoryFlag = 1;
					$display("Product purchased with cash --> newBalance = %d", newBalance);
				end
			end else begin						//  credit card payment
				if (enoughMoney) begin
					newCredit = newCredit - itemCost[curIndex*8+:8];
					reduceInventoryFlag = 1;
					$display("Product purchased with credit --> newCredit = %d", newCredit);
				end	
			end
		end
	
	// Coin balance adjust
	if (nickel_o)  newBalance = newBalance + 3'b101; 		// add 5 to money 
	if (dime_o) newBalance = newBalance + 4'b1010;  		// add 10 to money
	if (quarter_o) newBalance = newBalance + 5'b11001;		// add 25 to money
	if (dollar_o) newBalance = newBalance + 7'b1100100; 	// add 100 to money
	
	if (reduceInventoryFlag) begin
		if (~reduceInventory && ~reduceInventoryDone) begin
			reduceInventory = 1;
			reduceInventoryFlag = 0;
		end
	end
	
	if (reduceInventory && reduceInventoryDone) begin
		reduceInventory = 0;
	end
	
	
	// Cancellation 
	if (cancelled && ~cancelledDone) begin
		change = newBalance;
		newBalance = 0;
		cancelledDone = 1;
	end
	
	if (~cancelled && cancelledDone) begin
		change = 0;
		cancelledDone = 0;
	end
	
	$display("creditBalance: %d, newBalance: %d, itemCost: %b", newCredit, newBalance, itemCost[curIndex*8+:8]);
end

endmodule