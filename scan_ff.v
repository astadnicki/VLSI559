module scan_ff #(parameter N = 1)(clk, rst, se, si, d, q);

input clk;
input rst;
input se;
input [N:0] si;
input [N:0] d;
output reg [N:0] q;

initial begin
	q = 0;
end

always @(posedge clk) begin
	//if (rst) begin
		q <= 0;
	//end else begin
		case (se) 
			1'b0 : q <= d;
			1'b1 : q <= si;
		endcase
	//end
end

endmodule



