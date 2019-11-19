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

module simulation(load, x_in, y_in, start, testx,testy, reset_n, out_x, out_y);
  input load;
	input reset_n;
  input [7:0] x_in;
  input [7:0] y_in;
  input [7:0] testx;
  input [7:0] testy;
  input start;
  output reg out_x;
  output reg out_y;

  reg cells [0:159][0:119];
  reg reset;
  reg neighbors;

  reg [7:0]testing;
  reg testingx;
  reg testingy;

  reg changed [0:160];
  reg changed_count;

  always @(*)
  begin
    assign changed_count = 0;
    if (reset_n == 0) begin: RESET
      integer i;
      integer j;
      for (i = 0; i < 160; i = i + 1) begin
        for (j = 0; j < 120; j = j + 1) begin
          cells[i][j] = 0;
        end
      end
    end

    if (load == 1) begin: LOAD
      cells[x_in][y_in] = 1;
    end

    if (start == 1) begin: SIMULATE
      integer row;
      integer col;
      integer i;
      integer j;
      integer a;
      for (row = 0; row < 160; row = row + 1) begin
        for (col = 0; col < 120; col = col + 1) begin
          assign neighbors = 0;

          if (cells[row][col] == 0) begin: DEAD
            for (i = -1; i <= 1; i = i + 1) begin
              for (j = -1; j <= 1; j = j + 1) begin
                if ((row + i > 0) & (row + i < 160) & (col + j > 0) & (col + j < 160) & ~(col == row)) begin
                  if (cells[row+i][col+j] == 1)
                    assign neighbors = neighbors + 1;
                end
              end
            end
            // after checking all cells around, see if we change the cell or not
            if (row == 51 & col == 51) begin
              testing = cells[row][col];
            end
            if (neighbors == 3) begin
              changed[changed_count] = row;
              changed[changed_count] = col;
              assign changed_count = changed_count + 2;
            end
          end

          else begin: ALIVE
            for (i = -1; i <= 1; i = i + 1) begin
              for (j = -1; j <= 1; j = j + 1) begin
                if ((row + i > 0) & (row + i < 160) & (col + j > 0) & (col + j < 160) & ~(col == row)) begin
                  if (cells[row+i][col+j] == 1)
                    assign neighbors = neighbors + 1;
                end
              end
            end
            // after checking all cells around, see if we change the cell or not
            if (neighbors <= 1) begin
              changed[changed_count] = row;
              changed[changed_count] = col;
              assign changed_count = changed_count + 2;
            end
            if (neighbors >= 4) begin
              changed[changed_count] = row;
              changed[changed_count] = col;
              assign changed_count = changed_count + 2;
            end
          end

        end
      end

    for (a = 0; a < changed_count; a = a + 2) begin
      cells[changed[a]][changed[a+1]] = ~cells[changed[a]][changed[a+1]];
    end

    assign testingx = cells[51][51];

    end
  end

endmodule


