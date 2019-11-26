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

  // module simulation(.clock(CLOCK_50), .load(load), .x_in(), .y_in(), .start(start), .reset_n(reset_n), .out_x(x), .out_y(y));

endmodule

module simulation(clock, load, x_in, y_in, start, reset_n, out_x, out_y, out_color);
  input load;
	input reset_n;
  input clock;
  input [7:0] x_in;
  input [7:0] y_in;
  input start;
  output reg [7:0] out_x;
  output reg [7:0] out_y;
  output reg [2:0] out_color;

  reg cells [0:3][0:3];
  // reg [7:0] neighbors;
  reg draw;
  reg [7:0] changed [0:10];
  reg [2:0] changed_color [0:10];
  reg [7:0] changed_count;

  reg [7:0]testingbit;
  reg [7:0] foo;
  reg test;

  always @(posedge clock)
  begin
    $display("start    = %0d",start);
    $display("draw    = %0d",draw);
    if (reset_n == 0) begin: RESET
      integer i;
      integer j;
      for (i = 0; i < 4; i = i + 1) begin
        for (j = 0; j < 4; j = j + 1) begin
          cells[i][j] <= 0;
        end
      end
      draw <= 0;
      changed_count <= 0;
    end

    else if (load == 1) begin: LOAD
      $display("loading");	
      cells[x_in][y_in] = 1;
      out_x <= x_in;
      out_y <= y_in;
      out_color <= 3'b0;
      draw <= 0;
    end

    else if (draw == 1) begin: DRAW
      if (changed_count <= 0) begin
        draw <= 0;
      end
      else if (changed_count > 0) begin
        // $display("changed1    = %0d",changed[0]);		
        // $display("changed2    = %0d",changed[1]);
        // $display("changed3    = %0d",changed[2]);		
        // $display("changed4    = %0d",changed[3]);
        // $display("changed5    = %0d",changed[4]);
        // $display("changed6    = %0d",changed[5]);
        // $display("changed7    = %0d",changed[6]);
        // $display("changed8    = %0d",changed[7]);
        // $display("changed9    = %0d",changed[8]);
        // $display("changed10    = %0d",changed[9]);
        // $display("changed count    = %0d",changed_count);		
        cells[changed[changed_count-2]][changed[changed_count-1]] <= ~cells[changed[changed_count-2]][changed[changed_count-1]];
        out_x <= changed[2*changed_count-2];
        out_y <= changed[2*changed_count-1];
        out_color <= changed_color[changed_count];
        changed_count <= changed_count - 1;
        $display("out x    = %0d",changed[2*changed_count-2]);		
        $display("out y    = %0d",changed[2*changed_count-1]);
        $display("out color    = %0d",changed_color[changed_count]);		
        // $display("changed    = %0d",changed_count);
      end
    end

    else if (start == 1 & draw == 0) begin: SIMULATE
      integer row;
      integer col;
      integer i;
      integer j;
      integer neighbors;
      integer num_changed;
      changed_count <= 0;
      num_changed = 0;
      for (row = 0; row < 4; row = row + 1) begin
        for (col = 0; col < 4; col = col + 1) begin
          neighbors = 0;
          if (cells[row][col] == 0) begin: DEAD
            for (i = -1; i <= 1; i = i + 1) begin
              for (j = -1; j <= 1; j = j + 1) begin
                if ((row + i >= 0) & (row + i < 4) & (col + j >= 0) & (col + j < 4) & ~((i == 0) & (j == 0))) begin
                  // $display("1    = %0d",1);
                  if (cells[row+i][col+j] == 1)
                    neighbors = neighbors + 1;
                end
              end
            end
            // after checking all cells around, see if we change the cell or not
            if (neighbors == 3) begin
              changed[2*num_changed] = row;
              changed[2*num_changed + 1] = col;
              changed_color[num_changed] = 3'b111;
              // changed_count <= changed_count + 1;
              num_changed = num_changed + 1;
              draw <= 1;
              // $display("row    = %0d",row);
              // $display("col    = %0d",col);
              // $display("living");
            end
          end

          else begin: ALIVE
            for (i = -1; i <= 1; i = i + 1) begin
              for (j = -1; j <= 1; j = j + 1) begin
                if ((row + i >= 0) & (row + i < 4) & (col + j >= 0) & (col + j < 4) & ~((i == 0) & (j == 0))) begin
                  if (cells[row+i][col+j] == 1) begin
                    neighbors = neighbors + 1;
                  end
                end
              end
            end
            // after checking all cells around, see if we change the cell or not
            if (neighbors <= 1) begin
              changed[2*num_changed] = row;
              changed[2*num_changed + 1] = col;
              changed_color[num_changed] = 3'b0;
              num_changed = num_changed + 1;
              draw <= 1;
              // $display("row    = %0d",row);
              // $display("col    = %0d",col);
              // $display("dead 1");	
            end
            else if (neighbors >= 4) begin
              changed[2*num_changed] = row;
              changed[2*num_changed + 1] = col;
              changed_color[num_changed] = 3'b0;
              num_changed = num_changed + 1;
              draw <= 1;
              // $display("row    = %0d",row);
              // $display("col    = %0d",col);
              // $display("dead 2");	
            end
          end
        end
      end
      changed_count <= num_changed;
    end
  end
 
endmodule
