module scan_ff #(parameter N = 1)(clk, se, si, d, q);

input clk;
input se;
input [N:0] si;
input [N:0] d;
output reg [N:0] q;

initial begin
	// Initialization
	q = 0;
end

always @(posedge clk) begin
	case (se) 
		1'b0 : q <= d;
		1'b1 : q <= si;
	endcase
end

endmodule



