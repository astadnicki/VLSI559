module monitorInventory(clk, rst, state, curInventory, curIndex, reduceInventory, reduceInventoryDone, fullInventory);

input clk;
input rst;
input [1:0] state;
input [23:0] curInventory;
input [3:0] curIndex; 
input reduceInventory;

output reg reduceInventoryDone;
output reg fullInventory; 

reg [23:0] newInventory;

// Sequential Logic
always @(posedge clk) begin
	
	if (rst) begin
		fullInventory <= 0;
	end else begin

		if (newInventory[curIndex*3+:3] != 0) begin
			fullInventory <= 1;
		end else begin
			fullInventory <= 0;
		end
	end
end

// Combinational Logic
always @(*) begin
	if (rst) begin
		newInventory = curInventory;
		reduceInventoryDone = 0;
	end else begin
		if (reduceInventory && ~reduceInventoryDone) begin
			newInventory[curIndex*3+:3] = newInventory[curIndex*3+:3] - 1;
			$display("monitorInventory: Product Dispensed!");
			$display("Current Inventory: %d", newInventory[curIndex*3+:3]);
			reduceInventoryDone = 1;
		end
		if (~reduceInventory && reduceInventoryDone) begin
			reduceInventoryDone = 0;
		end
	end
end
endmodule