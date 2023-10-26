module strober (
    output reg strobe,
    input signal,
    input clk,
    input resetn
);

  reg done;

  always @(posedge clk) begin
    if (!resetn) begin
      done   <= 1'b0;
      strobe <= 1'b0;
    end else begin

      if (signal == 1'b1) begin
        if (done == 1'b1) begin
          strobe <= 1'b0;
        end else begin
          strobe <= 1'b1;
        end
        done <= 1'b1;
      end else begin
        done   <= 1'b0;
        strobe <= 1'b0;
      end

    end
  end

endmodule
