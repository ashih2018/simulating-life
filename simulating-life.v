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
	
	wire reset_n;
	assign reset_n = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	wire control_a;
	wire control_b;
  wire load;
  wire start;

  // Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.

	vga_adapter VGA(
			.reset_n(reset_n),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";

  module simulation(.clock(CLOCK_50), .load(load), .x_in(), .y_in(), .start(start), .reset_n(reset_n), .out_x(x), .out_y(y));

endmodule

module simulation(clock, load, x_in, y_in, start, reset_n, out_x, out_y);
  input load;
	input reset_n;
  input clock;
  input [7:0] x_in;
  input [7:0] y_in;
  input start;
  output reg [7:0] out_x;
  output reg [7:0] out_y;

  reg cells [0:159][0:119];
  reg [7:0] neighbors;
  reg draw;
  reg [7:0] changed [0:160];
  reg [7:0] changed_count;

  reg [7:0]testingbit;
  reg [7:0] foo;

  // $display("draw    = %0d",draw);
  always @(*)
  begin
    assign testingbit = cells[51][51];
    assign foo = cells[7][14];
    if (reset_n == 0) begin: RESET
      integer i;
      integer j;
      for (i = 0; i < 160; i = i + 1) begin
        for (j = 0; j < 120; j = j + 1) begin
          cells[i][j] = 0;
        end
      end
      assign draw = 0;
      assign changed_count = 0;
    end

    if (load == 1) begin: LOAD
      cells[x_in][y_in] = 1;
      out_x = x_in;
      out_y = y_in;
      assign draw = 0;
    end

    if (draw == 1) begin: DRAW
      if (changed_count > 0) begin
        cells[changed[changed_count-2]][changed[changed_count-1]] = ~cells[changed[changed_count-2]][changed[changed_count-1]];
        assign out_x = changed[changed_count-2];
        assign out_y = changed[changed_count-1];
        assign changed_count = changed_count - 2;
        if (changed_count <= 0) begin
          assign draw = 0;
        end
      end
    end

    if (start == 1 & draw == 0) begin: SIMULATE
      integer row;
      integer col;
      integer i;
      integer j;
      integer a;
      assign changed_count = 0;
      for (row = 0; row < 160; row = row + 1) begin
        for (col = 0; col < 120; col = col + 1) begin
          assign neighbors = 0;

          if (cells[row][col] == 0) begin: DEAD
            for (i = -1; i <= 1; i = i + 1) begin
              for (j = -1; j <= 1; j = j + 1) begin
                if ((row + i >= 0) & (row + i < 160) & (col + j >= 0) & (col + j < 160) & ~((i == 0) & (j == 0))) begin
                  if (cells[row+i][col+j] == 1)
                    assign neighbors = neighbors + 1;
                end
              end
            end
            // after checking all cells around, see if we change the cell or not
            if (neighbors == 3) begin
              changed[changed_count] = row;
              changed[changed_count + 1] = col;
              assign changed_count = changed_count + 2;
              assign draw = 1;
            end
          end

          else begin: ALIVE
            for (i = -1; i <= 1; i = i + 1) begin
              for (j = -1; j <= 1; j = j + 1) begin
                if ((row + i >= 0) & (row + i < 160) & (col + j >= 0) & (col + j < 160) & ~((i == 0) & (j == 0))) begin
                  if (cells[row+i][col+j] == 1) begin
                    assign neighbors = neighbors + 1;
                  end
                end
              end
            end
            // after checking all cells around, see if we change the cell or not
            if (neighbors <= 1) begin
              if (row == 7 & col == 14) begin
                $display("no1    = %0d",row);
              end
              changed[changed_count] = row;
              changed[changed_count + 1] = col;
              assign changed_count = changed_count + 2;
              assign draw = 1;
            end
            if (neighbors >= 4) begin
              changed[changed_count] = row;
              changed[changed_count + 1] = col;
              assign changed_count = changed_count + 2;
              assign draw = 1;
            end
          end
        end
      end
    end
  end
endmodule


