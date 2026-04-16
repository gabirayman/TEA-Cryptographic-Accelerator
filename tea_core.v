`include "tea_round.v"

module tea_core (
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire [63:0] plaintext,
    input wire [127:0] key,
    output reg [63:0] ciphertext,
    output reg valid,
    output reg ready
);

// Constants and state definitions
localparam DELTA = 32'h9E3779B9;
localparam STATE_IDLE = 2'b00;
localparam STATE_WORK = 2'b01;
localparam STATE_DONE = 2'b10;
reg [1:0] current_state, next_state;

// Internal registers
reg [63:0] v_reg;
reg [31:0] sum;
reg [5:0] count;

// Internal wires
wire [31:0] next_sum = sum + DELTA;
wire [63:0] v_next;

// Instantiate the tea_round module
tea_round engine (
        .v(v_reg),
        .k(key),
        .sum(next_sum), 
        .out(v_next)
    );

// block for pos edge
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= STATE_IDLE;
        ciphertext <= 64'd0;
        v_reg <= 64'd0;
        sum <= 32'd0;
        count <= 6'd0;
    end else begin
        current_state <= next_state;
        case(current_state)
            STATE_IDLE: begin
                if (start) begin
                    v_reg <= plaintext;
                    sum <= 32'd0;
                    count <= 6'd0;
                end
            end
            STATE_WORK: begin
                v_reg <= v_next;
                sum <= next_sum;
                count <= count + 1;
            end
            STATE_DONE: begin
                ciphertext <= v_reg;
            end
        endcase
    end
end

// block for combinational logic and state transition
always @(*) begin
    next_state = current_state;
    ready = 1'b0;
    valid = 1'b0;

    case(current_state)
        STATE_IDLE: begin
            ready = 1'b1;
            if (start) begin
                next_state = STATE_WORK;
            end
        end
        STATE_WORK: begin
            if (count == 6'd31) begin
                next_state = STATE_DONE;
            end else begin
                next_state = STATE_WORK;
            end
        end
        STATE_DONE: begin
            valid = 1'b1;
            next_state = STATE_IDLE;
        end
        default: next_state = STATE_IDLE;
    endcase
end
endmodule
