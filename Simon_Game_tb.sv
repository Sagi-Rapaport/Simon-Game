`timescale 1ns/1ps

module Simon_Game_tb;

    // Testbench-controlled inputs to DUT
    logic clk = 0;
    logic rst = 0;
    logic [7:0] SW = 8'b00000000;
    
    // Output from DUT
    logic [7:0] LED;
    logic [6:0] seg0;

    // Clock generation (50 MHz clock = 20ns period)
    always #10 clk = ~clk;

    // Instantiate the DUT
    Simon_Game dut(
        // Inputs
        .clk(clk),
        .rst(rst),
        .SW(SW),
        // Outputs
        .seg0(seg0),
        .LED(LED)
    );

    // Stimulus block
    initial begin
        // Initial reset
        #40;
        rst = 1;
        #40;
        rst = 0;
        #120000;
        // testing SW: input of the participant (7 inputs) first attempt
        SW[5] = 1;
        #40;
        SW[3] = 1;
        #40;
        SW[7] = 1;
        #40;
        SW[6] = 1;
        #40;
        SW[3] = 0; // mistake (SW[4] = 1 - RIGHT)
        #40;
        SW[2] = 1; // mistake (SW[1] = 1 - RIGHT)
        #40;
        SW[1] = 1; // mistake (SW[2] = 1 - RIGHT)
        #10000;

        // seg0: incorrect - "0"   *failure*
        // moving all the switches to 0
        SW[0] = 0;
        #40;
        SW[1] = 0;
        #40;
        SW[2] = 0;
        #40;
        SW[3] = 0;
        #40;
        SW[4] = 0;
        #40;
        SW[5] = 0;
        #40;
        SW[6] = 0;
        #40;
        SW[7] = 0;
        #10000;

        // restart the game
        rst = 1;
        #40;
        rst = 0;
        #120000;

        // testing SW: input of the participant (7 inputs) second attempt
        SW[5] = 1;
        #40;
        SW[3] = 1;
        #40;
        SW[7] = 1;
        #40;
        SW[6] = 1;
        #40;
        SW[4] = 1; 
        #40;
        SW[1] = 1; 
        #40;
        SW[2] = 1; 
        #10000;

        // seg0: correct - "1"   *success*

        $stop;

    end

endmodule