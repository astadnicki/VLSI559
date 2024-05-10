module vending_machine (clk, clk2, se, si, rst, index, paymentMethod, creditBalance, nickel, dime, quarter, dollar, cost, cancel, currentInventory, quarter_o, dime_o, nickel_o); 


//***** INPUTS AND OUTPUTS *****//

// Clock signals
input clk;												// 500 KHz clock
input clk2;												// 1 MHz

input [1:0] se;										// Select enable for scan ff
input [5:0] si;										// Scan input for ff
	
input rst;												// Reset     					
input [3:0] index;									// Drink selection
input paymentMethod;									// Payment selection
input [8:0] creditBalance;							// Credit card balance from company (input)
input nickel, dime, quarter, dollar;			// Coin inputs in machine
input [63:0] cost;									// Large register for cost of each item
input cancel;											// User input to cancel selection
input [23:0] currentInventory;					
										

output wire [8:0] quarter_o;						// Change back (quarters)
output wire [8:0] dime_o;							// Change back (dimes)
output wire [8:0] nickel_o;						// Change back (nickels)

wire gclk;												// Gated clocks
wire gclk2;

localparam num_items = 8;							// Number of items in vending machine

wire [31:0] change;									// Change back when process is cancelled by user

wire [3:0] curIndex;									// Current index selection	(output from scan)	

reg clkEnable;											// CLK enable for clock gating
												
reg [3:0] si1=4'b0;
reg [1:0] si2=2'b0;


wire [1:0] state;										// Current state
wire [1:0] nextState;								// Next state					
wire [8:0] newBalance;								// Adjusted balance for addMoney module
wire [8:0] newCredit;								// Adjusted balance for addMoney module

wire reduceBalance;									// Adjust current balance in addMoney module

wire cancelled;

wire fullInventory;
wire reduceInventory;
wire reduceInventoryDone;

wire cancelledDone;
wire changeStateDone;

//***** MODULES *****//

// Dispense change when selection cancelled
dispenseChange change_back(change, rst, quarter_o, dime_o, nickel_o);

// Store selected index
scan_ff #(3) itemSelection(gclk2, rst, se[0], si1, index, curIndex);	// get rid of clock gating to fix not clocking the index;

// Store State
scan_ff stateAdjust(clk2, rst, se[1], si2, nextState, state);

// Clock gating
clockGate gclkCreate(clk2, clkEnable, gclk2); 
clockGate gclk2Create(clk, clkEnable, gclk);

// State machine
stateMachine stateMachine(clk2, rst, state, index, cancel, fullInventory, cancelledDone, changeState, nextState, cancelled, changeStateDone);

// Coin and credit adjustments
addMoney adjustBalance(clk2, rst, state, cancelled, paymentMethod, cost, curIndex, creditBalance, dollar, quarter, dime, nickel, reduceInventoryDone, changeStateDone, fullInventory, reduceInventory, change, cancelledDone, changeState);

// Monitor Inventory
monitorInventory adjustInventory(clk2, rst, state, currentInventory, curIndex, reduceInventory, reduceInventoryDone, fullInventory);


//****** SEQUENTIAL LOGIC *****//

always @ (posedge clk2) begin 
	
	if (rst) begin
		$display("Resetting");
		// Initialize registers
		si1 <= si[3:0];
		si2 <= si[5:4];

		// Initialize
		clkEnable <= 0;
		
	end else begin
		
		//Clock gating enables reading of product selection 
		if (state == 2'b00) begin	
			clkEnable <= 1;
		end else begin
			clkEnable <= 0;
		end
	end
end
endmodule