module stateMachine(clk, state, cancel, fullInventory, timeOut, cancelledDone, nextState, dispensed, cancelled);

input clk;
input [1:0] state;
input cancel;
input fullInventory;
input timeOut;
input cancelledDone;

output reg [1:0] nextState;
output reg dispensed;
output reg cancelled;


initial begin
//Initial state
	nextState = 2'b0;
	cancelled = 0;
end


// Sequential Logic
always @(posedge clk) begin
	
	if (fullInventory) begin
		nextState <= 2'b01;
	end else begin
		$display("Out of stock: Please select another item");
		nextState <= 2'b00;
	end
	
	if (timeOut || cancel) begin
		nextState <= 2'b11;
	end

	case (state)					
		2'b11 : begin
			$display("Cancelled");
			if (~cancelled && ~cancelledDone) begin
				cancelled <= 1; 	// add module to dispense change --> input = change, output = coins
			end
			
			if (cancelled && cancelledDone) begin
				cancelled <= 0;
				nextState <= 2'b00;	// select product
			end
		end
		
	endcase
end

endmodule