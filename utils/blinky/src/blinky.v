module blinky #(
    parameter NO_OF_LEDS = 4
) (
    output reg [NO_OF_LEDS - 1:0] led_out,
    input mode_switch,
    input ext_counter,
    input clk,
    input resetn
);

  localparam COUNTER = 1'b0;
  localparam EXTERNAL = 1'b1;

  reg mode;
  reg [NO_OF_LEDS-1:0] led_counter;

  always @(posedge clk) begin
    if (!resetn) begin
      mode <= COUNTER;
      led_counter <= 'h00;
      led_out <= 'h00;
    end else begin

      case (mode)
        COUNTER: begin
          led_counter <= led_counter + 1;
          if (mode_switch) mode <= EXTERNAL;
        end
        EXTERNAL: begin
          led_counter[NO_OF_LEDS-1:0] <= led_counter + ext_counter;
          if (mode_switch) mode <= COUNTER;
        end
      endcase

      led_out <= led_counter;

    end
  end
endmodule

