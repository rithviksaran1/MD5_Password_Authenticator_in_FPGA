`timescale 1ns / 1ns
module tbtb;

    // Testbench signals
    reg clk;
    reg reset;
    reg [3:0] s_axis_tdata;
    wire s_axis_ready;
    wire m_axis_tdata;
    wire [127:0]f;
    wire [3:0]out;

    // Instantiate the control module
    control uut (
        .clk(clk),
        .reset(reset),
        .s_axis_tdata(s_axis_tdata),
        .out(out),
        .s_axis_ready(s_axis_ready),
        .m_axis_tdata(m_axis_tdata)
        );

    // Clock generation (10ns period)
    always #5 clk = ~clk;

    initial begin
        // Initialize
        clk = 0;
        reset = 0;
        s_axis_tdata = 32'd0;

        //Apply reset
        #20;
        reset = 1;

        
        s_axis_tdata = 4'b1010; // ASCII string packed into 56-bit
        
        
        //Wait for done signal
        wait (s_axis_ready == 1);
        #10;
        
        $finish;
    end

endmodule
