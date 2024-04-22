module vending_machine (clk, clk2, rst, index, paymentMethod, creditBalance, nickel, dime, quarter, dollar, cost, cancel, currentInventory, quarter_o, dime_o, nickel_o, gclk); 


//***** INPUTS AND OUTPUTS *****//

// Clock signals
input clk;
input clk2;

input rst;												//reset     					
input [3:0] index;									//drink selection
input paymentMethod;									//payment selection
input [8:0] creditBalance;							//credit card balance from company (input)
input nickel, dime, quarter, dollar;			// coin inputs in machine
input [63:0] cost;									// large register for cost of each item
input cancel;											// user input to cancel selection
input [23:0] currentInventory;
										

output wire [4:0] quarter_o;
output wire [4:0] dime_o;
output wire [4:0] nickel_o;
output wire gclk;

localparam num_items = 8;

wire [8:0] change;									// Change back when selection or process is cancelled
wire [8:0] credBalance;							   // Adjust credit balance
wire [23:0] curInventory;

wire [3:0] curIndex;									// current index selection		
wire [8:0] currentBalance;							

reg [31:0] counter;									// account for timeout functionality
reg clkEnable;

reg se=0;												// CREATE LARGE REGISTER TO STORE ALL ACCUMULATED VALUES
reg [3:0] si=4'b0;
reg [8:0] si1=8'b0;
reg [1:0] si2=2'b0;
reg [23:0] si3=24'b0;
reg [63:0] si4=64'b0;

wire [63:0] storeCost;

wire [1:0] state;										// current state
wire [1:0] nextState;									
wire [8:0] newBalance;								// Adjusted balance for addMoney module
wire [8:0] newCredit;								// Adjusted balance for addMoney module

wire reduceBalance;									// Adjust current balance
wire dispensed;

wire cancelled;

reg timeOut;
wire fullInventory;
wire reduceInventory;
wire reduceInventoryDone;

wire cancelledDone;

//***** MODULES *****//

// Dispense change when selection cancelled
dispenseChange change_back(change, quarter_o, dime_o, nickel_o);

// Store selected index
scan_ff #(3) itemSelection(gclk, se, si, index, curIndex);

// Store State
scan_ff stateAdjust(clk2, se, si2, nextState, state);

// Clock gating
clockGate gclkCreate(clk2, clkEnable, gclk); 

// State machine
stateMachine stateMachine(clk2, state, cancel, fullInventory, timeOut, cancelledDone, nextState, dispensed, cancelled);

// Store cost
scan_ff #(63) updateCost(clk, se, si4, cost, storeCost);		// lower frequency clock to save power

// Coin and credit adjustments
addMoney adjustBalance(clk2, rst, state, cancelled, paymentMethod, storeCost, curIndex, credBalance, dollar, quarter, dime, nickel, reduceInventoryDone, reduceInventory, change, cancelledDone);

// Store credit balance 
scan_ff #(8) credAdjust(clk2, se, si1, creditBalance, credBalance);	// add clock gating for both this and current inventory

// Store current inventory
scan_ff #(23) InventoryAdjust(clk2, se, si3, currentInventory, curInventory);

// Monitor Inventory
monitorInventory adjustInventory(clk2, rst, state, curInventory, curIndex, reduceInventory, reduceInventoryDone, fullInventory);


//***** INITIALIZATION *****//

initial begin

	// Initialize counter
	counter = 32'b0;	// keep track of timeout clock
	
	// Initialize
	clkEnable = 0;
	timeOut = 0;
		
end


//****** SEQUENTIAL LOGIC *****//

always @ (posedge clk2) begin 
	
	if (rst) begin
		$display("Resetting");
		// Initialize registers
		counter <= 32'b0;
	end
	
	//Increment counter every clock edge
	if (state == 2'b01) begin
		counter <= counter + 1;
	end else begin
		counter <= 32'b0;
	end
	
	$display("state: %d, counter: %d, curIndex: %d", state, counter, curIndex);
	
	// Time out functionality
	if (counter <= 20) begin		// 32'd1500000000 --> 30 seconds
		timeOut <= 0;
	end else begin
		timeOut <= 1;
		counter <= 32'b0;
	end
	
	//Clock gating enables reading of product selection 
	if (state == 2'b00) begin	
		clkEnable <= 1;
	end else begin
		clkEnable <= 0;
	end
end
endmodule