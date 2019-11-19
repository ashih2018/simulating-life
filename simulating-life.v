// Part 2 skeleton

module main
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	wire control_a;
	wire control_b;

    
endmodule

module datapath(clock, start, x_in, y_in, reset_n, out_x, out_y);
	input clock;
  input start;
	input reset_n;
  input [7:0] x_in;
  input [7:0] y_in;
  output reg out_x;
  output reg out_y;

  reg x_counter;
  reg y_counter;
  reg cells [159:0][119:0];
  reg reset;

  always @(*)
  begin
    if (reset_n == 0) begin: RESET
      integer i;
      integer j;
      for (i = 0; i < 160; i = i + 1) begin
        for (j = 0; j < 120; j = j + 1) begin
          if (i == 50)
            cells[i][j] = 1;
          else
            cells[i][j] = 0;
        end
      end
    end
    assign out_x = cells[x_in][y_in];
    assign out_y = cells[y_in][x_in];

    // if (reset == 1) begin
    //   cells[x_counter][y_counter] = 0;
    //   x_counter = x_counter + 1;
    //   y_counter = y_counter + 1;
    //   if (x_counter >= 160) begin
    //     x_counter = 0;
    //   end
    //   if (y_counter >= 120) begin
    //     y_counter = 0;
    //     reset = 0;
    //   end
    // end
  end

endmodule


