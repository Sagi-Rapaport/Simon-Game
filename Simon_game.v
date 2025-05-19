module Simon_game (
    input wire clk,
    input wire [7:0] SW,
    output reg [7:0] LED,
    output reg [6:0] HEX
);

// === Internal Wires & Registers ===
wire [2:0] rand_num;
wire slow_clock;
wire rst;

reg [23:0] led_sequence;
reg [23:0] sw_sequence;
reg [3:0] index;
reg [2:0] state;
reg [7:0] sw_prev;
reg sw_event;
reg [2:0] sw_index;

// === State Encoding ===
localparam START = 0,
           GENERATE_LED = 1,
           DISPLAY = 2,
           INPUT = 3,
           CHECK = 4,
           DONE = 5;

// === Clock Divider ===
slow_clock_1Hz slow_clock_1Hz(
    .clk_in(clk),
    .clk_out(slow_clock)
);

// === Random Number Generator ===
lfsr lfsr(
    .clk(slow_clock),
    .rst(rst),
    .rand_num(rand_num)
);

// === One-Time Reset Pulse ===
create_reset create_reset(
    .clk(slow_clock),
    .rst(rst)
);

// === Main Game FSM ===
always @(posedge slow_clock or posedge rst) begin
    if (rst) begin
        LED <= 0;
        HEX <= 7'b0000000;
        state <= START;
        index <= 0;
        led_sequence <= 0;
        sw_sequence <= 0;
        sw_prev <= SW;
    end else begin
        case (state)
            START: begin
                index <= 0;
                state <= GENERATE_LED;
            end
            GENERATE_LED: begin
                if (index == 0) begin
                    led_sequence[23 -: 3] <= 3'b101; // Start with LED[5]
                    index <= index + 1;
                end else if (index < 8) begin
                    led_sequence[23 - index*3 -: 3] <= rand_num;
                    index <= index + 1;
                end else begin
                    index <= 0;
                    state <= DISPLAY;
                end
            end
            DISPLAY: begin
                LED <= 0;
                case (led_sequence[23 - index*3 -: 3])
                    3'd0: LED[0] <= 1;
                    3'd1: LED[1] <= 1;
                    3'd2: LED[2] <= 1;
                    3'd3: LED[3] <= 1;
                    3'd4: LED[4] <= 1;
                    3'd5: LED[5] <= 1;
                    3'd6: LED[6] <= 1;
                    3'd7: LED[7] <= 1;
                endcase
                index <= index + 1;
                if (index == 8) begin
                    index <= 0;
                    LED <= 0;
                    state <= INPUT;
                end
            end
            INPUT: begin
                sw_event <= |(SW ^ sw_prev);
                if (sw_event) begin
                    // Detect which switch was toggled
                    if (SW[0] != sw_prev[0]) sw_index <= 3'd0;
                    else if (SW[1] != sw_prev[1]) sw_index <= 3'd1;
                    else if (SW[2] != sw_prev[2]) sw_index <= 3'd2;
                    else if (SW[3] != sw_prev[3]) sw_index <= 3'd3;
                    else if (SW[4] != sw_prev[4]) sw_index <= 3'd4;
                    else if (SW[5] != sw_prev[5]) sw_index <= 3'd5;
                    else if (SW[6] != sw_prev[6]) sw_index <= 3'd6;
                    else if (SW[7] != sw_prev[7]) sw_index <= 3'd7;

                    sw_sequence[23 - index*3 -: 3] <= sw_index;
                    sw_prev <= SW;
                    index <= index + 1;

                    if (index == 8) begin
                        state <= CHECK;
                        index <= 0;
                    end
                end
            end
            CHECK: begin
                HEX <= (led_sequence == sw_sequence) ? 7'b1111001 : 7'b1000000; // 1 or 0
                state <= DONE;
            end
            DONE: begin
                // Wait for restart
            end
        endcase
    end
end

endmodule

// === 1Hz Clock Divider ===
module slow_clock_1Hz(
    input wire clk_in,
    output reg clk_out
);
reg [25:0] count = 0;
always @(posedge clk_in) begin
    count <= count + 1;
    if (count == 25_000_000) begin
        count <= 0;
        clk_out <= !clk_out;
    end
end
endmodule

// === LFSR Random Generator ===
module lfsr(
    input wire clk,
    input wire rst,
    output reg [2:0] rand_num
);
    always @(posedge clk) begin
        if (rst)
            rand_num <= 3'b101;
        else
            rand_num <= {rand_num[1:0], rand_num[2]^rand_num[1]};
    end
endmodule

// === Simple One-Time Reset Generator ===
module create_reset(
    input wire clk,
    output reg rst
);
reg [2:0] counter = 0;
always @(posedge clk) begin
    if (counter < 1) begin
        counter <= counter + 1;
        rst <= 0;
    end else if (counter < 2) begin
        counter <= counter + 1;
        rst <= 1;
    end else begin
        rst <= 0;
    end
end
endmodule