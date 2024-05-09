module stateMachine(clk, state, index, cancel, fullInventory, cancelledDone, changeState, nextState, cancelled, changeStateDone);

input clk;
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

initial begin
	//Initial state
	nextState = 2'b0;
	cancelled = 0;
	changeStateDone = 0;
	counter = 0;
end


// Sequential Logic
always @(posedge clk) begin

	$display("counter: %d, state: %d", counter, nextState);
	counter <= counter + 1;

	// Time out functionality
	if (counter > 40) begin
		nextState <= 2'b11;
		counter <= 0;
	end else if (fullInventory) begin
		nextState <= 2'b01;
	end else if (~fullInventory) begin
		$display("Out of stock: Please select another item");
		nextState <= 2'b00;
	end
	
	// Initialize to state 00 after dispensing product (look for index again)
	if (changeState && ~changeStateDone) begin
		nextState <= 2'b00;
		changeStateDone <= 1;
	end
	
	if (~changeState && changeStateDone) begin
		changeStateDone <= 0;
	end
	case (state)					
		2'b11 : begin
			$display("Cancelled");
			if (~cancelled && ~cancelledDone) begin
				cancelled <= 1; 
				nextState <= 2'b00;	// select product
			end
			
			if (cancelled && cancelledDone) begin
				cancelled <= 0;
				
			end
		end
		
	endcase
end

endmodule