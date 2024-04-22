
// OLD FILE --> DO NOT USE






module vending (clk, rst, index, paymentMethod, creditBalance, nickel, dime, quarter, dollar, cost, cancel, dispensed, quarter_o, dime_o, nickel_o, penny_o); 
						
input clk;
input rst;     					 // Declare input port for the clock to allow counter to count up  
input [2:0] index;             // chosen drink  
input paymentMethod;
input [8:0] creditBalance;
input nickel, dime, quarter, dollar;
input [63:0] cost;				// keeps track of cost of each item, index is the item you select
input cancel;

output reg dispensed;
output wire [3:0] quarter_o;
output wire [2:0] dime_o;
output wire [2:0] nickel_o;
output wire [2:0] penny_o;

localparam num_items = 8;

reg [8:0] change;
reg [7:0] item_cost [num_items-1:0];
reg [8:0] credBalance;					
reg [2:0] currentInventory [num_items-1:0]; // number of items left at that index

wire [8:0] newBalance;	// where the actual dollar amount is money/100. Ex: if money is 256, then we have $2.56

reg [1:0] state;	// keeps track of the current state the state machine is in

reg [2:0] prevIndex;

reg [8:0] currentBalance;
reg [31:0] counter;	// account for timeout
reg se=0, si=0;

// This always block will be triggered at the rising edge of clk (0->1)  
// Once inside this block, it checks if the reset is 1, then change out to zero   
// If reset is 0, then the design should be allowed to count up, so increment the counter 

// 00: Select the product
// 01: Insert coins
// 10: Dispensing

// Dispense change when selection cancelled
dispenseChange change_back(change, quarter_o, dime_o, nickel_o, penny_o);

// Add up coins coming in
addMoney currentBalanceTrack(clk, currentBalance, dollar, quarter, dime, nickel, newBalance);

//scan_ff track_money(clk, se, si, currentBalance, newBalance);


//Initialization 
integer j;
initial begin
	
	counter = 32'b0;	// keep track of clock edges
	
	for (j=0; j<=num_items-1; j=j+1) begin
			item_cost[j] = 8'b0;	
	end
	
	state = 2'b00;	// set initial state
	prevIndex = 3'b0;
	
	// Initialize wallets
	currentBalance = 9'b0;
	
	
end
  
always @ (posedge clk) begin  

	currentBalance = newBalance;

	if (rst) begin
	
		$display("Resetting");
	
		// Load cost and inventory total of each product into memory
		for (j=0; j<=num_items-1; j=j+1) begin
			item_cost[j] = cost[j*8+:8];	
			currentInventory[j] = 3'b111;
		end
		
		// Initialize state, counter, and index
		state = 2'b00;
		counter = 31'b0;
		prevIndex = 3'b0;
		
		currentBalance = 9'b0;
		
	end
	
	counter = counter + 1;
	dispensed = 1'b0;
	
	if (cancel) begin
		state = 2'b11;
	end

	case (state)
		2'b00 : begin	// Select the product
			if (index != prevIndex) begin	// index of 0 suggests no user input
				prevIndex = index;
			
				if (currentInventory[prevIndex] != 0) begin
					state = 2'b01;
				end else begin
					$display("Out of stock: Please select another item: %d", currentInventory[prevIndex]);
					state = 2'b00;
				end
			end
		end
		
		2'b01 : begin	// Payment
		
			case (paymentMethod)	// wait for payment method input
			
				1'b0 : begin // cash/coin payment
		
					$display("Paying with cash --> Current balance: %d", currentBalance);
					
					if (counter <= 32'd1500000000) begin		// timeout at 15 seconds
						if (currentBalance >= item_cost[prevIndex]) begin
							$display("Sufficient funds");
							currentBalance = currentBalance - item_cost[prevIndex];
							state = 2'b10; // dispense product 		
							counter = 0;
						end else if (currentBalance < item_cost[prevIndex]) begin
							$display("Insufficient funds");
							state = 2'b01;
						end
						
					end else begin
						$display("Timeout limit reached");
						state = 2'b11;
					end
				
				end
			
				1'b1 : begin // credit card payment
			
					$display("Paying with credit card");
					credBalance = creditBalance;
					if (credBalance < item_cost[prevIndex]) begin
						$display ("Insufficient funds");
						state=2'b00;
					end else begin
						credBalance = credBalance - item_cost[prevIndex];
						state = 2'b10;	// potentially skip state (increment count) since credit card
					end
			
				end
		
			endcase
			
		end
		
		2'b10 : begin
			dispensed = 1'b1;
			currentInventory[prevIndex] = currentInventory[prevIndex] - 1;
			state = 2'b00;
			$display("Dispensing --> Item Cost: %d, Credit balance: %d, Coin Balance: %d, Current inven: %d", item_cost[prevIndex], credBalance, currentBalance, currentInventory[prevIndex]);
		end
			
		2'b11 : begin
			$display("Cancelled");
			change = currentBalance; 	// add module to dispense change --> input = change, output = coins
			$display("%d", change);
			currentBalance = 9'b0;
			state = 2'b00;	// select product
		end
		
	endcase
end  

  
endmodule  
