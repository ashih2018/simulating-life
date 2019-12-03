module main
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
    // Mouse/Keyboard
        PS2_CLK,
        PS2_DAT
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

  inout PS2_CLK,
	inout PS2_DAT,
	
	wire reset_n;
	assign reset_n = KEY[1];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [7:0] y;
	wire load;
	wire loadY;
	wire loadX;
   wire writeEn;
   wire start;
//	wire new_start;
   wire divided_clock;
  
  wire set;
  wire go;
  wire stop;
	
  assign divided_start = (start) ? divided_clock : 0;

  rateDivider d1(
    .d(26'b10111110101111000010000000), .clock(CLOCK_50), .clock_slower(divided_clock), .reset(reset_n)
  );

  keyboard_tracker #(.PULSE_OR_HOLD(1)) k1(
    .clock(CLOCK_50),
	  .reset(reset_n),
	 .PS2_CLK(PS2_CLK),
	 .PS2_DAT(PS2_DAT),
	 .s(set),
   .enter(go),
   .space(stop)
  );

  // Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.

	vga_adapter VGA(
			.resetn(reset_n),
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

  reg [7:0]x_in;
  reg [7:0]y_in;
  wire [7:0]loadVal;

  assign loadVal = SW[7:0];

  always @(*)
  begin
    if (loadX == 1'b1)
      x_in = loadVal;
    if (loadY == 1'b1)
      y_in = loadVal;
  end
  
  control c1(
  .go(go),
  .reset(reset_n),
  .set(set),
  .clock(CLOCK_50),
  .loadVal(SW[7:0]),
  .stop(stop),
  .ldX(loadX),
  .ldY(loadY),
  .load(load),
  .start(start),
  .writeEn(writeEn)
  );
  
  simulation s1(.clock(CLOCK_50), .load(load), .x_in(x_in), .y_in(y_in), .start(divided_start), .reset_n(reset_n), .out_x(x), .out_y(y), .out_color(colour));

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
  reg draw;
  reg [7:0] changed [0:10];
  reg [2:0] changed_color [0:10];
  reg [7:0] changed_count;

  always @(posedge clock)
  begin
    if (reset_n == 0) begin: RESET
      // $display("1    = %0d",1);
      integer i;
      integer j;
      integer do_draw;
      integer num_changed;
      num_changed = 0;
      do_draw = 0;
      for (i = 0; i < 4; i = i + 1) begin
        for (j = 0; j < 4; j = j + 1) begin
          if (cells[i][j] === 1'bx) begin
            cells[i][j] = 0;
          end
          else if (cells[i][j] == 1) begin
            changed[2*num_changed] = i;
            changed[2*num_changed + 1] = j;
            changed_color[num_changed] = 3'b0;
            num_changed = num_changed + 1;
            do_draw = 1;
          end
        end
      end
      draw <= do_draw;
      changed_count <= num_changed;
    end

    else if (load == 1) begin: LOAD
      cells[x_in][y_in] = 1;
      out_x <= x_in;
      out_y <= y_in;
      out_color <= 3'b111;
      draw <= 0;
    end

    else if (draw == 1) begin: DRAW
      if (changed_count <= 0) begin
        draw <= 0;
      end
      else if (changed_count > 0) begin
        cells[changed[2*changed_count-2]][changed[2*changed_count-1]] <= ~cells[changed[2*changed_count-2]][changed[2*changed_count-1]];
        out_x <= changed[2*changed_count-2];
        out_y <= changed[2*changed_count-1];
        out_color <= changed_color[changed_count-1];
        changed_count <= changed_count - 1;
      end
    end

    else if (start == 1 & draw == 0) begin: SIMULATE
      integer row;
      integer col;
      integer i;
      integer j;
      integer neighbors;
      integer num_changed;
//		$display("1    = %0d", 7);
//      changed_count <= 0;
      num_changed = 0;
      for (row = 0; row < 4; row = row + 1) begin
        for (col = 0; col < 4; col = col + 1) begin
          neighbors = 0;
          if (cells[row][col] == 0) begin: DEAD
            for (i = -1; i <= 1; i = i + 1) begin
              for (j = -1; j <= 1; j = j + 1) begin
                if ((row + i >= 0) & (row + i < 4) & (col + j >= 0) & (col + j < 4) & ~((i == 0) & (j == 0))) begin
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
              num_changed = num_changed + 1;
//				  $display("1    = %0d", 8);
              draw <= 1;
            end
          end

          else begin: ALIVE
            for (i = -1; i <= 1; i = i + 1) begin
              for (j = -1; j <= 1; j = j + 1) begin
                if ((row + i >= 0) & (row + i < 4) & (col + j >= 0) & (col + j < 4) & ~((i == 0) & (j == 0))) begin
                  if (cells[row+i][col+j] == 1) begin
//							$display("1    = %0d", row);
//						  $display("1    = %0d", col);
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
//				  $display("1    = %0d", 9);
              draw <= 1;
            end
            else if (neighbors >= 4) begin
              changed[2*num_changed] = row;
              changed[2*num_changed + 1] = col;
              changed_color[num_changed] = 3'b0;
              num_changed = num_changed + 1;
//				  $display("1    = %0d", 10);
              draw <= 1;
            end
          end
        end
      end
      changed_count <= num_changed;
    end
  end
 
endmodule

module control(
  go,
  reset,
  set,
  clock,
  loadVal,
  stop,
  ldX,
  ldY,
  load,
  start,
  writeEn
  );
  input go;
  input reset;
  input set;
  input stop;
  input clock;
  input [7:0]loadVal;
  output reg ldX;
  output reg ldY;
  output reg start;
  output reg writeEn;
  output reg load;

  reg [3:0] current_state, next_state;
  

  localparam BASE = 4'd0,
             LOAD_X = 4'd1,
             LOAD_X_WAIT = 4'd2,
             LOAD_Y = 4'd3,
             DRAW = 4'd4,
             DRAW_WAIT = 4'd5,
             SIMULATION = 4'd6;
  
  always @(*)
  begin: state_table
    case (current_state)
      BASE: next_state = ~set ? LOAD_X : BASE;
      LOAD_X: next_state = set ? LOAD_X_WAIT : LOAD_X;
      LOAD_X_WAIT: next_state = ~set ? LOAD_Y : LOAD_X_WAIT;
      LOAD_Y: next_state = set ? DRAW : LOAD_Y;
      DRAW: next_state = DRAW_WAIT;
      DRAW_WAIT: begin
       if (go == 1'b0) begin
		  next_state = SIMULATION;
		 end  
       else if (set == 1'b0) begin
        next_state = LOAD_X;
		  end
       else begin
        next_state = DRAW_WAIT;
		  end
      end
      SIMULATION: next_state = ~stop ? DRAW_WAIT: SIMULATION;
    endcase
  end // state_table

  always @(*)
  begin: output_logic
    // default
    start = 0;
    ldX = 0;
    ldY = 0;
    load = 0;
	 writeEn = 0;
    case (current_state)
      BASE: $display("1    = %0d",2);
      LOAD_X: begin
        ldX = 1;
        $display("1    = %0d",3);
      end
      LOAD_Y: begin
        ldY = 1;
        $display("1    = %0d",4);
      end
      DRAW: begin
			load = 1;
			writeEn = 1;
        $display("1    = %0d",5);
		end
		DRAW_WAIT: begin
      writeEn = 1;
      $display("1    = %0d",6);
    end
    SIMULATION: begin
			start = 1;
			writeEn = 1;
      $display("1    = %0d",7);
		end
      default: begin
        start = 0;
        ldX = 0;
        ldY = 0;
        load = 0;
      end
    endcase
  end


  always @(posedge clock)
  begin: state_FF
    if (!reset)
      current_state <= BASE;
    else
      current_state <= next_state;
  end // state_FFs

endmodule

module rateDivider(d, clock, clock_slower, reset);
  input [25:0] d;
  input clock;
  input reset;
  output clock_slower;
  
  reg [25:0]q; // use decimal

  assign clock_slower = (q == 1'b0) ? 1 : 0;

  always @(posedge clock)
  begin
	 $display("1    = %0d",q);
    if (reset == 1'b0)
      q <= 1'b0;
    else if (q == 1'd0)
      q <= d;
    else
      q <= q - 1'b1;
  end
endmodule