/* Adder that is run through the avalon memory
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
 
logic [63:0] a, b, c, d;
wire [255:0] in; 
assign in = {a, b, c, d};

logic [63:0] e, f, e_d, f_d;
wire [127:0] out;
assign {e, f} = out;

runNetwork network (.*);

always_ff @(posedge clk) begin
    e_d <= e;
    f_d <= f;
end

// AXI Write Controller
always_ff @(posedge clk) begin
    if (reset) begin
        a <= 0;
        b <= 0;
        c <= 0;
        d <= 0;
    end
    else if (avs_s0_write) begin
        case (avs_s0_address)
            3'd0 : begin
                a <= avs_s0_writedata;
                b <= b;
                c <= c;
                d <= d;
            end
            3'd1 : begin
                a <= a;
                b <= avs_s0_writedata;
                c <= c;
                d <= d;
            end
            3'd2 : begin
                a <= a;
                b <= b;
                c <= avs_s0_writedata;
                d <= d;
            end
            3'd3 : begin
                a <= a;
                b <= b;
                c <= c;
                d <= avs_s0_writedata;
            end
            default: begin
                a <= a;
                b <= b;
                c <= c;
                d <= d;
            end
        endcase
    end
    else begin
        a <= a;
        b <= b;
        c <= c;
        d <= d;
    end
end    

//AXI Slave Read Controller
always_comb begin
    if (avs_s0_read) begin
        case (avs_s0_address)
            3'd4 : avs_s0_readdata = e_d;
            3'd5 : avs_s0_readdata = f_d;
            default: avs_s0_readdata = 0;
        endcase
    end
    else begin
        avs_s0_readdata = 'x;
    end
end
           
endmodule