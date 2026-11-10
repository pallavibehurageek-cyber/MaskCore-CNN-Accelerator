// Partial-sum accumulator on arithmetic shares, same behaviour as psum_accum
module psum_accum_masked #(
    parameter N     = 8,
    parameter XW    = 18,
    parameter COLS  = 5,
    parameter DEPTH = 32,
    parameter AW    = 6
)(
    input  wire                 clk,
    input  wire                 reset_n,
    input  wire                 tile_start,
    input  wire                 first_tile,
    input  wire                 last_tile,
    input  wire [COLS-1:0]      valid_in,
    input  wire [COLS*XW-1:0]   psum0_in,
    input  wire [COLS*XW-1:0]   psum1_in,
    output wire [COLS*XW-1:0]   psum0_out,
    output wire [COLS*XW-1:0]   psum1_out,
    output wire [COLS-1:0]      valid_out,
    output wire [COLS-1:0]      ovf
);
    genvar c;
    generate
        for (c = 0; c < COLS; c = c + 1) begin : g_lane
            reg [XW-1:0] mem0 [0:DEPTH-1];
            reg [XW-1:0] mem1 [0:DEPTH-1];
            reg [AW-1:0] addr;
            reg [XW-1:0] acc0_r, acc1_r;
            reg          vld_r, ovf_r;

            wire [XW-1:0] din0  = psum0_in[c*XW +: XW];
            wire [XW-1:0] din1  = psum1_in[c*XW +: XW];
            wire [XW-1:0] prev0 = first_tile ? {XW{1'b0}} : mem0[addr];
            wire [XW-1:0] prev1 = first_tile ? {XW{1'b0}} : mem1[addr];
            wire [XW-1:0] sum0  = din0 + prev0;
            wire [XW-1:0] sum1  = din1 + prev1;

            always @(posedge clk) begin
                if (!reset_n) begin
                    addr   <= {AW{1'b0}};
                    acc0_r <= {XW{1'b0}};
                    acc1_r <= {XW{1'b0}};
                    vld_r  <= 1'b0;
                    ovf_r  <= 1'b0;
                end else begin
                    if (tile_start) begin
                        addr  <= {AW{1'b0}};
                        ovf_r <= 1'b0;
                    end
                    vld_r <= valid_in[c] & last_tile;
                    if (valid_in[c]) begin
                        if (addr >= DEPTH) begin
                            ovf_r <= 1'b1;
                        end else begin
                            mem0[addr] <= sum0;
                            mem1[addr] <= sum1;
                            acc0_r     <= sum0;
                            acc1_r     <= sum1;
                            if (!tile_start) addr <= addr + 1;
                        end
                    end
                end
            end
            assign psum0_out[c*XW +: XW] = acc0_r;
            assign psum1_out[c*XW +: XW] = acc1_r;
            assign valid_out[c]          = vld_r;
            assign ovf[c]                = ovf_r;
        end
    endgenerate
endmodule
