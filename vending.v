module vending (clk, index, paymentMethod, creditBalance, nickel, dime, quarter, dollar, cost, cancel, dispensed, quart, dim, nick, pen); 
						
input clk;     					 // Declare input port for the clock to allow counter to count up  
input [2:0] index;             // chosen drink  
input paymentMethod;
input [8:0] creditBalance;
input nickel, dime, quarter, dollar;
input [63:0] cost;				// keeps track of cost of each item, index is the item you select
input cancel;

output reg dispensed;
output wire [3:0] quart;
output wire [2:0] dim;
output wire [2:0] nick;
output wire [2:0] pen;

localparam num_items = 8;

reg [8:0] change;
reg [7:0] regcost [num_items-1:0];
reg [8:0] creditBalanceReg;					
reg [2:0] currentInventory [num_items-1:0]; // number of items left at that index
reg [8:0] money;	// where the actual dollar amount is money/100. Ex: if money is 256, then we have $2.56
reg [1:0] state;	// keeps track of the current state the state machine is in
reg [2:0] regindex;
reg [8:0] currentBalance;

// This always block will be triggered at the rising edge of clk (0->1)  
// Once inside this block, it checks if the reset is 1, then change out to zero   
// If reset is 0, then the design should be allowed to count up, so increment the counter 

// 00: Select the product
// 01: Insert coins
// 10: Dispensing

dispenseChange change_back(change, quart, dim, nick, pen);

integer counter;	// account for timeout
integer j;

initial begin
	
	counter = 0;
	
	// Load cost and inventory total of each product into memory
	for (j=0; j<=num_items-1; j=j+1) begin
		regcost[j] = cost[j*3+:3];	
		currentInventory[j] = 3'b111;
		
	end
	
	state = 2'b00;	// set initial state
	
	
end
  
always @ (posedge clk) begin  
	currentBalance = currentBalance + money;	// account for coin inputs
	counter = counter + 1;
	dispensed = 1'b0;
	
	if (cancel) begin
		state = 2'b11;
	end

	case (state)
		2'b00 : begin	// Select the product
			if (index != 0) begin	// index of 0 suggests no user input
				regindex = index;
				if (currentInventory[regindex] != 0) begin
					state = 2'b01;
				end else begin
					$display("Out of stock: Please select another item");
					state = 2'b00;
				end
			end
		end
		
		2'b01 : begin	// Payment
		
			case (paymentMethod)	// wait for payment method input
			
				1'b0 : begin // cash/coin payment
		
					$display("Paying with cash --> Current balance: %d", money);
					
					if (counter <= 1000000) begin		// FIX timeout
						if (currentBalance == regcost[regindex]) begin
							$display("Sufficient funds");
							state = 2'b10;	// dispense product
							counter = 0;
						end else if (currentBalance > regcost[regindex]) begin
						// ADD IN MODULO CHANGE CALCULATION FOR NICKELS, DIMES, AND QUARTERS
							$display("Sufficient funds");
							currentBalance = currentBalance - regcost[regindex];
							state = 2'b10; // dispense product 		
							counter = 0;
						end else if (currentBalance < regcost[regindex]) begin
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
					creditBalanceReg = creditBalance;
					if (creditBalanceReg < regcost[regindex]) begin
						$display ("Insufficient funds");
						state=2'b00;
					end else begin
						creditBalanceReg = creditBalanceReg - regcost[regindex];
						state = 2'b10;	// potentially skip state (increment count) since credit card
					end
			
				end
		
			endcase
			
		end
		
		2'b10 : begin
			$display("Dispensing");
			dispensed = 1'b1;
			currentInventory[regindex] = currentInventory[regindex] - 1;
			state = 2'b00;
		end
			
		2'b11 : begin
			$display("Cancelled");
			change = currentBalance; 	// add module to dispense change --> input = change, output = coins
			currentBalance = 1'b0;
			state = 2'b00;	// select product
		end
		
	endcase
end  

// always counting up money
always @ (negedge clk) begin
	if (nickel)  money = money + 3'b101; 	// add 5 to money 
	if (dime) money = money + 4'b1010;  // add 10 to money
	if (quarter) money = money + 5'b11001;		// add 25 to money
	if (dollar) money = money + 7'b1100100; 	// add 100 to money
end
  
endmodule  
