`timescale 1ns / 1ps

module dispenseChange_tb;

// Parameters
parameter CLK_PERIOD = 10; // Clock period in ns

// Inputs
reg [8:0] change;
reg clk;

// Outputs
wire [3:0] quarters;
wire [2:0] dimes;
wire [2:0] nickels;
wire [2:0] pennies;

// Instantiate the Unit Under Test (UUT)
dispenseChange dut(
    .change(change),
    .quarters(quarters),
    .dimes(dimes),
    .nickels(nickels),
	 .pennies(pennies)
);

// Clock generation
always #((CLK_PERIOD)/2) clk = ~clk;

// Stimulus
initial begin
    // Initialize inputs
    change = 0;
    clk = 0;

    // Apply stimulus
    #10 change = 37; // $37 in cents

    // Wait for some time
    #100 $finish;
end

// Display simulation results
initial begin
    $monitor("Time=%t, Change=%d, Quarters=%d, Dimes=%d, Nickels=%d, Pennies=%d", $time, change, quarters, dimes, nickels, pennies);
end

endmodule
