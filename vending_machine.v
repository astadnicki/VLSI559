module vending_machine (clk, clk2, se, si, rst, index, paymentMethod, creditBalance, nickel, dime, quarter, dollar, cost, cancel, currentInventory, quarter_o, dime_o, nickel_o, gclk); 


//***** INPUTS AND OUTPUTS *****//

// Clock signals
input clk;												// 500 KHz clock
input clk2;												// 1 MHz

input [4:0] se;										// Select enable for scan ff
input [101:0] si;										// Scan input for ff
	
input rst;												// Reset     					
input [3:0] index;									// Drink selection
input paymentMethod;									// Payment selection
input [8:0] creditBalance;							// Credit card balance from company (input)
input nickel, dime, quarter, dollar;			// Coin inputs in machine
input [63:0] cost;									// Large register for cost of each item
input cancel;											// User input to cancel selection
input [23:0] currentInventory;					
										

output wire [4:0] quarter_o;						// Change back (quarters)
output wire [4:0] dime_o;							// Change back (dimes)
output wire [4:0] nickel_o;						// Change back (nickels)

output wire gclk;										// Gated clocks

localparam num_items = 8;							// Number of items in vending machine

wire [8:0] change;									// Change back when process is cancelled by user
wire [8:0] credBalance;							   // Credit balance ouput wire for scan functionality
wire [23:0] curInventory;							// Product inventory list (3 bits for each item)

wire [3:0] curIndex;									// Current index selection	(output from scan)	

reg [31:0] counter;									// Account for timeout functionality
reg clkEnable;											// CLK enable for clock gating
												
reg [3:0] si1=4'b0;
reg [8:0] si2=8'b0;
reg [1:0] si3=2'b0;
reg [23:0] si4=24'b0;
reg [63:0] si5=64'b0;

wire [63:0] storeCost;

wire [1:0] state;										// Current state
wire [1:0] nextState;								// Next state					
wire [8:0] newBalance;								// Adjusted balance for addMoney module
wire [8:0] newCredit;								// Adjusted balance for addMoney module

wire reduceBalance;									// Adjust current balance in addMoney module

wire cancelled;

reg timeOut;
wire fullInventory;
wire reduceInventory;
wire reduceInventoryDone;

wire cancelledDone;
wire changeStateDone;

//***** MODULES *****//

// Dispense change when selection cancelled
dispenseChange change_back(change, quarter_o, dime_o, nickel_o);

// Store selected index
scan_ff #(3) itemSelection(gclk2, se[0], si1, index, curIndex);	// get rid of clock gating to fix not clocking the index;

// Store State
scan_ff stateAdjust(clk2, se[2], si3, nextState, state);

// Clock gating
clockGate gclkCreate(clk2, clkEnable, gclk2); 
clockGate gclk2Create(clk, clkEnable, gclk);

// State machine
stateMachine stateMachine(clk2, state, index, cancel, fullInventory, timeOut, cancelledDone, changeState, nextState, cancelled, changeStateDone);

// Store cost
scan_ff #(63) updateCost(clk2, se[4], si5, cost, storeCost);		// lower frequency clock to save power but must align with edges

// Coin and credit adjustments
addMoney adjustBalance(clk2, rst, state, cancelled, paymentMethod, storeCost, curIndex, credBalance, dollar, quarter, dime, nickel, reduceInventoryDone, changeStateDone, reduceInventory, change, cancelledDone, changeState);

// Store credit balance 
scan_ff #(8) credAdjust(clk2, se[1], si2, creditBalance, credBalance);

// Store current inventory
scan_ff #(23) InventoryAdjust(clk2, se[3], si4, currentInventory, curInventory);

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
		si1 <= si[3:0];
		si2 <= si[11:4];
		si3 <= si[13:12];
		si4 <= si[37:14];
		si5 <= si[101:38];
		
	end
	
	//Increment counter every clock edge
	counter <= counter + 1;
	
	$display("state: %d, counter: %d, curIndex: %d", state, counter, curIndex);
	
	// Time out functionality
	if (counter <= 40) begin		// 32'd1500000000 --> 30 seconds
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