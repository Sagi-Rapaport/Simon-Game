module Simon_Game(
    input logic clk, // FPGA clock (50 MHz) 
    input logic rst, // reset (SW[9])
    input logic [7:0] SW, // 8 switches for input from the participant
    output logic [7:0] LED, // 8 LEDs for display the LED sequence that the participant need to repeat
    output logic [6:0] seg0 // 7-segment feedback, display digit 1 or 0: 1- correct, 0- incorrect
);

    localparam sequence_length = 7; // maximal sequence length for 3 bits (without repetition)
    localparam one_sec = 50_000_000; // 1 sec

    // === Internal variables ===
    logic [2:0] rand_num; // 2^3 options (0-7)
    logic [3*sequence_length-1:0] led_sequence; // 21 bits: total 7 LEDs- every 3 bits are associated with a LED number
    logic [3*sequence_length-1:0] sw_sequence; // 21 bits: total 7 switches- every 3 bits are associated with a switch number
    logic [2:0] gen_led_index, inp_sw_index; // indicate the index in GEN/INP states, when equal to 7 passing to the next state
    logic [3:0] disp_led_index; // indicate the index in DISP state, when equal to 8 passing to the next state
    logic [7:0] sw_prev; // the previous state of a switch (0-7)
    logic [7:0] sw_sync1, sw_sync2; // 2 intermediate steps for synchronization
    logic sw_change_detected; // indicate on stable change in one switch
    logic [7:0] sw_changed; // stores changes of the switches
    logic [19:0] debounce_cnt; // debounce counter for checking stability of switch change
    logic [2:0] sw_index; // Total of 8 switches (0-7) - indicate the switch index
    logic [25:0] count; // enough for 50 million

// === Instantiate the LFSR module ===
LFSR lfsr(
    .clk(clk),
    .rst(rst),
    .rand_num(rand_num)
);

    // === State Encoding ===
        typedef enum logic [2:0] {
            START,
            GENERATE_LED,
            DISPLAY,
            INPUT,
            CHECK,
            DONE
        } state_t;
        state_t state, next_state;

    // === Main Game FSM ===
    always_ff @(posedge clk or posedge rst) begin // state register
        if (rst) begin
            state <= START;
        end 
        else begin
            state <= next_state;
        end
    end

    // === Next State Logic ===
    always_comb begin
        next_state = state; // default

        unique case (state)
            START: begin
                next_state = GENERATE_LED;
            end
            GENERATE_LED: begin
                if (gen_led_index == sequence_length) begin
                    next_state = DISPLAY;
                end
            end
            DISPLAY: begin
                if (disp_led_index == sequence_length + 1) begin
                    next_state = INPUT;
                end
            end
            INPUT: begin
                if (inp_sw_index == sequence_length) begin
                    next_state = CHECK;
                end
            end
            CHECK: begin
                next_state = DONE;
            end
            DONE: begin
                if (rst) begin
                    next_state = START;
                end
            end
        endcase
    end

    // === Sequential Counters/Index + Outputs ===
    always_ff @(posedge clk or posedge rst) begin // Internal registers of the game
        if (rst) begin
            led_sequence <= 0;
            sw_sequence <= 0;
            gen_led_index <= 0; 
            disp_led_index <= 0;
            inp_sw_index <= 0;
            sw_prev <= 0; // the initial state of the switches
            sw_sync1 <= 0;
            sw_sync2 <= 0;
            sw_change_detected <= 0;
            sw_changed <= 0;
            debounce_cnt <= 0;
            sw_index <= 0;
            count <= 0;
            LED <= 8'b00000000; // at the beginning- all LEDs OFF
            seg0 <= 7'b0111111; // display "-" | active low logic
        end 
        else begin
            case (state)
                START: begin
                    // starting the game
                end
                GENERATE_LED: begin
                    if (gen_led_index == 0) begin
                        led_sequence[3*sequence_length-1 -: 3] <= 3'b101; // Start with LED[5]
                        gen_led_index <= gen_led_index + 1;
                    end 
                    else if (gen_led_index < sequence_length) begin
                        led_sequence[3*sequence_length-1 - gen_led_index*3 -: 3] <= rand_num; // LFSR
                        gen_led_index <= gen_led_index + 1;
                    end 
                end
                DISPLAY: begin
                    if (count == one_sec) begin
                        count <= 0;
                        LED <= 8'b00000000; // all LEDs OFF
                        
                        if (disp_led_index < sequence_length) begin
                            case (led_sequence[3*sequence_length-1 - disp_led_index*3 -: 3])
                                3'd0: LED[0] <= 1;
                                3'd1: LED[1] <= 1;
                                3'd2: LED[2] <= 1;
                                3'd3: LED[3] <= 1;
                                3'd4: LED[4] <= 1;
                                3'd5: LED[5] <= 1;
                                3'd6: LED[6] <= 1;
                                3'd7: LED[7] <= 1;
                            endcase
                            disp_led_index <= disp_led_index + 1;
                        end
                        else begin
                            LED <= 8'b00000000; // end of the led_sequence- all LEDs OFF
                            disp_led_index <= disp_led_index + 1;
                        end
                    end
                    else begin
                        count <= count + 1;
                    end
                end
                INPUT: begin
                    sw_sync1 <= SW; // step 1
                    sw_sync2 <= sw_sync1; // step 2

                    sw_change_detected <= 1'b0;
                    sw_changed <= 8'b0;

                    if (sw_sync2 != sw_prev) begin // change has found- start counting
                        debounce_cnt <= debounce_cnt + 1;

                        if (&(debounce_cnt)) begin // all the bits are 1- enough time has passed
                            sw_changed <= sw_prev ^ sw_sync2; // indicate which switches have changed
                            sw_prev <= sw_sync2; // updating previous switches
                            sw_change_detected <= 1'b1; // stable switch change has found
                            debounce_cnt <= 0; // reset debounce count 
                        end
                    end 
                    else begin
                        debounce_cnt <= 0; // change has not found- reset debounce count
                    end

                    if (sw_change_detected) begin // stable switch change has found
                        for (int i = 0; i < 8; i++) begin // goes through all the switches
                            if (sw_changed[i]) // checking which switch changed
                                sw_index = i[2:0]; // updates the switch index that changed
                        end

                        if (inp_sw_index < sequence_length) begin
                            sw_sequence[3*sequence_length-1 - inp_sw_index*3 -: 3] <= sw_index; // insert the switch index that changed to the sw_sequence
                            inp_sw_index <= inp_sw_index + 1;
                        end
                    end
                end
                CHECK: begin
                    if (led_sequence == sw_sequence) begin
                        seg0 <= 7'b1111001; // display "1" | active low logic
                    end 
                    else begin
                        seg0 <= 7'b1000000; // display "0" | active low logic
                    end
                end
                DONE: begin
                    // Wait for restart
                end
            endcase
        end
    end
endmodule

module LFSR( // Linear Feedback Shift Register
    input logic clk, // FPGA clock (50 MHz) 
    input logic rst, // reset (SW[9])
    output logic [2:0] rand_num
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            rand_num <= 3'b010;
        end
        else begin
            rand_num <= {rand_num[1:0], rand_num[2]^rand_num[1]};
        end
    end
endmodule