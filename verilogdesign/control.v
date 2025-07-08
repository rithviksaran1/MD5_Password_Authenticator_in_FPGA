//The top-level module of the MD5 project
`timescale 1ns / 1ps

module control (
    input clk,
    input reset,  
    input [3:0] s_axis_tdata,   //ascii_str   
    output reg s_axis_ready,     //done
    output reg m_axis_tdata,     //match              
    output reg [3:0] out   
    );

    //reg [127:0] final_hash;
    wire [63:0] hex_out;
    reg [127:0] data_i;
    wire [127:0] data_o;
    wire ready_o;
    reg load_i, newtext_i;
    reg [127:0] f;
    
    always @ (posedge clk) begin
    out <= s_axis_tdata;
end

    reg [2:0] state, next_state;

    
    localparam IDLE       = 3'd0;
    localparam START      = 3'd1;
    localparam LOAD1      = 3'd2;
    localparam LOAD2      = 3'd3;
    localparam LOAD3      = 3'd4;
    localparam LOAD4      = 3'd5;
    localparam WAIT_HASH  = 3'd6;
    localparam DONE       = 3'd7;

    
    string2hex s2h (
        .ascii_str(s_axis_tdata),
        .hex_out(hex_out)
    );

    
    md5 md5_core (
        .clk(clk),
        .reset(reset),
        .load_i(load_i),
        .newtext_i(newtext_i),
        .data_i(data_i),
        .data_o(data_o),
        .ready_o(ready_o)
    );
    
    always @(posedge clk or negedge reset) begin
        if (!reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    
    always @(*) begin
        load_i = 0;
        newtext_i = 0;
        next_state = state;

        case (state)
            IDLE:       next_state = START;

            START: begin
                newtext_i = 1;
                next_state = LOAD1;
            end

            LOAD1: begin
                load_i = 1;
                next_state = LOAD2;
            end

            LOAD2: begin
                load_i = 1;
                next_state = LOAD3;
            end

            LOAD3: begin
                load_i = 1;
                next_state = LOAD4;
            end

            LOAD4: begin
                load_i = 1;
                next_state = WAIT_HASH;
            end

            WAIT_HASH: begin
                if (ready_o)
                    next_state = DONE;
            end

            DONE: next_state = IDLE; 
        endcase
    end

    
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            data_i <= 0;
            s_axis_ready <= 0;
            m_axis_tdata <= 0;
            f<=0;
        end else begin
            case (state)
                LOAD1: data_i <= {hex_out, 64'd0};
                LOAD2: data_i <= 128'h0000000000000000_0000000000000000;
                LOAD3: data_i <= 128'h0000000000000000_0000000000000000;
                LOAD4: data_i <= 128'h0000000000000000_3800000000000000;
                WAIT_HASH: begin
                    if (ready_o) begin
                        if (data_o == 128'h310e513993d8fd205f94205a491dae49) begin
                            m_axis_tdata <= 1'b1;
                        end else begin
                            m_axis_tdata <= 1'b0;
                        end
                        //f<=data_o;
                        s_axis_ready <= 1'b1; 
                    end
                end
                //DONE: begin
                  //m_axis_tdata <= 1'b1; 
                //end
            endcase
        end
    end
endmodule
