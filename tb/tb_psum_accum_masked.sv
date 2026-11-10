 \`timescale 1ns/1ps
module tb_psum_accum_masked;
    localparam N     = 8;
    localparam XW    = 12;
    localparam COLS  = 1;
    localparam DEPTH = 2;
    localparam AW    = 2;

    reg clk = 1'b0;
    always #5 clk = ~clk;

    reg reset_n;
    reg tile_start;
    reg first_tile;
    reg last_tile;
    reg [COLS-1:0] valid_in;
    reg [COLS*XW-1:0] psum0_in;
    reg [COLS*XW-1:0] psum1_in;

    wire [COLS*XW-1:0] psum0_out;
    wire [COLS*XW-1:0] psum1_out;
    wire [COLS-1:0] valid_out;
    wire [COLS-1:0] ovf;

    integer errors = 0;

    psum_accum_masked #(
        .N(N),
        .XW(XW),
        .COLS(COLS),
        .DEPTH(DEPTH),
        .AW(AW)
    ) dut (
        .clk(clk),
        .reset_n(reset_n),
        .tile_start(tile_start),
        .first_tile(first_tile),
        .last_tile(last_tile),
        .valid_in(valid_in),
        .psum0_in(psum0_in),
        .psum1_in(psum1_in),
        .psum0_out(psum0_out),
        .psum1_out(psum1_out),
        .valid_out(valid_out),
        .ovf(ovf)
    );

    task drive_cycle;
        input ts;
        input ft;
        input lt;
        input vi;
        input [XW-1:0] in0;
        input [XW-1:0] in1;
        begin
            @(negedge clk);
            tile_start = ts;
            first_tile = ft;
            last_tile  = lt;
            valid_in   = vi;
            psum0_in   = in0;
            psum1_in   = in1;
            @(posedge clk);
            #1;
        end
    endtask

    task expect_state;
        input [XW-1:0] expected0;
        input [XW-1:0] expected1;
        input expected_valid;
        input expected_overflow;
        begin
            if (psum0_out !== expected0 ||
                psum1_out !== expected1 ||
                valid_out[0] !== expected_valid ||
                ovf[0] !== expected_overflow) begin
                $display("[FAIL] got share0=%0d share1=%0d valid=%b overflow=%b; expected share0=%0d share1=%0d valid=%b overflow=%b",
                         psum0_out, psum1_out, valid_out[0], ovf[0],
                         expected0, expected1, expected_valid, expected_overflow);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        reset_n   = 1'b0;
        tile_start = 1'b0;
        first_tile = 1'b1;
        last_tile  = 1'b0;
        valid_in   = '0;
        psum0_in   = '0;
        psum1_in   = '0;

        repeat (2) @(posedge clk);
        #1;
        expect_state(0, 0, 0, 0);

        // First tile: store two independent share pairs.
        drive_cycle(1, 1, 1, 0, 0, 0);
        expect_state(0, 0, 0, 0);

        drive_cycle(0, 1, 1, 1, 10, 3);
        expect_state(10, 3, 1, 0);

        drive_cycle(0, 1, 1, 1, 2, 5);
        expect_state(2, 5, 1, 0);

        // A third write exceeds DEPTH and must set the overflow flag.
        drive_cycle(0, 1, 1, 1, 99, 99);
        expect_state(2, 5, 1, 1);

        // Next tile accumulates new shares with the previously stored shares.
        drive_cycle(1, 0, 0, 0, 0, 0);
        expect_state(2, 5, 0, 0);

        drive_cycle(0, 0, 1, 1, 7, 1);
        expect_state(17, 4, 1, 0);

        drive_cycle(0, 0, 1, 1, 9, 6);
        expect_state(11, 11, 1, 0);

        // valid_out is gated by last_tile.
        drive_cycle(1, 1, 0, 0, 0, 0);
        drive_cycle(0, 1, 0, 1, 4, 5);
        expect_state(4, 5, 0, 0);

        // Synchronous reset clears the output registers and status flags.
        @(negedge clk);
        reset_n = 1'b0;
        valid_in = '0;
        tile_start = 1'b0;
        @(posedge clk);
        #1;
        expect_state(0, 0, 0, 0);

        if (errors == 0) begin
            $display("[PASS] tb_psum_accum_masked: all checks passed.");
            $finish;
        end else begin
            $fatal(1, "[FAIL] tb_psum_accum_masked: %0d check(s) failed.", errors);
        end
    end
endmodule
