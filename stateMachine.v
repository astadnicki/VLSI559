module stateMachine(clk, rst, state, index, cancel, fullInventory, cancelledDone, changeState, nextState, cancelled, changeStateDone);

input clk;
input rst;
input [1:0] state;
input [3:0] index;
input cancel;
input fullInventory;
input cancelledDone;

input changeState;

output reg [1:0] nextState;
output reg cancelled;

output reg changeStateDone;

reg [31:0] counter;

// Sequential Logic
always @(posedge clk) begin

	if (rst) begin
		nextState <= 2'b0;
		cancelled <= 0;
		changeStateDone <= 0;
		counter <= 0;
	end else begin
	
		$display("counter: %d, state: %d", counter, nextState);
		counter <= counter + 1;

		case (state)

			2'b00 : begin
				if (fullInventory) begin
					nextState <= 2'b01;
				end else if (~fullInventory) begin
					$display("Out of stock: Please select another item");
					nextState <= 2'b00;
				end 
			end
			
			2'b01 : begin
				if (changeState && ~changeStateDone) begin
					nextState <= 2'b00;
					changeStateDone <= 1;
				end
			
				// Response and request communication to initialize state 00 after dispensing product (2)
				if (~changeState && changeStateDone) begin
					changeStateDone <= 0;
				end
			end
			
			2'b11 : begin
				$display("Cancelled");
				// Response and request communication to enable cancellation (1)
				if (~cancelled && ~cancelledDone) begin
					cancelled <= 1; 
				end
				
				// Response and request communication to enable cancellation (2)
				if (cancelled && cancelledDone) begin
					cancelled <= 0;
					nextState <= 2'b00;	// select product
					$display("CANCELLED BITCH");
					
				end
			end
			
		endcase
		
		// Time out functionality
		if ((counter > 40) ||(cancel)) begin
			nextState <= 2'b11;
			counter <= 0;
		end 
	end
end

endmodule