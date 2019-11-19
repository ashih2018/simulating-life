module control(
  go,
  reset,
  set,
  clock,
  stop,
  ldX,
  ldY,
  loadVal,
  draw,
  current_state
);
  input go;
  input reset;
  input set;
  input stop;
  input clock;
  input loadVal;
  output reg ldX;
  output reg ldY;
  output reg draw;
  output reg [3:0] current_state;

  reg [3:0] next_state;
  

  localparam BASE = 4'd0,
             LOAD_X = 4'd1,
             LOAD_X_WAIT = 4'd2,
             LOAD_Y = 4'd3,
             LOAD_Y_WAIT = 4'd4,
             DRAW = 4'd5,
             DRAW_WAIT = 4'd6;
  
  always @(*)
  begin: state_table
    case (current_state)
      BASE: next_state = set ? LOAD_X : BASE;
      LOAD_X: next_state = set ? LOAD_X : LOAD_X_WAIT;
      LOAD_X_WAIT: next_state = set ? LOAD_Y : LOAD_X_WAIT;
      LOAD_Y: next_state = set ? LOAD_Y : LOAD_Y_WAIT;
      LOAD_Y_WAIT: next_state = go ? DRAW : LOAD_Y_WAIT;
      DRAW: next_state = stop ? DRAW_WAIT : DRAW;
      DRAW_WAIT: begin
       if (go == 1)
        next_state = DRAW;
       else if (set == 1)
        next_state = LOAD_X;
       else
        next_state = DRAW_WAIT;
      end
    endcase
  end // state_table

  always @(*)
  begin: outut_logic
    // default
    draw = 0;
    ldX = 0;
    ldY = 0;
    draw = 0;
    case (current_state)
      BASE: draw = 0;
      LOAD_X: ldX = 1;
      LOAD_Y: ldY = 1;
      DRAW: draw = 1;
      DRAW_WAIT: draw = 0;
      default: begin
        draw = 0;
        ldX = 0;
        ldY = 0;
        draw = 0;
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