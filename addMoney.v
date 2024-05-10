module addMoney(clk, rst, state, cancelled, paymentMethod, storeCost, curIndex, credBalance, dollar, quarter, dime, nickel, reduceInventoryDone, changeStateDone, fullInventory, reduceInventory, change, cancelledDone, changeState);

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

input changeStateDone;
input fullInventory;

output reg reduceInventory;
output reg [31:0] change;
output reg cancelledDone;

output reg changeState;

reg [10:0] newBalance;
reg [10:0] newCredit;
reg enoughMoney;

localparam num_items = 8;

reg dollar_o, quarter_o, dime_o, nickel_o;
reg [63:0] itemCost;

reg reduceInventoryFlag;

reg [3:0] prevIndex;		

// Non - Blocking
always @(posedge clk) begin

	if (rst) begin
		// Store item cost into register from scan flip flop
		itemCost <= storeCost;
		enoughMoney = 0;
	end else begin
		
		// Check money to see if there is enough to buy product
		if ((state == 2'b01) && (~cancelled && ~cancelledDone)) begin		// Not in state 3 and not in middle of cancelling a product
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
		
end

// Blocking
always @(posedge clk) begin	//state, rst, enoughMoney, cancelled, cancelledDone, reduceInventory, nickel_o, dime_o, quarter_o, dollar_o

	if (rst) begin
		// Store credit from company
		newCredit = credBalance;
		newBalance = 0;
		reduceInventory = 0;
		reduceInventoryFlag = 0;
		cancelledDone = 0;
		changeState = 0;
	end else begin
		
		// Coin balance adjust
		if (nickel)  newBalance = newBalance + 3'b101; 		// add 5 to money 
		if (dime) newBalance = newBalance + 4'b1010;  		// add 10 to money
		if (quarter) newBalance = newBalance + 5'b11001;		// add 25 to money
		if (dollar) newBalance = newBalance + 7'b1100100; 	// add 100 to money
		
		// Purchase product if specifications are reached
		if ((fullInventory) && (state == 2'b01)) begin	// inventory is full and state is not 11
			if ((~reduceInventory && ~reduceInventoryDone) && (~cancelled && ~cancelledDone)) begin	// Not in the middle of dispensing or cancelling a product
				if (~paymentMethod) begin		// cash payment
					if (enoughMoney) begin
						newBalance = newBalance - itemCost[curIndex*8+:8];
						reduceInventoryFlag = 1;
						$display("Product purchased with cash --> newBalance = %d", newBalance);
					end
				end else if (paymentMethod) begin						//  credit card payment
					if (enoughMoney) begin
						newCredit = newCredit - itemCost[curIndex*8+:8];
						reduceInventoryFlag = 1;
						$display("Product purchased with credit --> newCredit = %d", newCredit);
					end	
				end
				
				// Response and request communication to enable state change to 00 to select new product (1)
				if (~changeState && ~changeStateDone) begin
					changeState = 1;
				end
				
			end
			
		end
		
		// Response and request communication to enable dispensing of product (2)
			if (reduceInventory && reduceInventoryDone) begin
				reduceInventory = 0;
			end
		
		// Response and request communication to enable dispensing of product (1)
		if (reduceInventoryFlag) begin
			if (~reduceInventory && ~reduceInventoryDone) begin
				reduceInventory = 1;
				reduceInventoryFlag = 0;
			end
		end
	
		
		// Response and request communication to enable state change to 00 to select new product (2)
		if (changeState && changeStateDone) begin
			changeState = 0;
		end
		
		
		// Response and request communication for cancellation (1)
		if (cancelled && ~cancelledDone) begin
			change = newBalance;
			newBalance = 0;
			cancelledDone = 1;
		end
		
		// Response and request communication for cancellation (2)
		if (~cancelled && cancelledDone) begin
			cancelledDone = 0;
			change = 0;
		end
		
		
		$display("creditBalance: %d, newBalance: %d, itemCost: %d, current index: %d", newCredit, newBalance, itemCost[curIndex*8+:8], curIndex);
	end
end

endmodule