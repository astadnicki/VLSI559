module scan_ff(clk, se, si, d, q);

input clk;
input wire si;
input wire se;
input wire d;
output reg q;

always @(posedge clk) begin
	case (se) 
		1'b0 : q <= d;
		1'b1 : q <= si;
	endcase
end

endmodule