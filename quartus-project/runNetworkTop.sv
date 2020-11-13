/* Run the 2D neural network at once
 */
 
module runNetworkTop(
  input  logic        clk,
  input  logic        reset,
  
  // Memory mapped read/write slave interface
  input  logic  [3:0] avs_s0_address,  // avs_s0.address
  input  logic        avs_s0_read,     // avs_s0.read
  input  logic        avs_s0_write,    // avs_s0.write
  output logic [31:0] avs_s0_readdata, // avs_s0.readdata
  input  logic [31:0] avs_s0_writedata // avs_s0.writedata
);
 
logic [31:0] a, b;
wire [63:0] in; 
assign in = {a, b};

logic [31:0] c, c_d;
wire [31:0] out;
assign c = out;

runNetwork network (.in (in), .out (out));

always_ff @(posedge clk) begin
    c_d <= c;
end

// AXI Write Controller
always_ff @(posedge clk) begin
    if (reset) begin
        a <= 0;
        b <= 0;
    end
    else if (avs_s0_write) begin
        case (avs_s0_address)
            3'd0 : begin
                a <= avs_s0_writedata;
                b <= b;
            end
            3'd1 : begin
                a <= a;
                b <= avs_s0_writedata;
            end
            default: begin
                a <= a;
                b <= b;
            end
        endcase
    end
    else begin
        a <= a;
        b <= b;
    end
end    

//AXI Slave Read Controller
always_comb begin
    if (avs_s0_read) begin
        case (avs_s0_address)
            3'd0 : avs_s0_readdata = a;
            3'd1 : avs_s0_readdata = b;
            3'd2 : avs_s0_readdata = c_d;
            default: avs_s0_readdata = 0;
        endcase
    end
    else begin
        avs_s0_readdata = 'x;
    end
end
           
endmodule