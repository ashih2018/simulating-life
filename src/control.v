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
  start
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
      BASE: next_state = set ? LOAD_X : BASE;
      LOAD_X: next_state = set ? LOAD_X : LOAD_X_WAIT;
      LOAD_X_WAIT: next_state = set ? LOAD_Y : LOAD_X_WAIT;
      LOAD_Y: next_state = set ? LOAD_Y : DRAW;
      DRAW: next_state = DRAW_WAIT;
      DRAW_WAIT: begin
       if (go == 1)
        next_state = SIMULATION;
       else if (set == 1)
        next_state = LOAD_X;
       else
        next_state = DRAW_WAIT;
      end
      SIMULATION: next_state = stop ? DRAW_WAIT : SIMULATION;
    endcase
  end // state_table

  always @(*)
  begin: outut_logic
    // default
    start = 0;
    ldX = 0;
    ldY = 0;
    load = 0;
    case (current_state)
      BASE: start = 0;
      LOAD_X: ldX = 1;
      LOAD_Y: ldY = 1;
      DRAW: load = 1;
      SIMULATION: start = 1;
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