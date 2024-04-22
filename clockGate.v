module clockGate(clk, clkEnable, gclk);

input clk;
input clkEnable;

output wire gclk;

assign gclk = clk & clkEnable;

endmodule