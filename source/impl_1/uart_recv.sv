module uart_recv #(
  parameter baudRate = 9600,
  parameter clkFreq = 1e9
)(
  input logic clk,
  input logic signal,
  output logic[7:0] data,
  output logic dataReceivedFlag = 0
);

typedef enum { IDLE, START_BIT, DATA_BITS, STOP_BIT } State;

State uart_recv_state = IDLE;

int clkPulsesPerBit = clkFreq / baudRate;
int count = 0;
int bitReceived = 0;

always @(posedge clk) begin
  count <= count + 1;
  
  case (uart_recv_state)
    IDLE: begin
      dataReceivedFlag <= 0;
      if (signal == 0) begin
        count <= 0;
        uart_recv_state = START_BIT;
      end
    end

    START_BIT: begin
      // Sample for start bit to confirm
      if (count == clkPulsesPerBit / 2) begin
        if (signal == 0) begin
          count <= 0;
          bitReceived <= 0;
          uart_recv_state = DATA_BITS;
        end else begin
          uart_recv_state = IDLE;
        end
      end
    end

    DATA_BITS: begin
      if (count == clkPulsesPerBit) begin
        data[bitReceived] <= signal;
        bitReceived <= bitReceived + 1;
        count <= 0;

        if (bitReceived == 7) begin
          uart_recv_state = STOP_BIT;
          count <= 0;
        end
      end
    end

    STOP_BIT: begin
      if (count == clkPulsesPerBit) begin
        if (signal == 1) begin
          dataReceivedFlag <= 1;
        end
        uart_recv_state <= IDLE;
      end
    end

    default: begin
      uart_recv_state <= IDLE;
    end
  endcase
end

endmodule