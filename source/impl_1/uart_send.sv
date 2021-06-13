module uart_send #(
  parameter baudRate = 9600,
  parameter clkFreq = 1e8 
)(
  input logic clk,
  input logic[7:0] data,
  input logic send_trigger,
  output logic signal
);

typedef enum { IDLE, START_BIT, DATA_BITS, STOP_BIT } State;
State uart_send_state = IDLE;

int count = 0;
int clkPulsesPerBit = clkFreq / baudRate;
int bits_send = 0;
logic[7:0] dataToSend;
logic startTransmission = 0;

always @(posedge clk) begin
  count <= count + 1;

  case (uart_send_state)
    IDLE: begin
      signal <= 1;

      if (send_trigger == 1) begin
        uart_send_state <= START_BIT;
        count <= 0;
        dataToSend <= data;
      end
    end
    START_BIT: begin
      signal <= 0;

      if (count == clkPulsesPerBit) begin
        uart_send_state <= DATA_BITS;
        bits_send <= 0;
        count <= 0;
      end
    end
    DATA_BITS: begin
      signal <= dataToSend[bits_send];
      
      if (count == clkPulsesPerBit) begin
        count <= 0;
        bits_send <= bits_send + 1;

        if (bits_send == 7) begin
          uart_send_state <= STOP_BIT;
        end
      end
    end
    STOP_BIT: begin
      signal <= 1;

      if (count == clkPulsesPerBit) begin
        count <= 0;
        uart_send_state <= IDLE;
      end
    end
    default: uart_send_state <= IDLE; 
  endcase
end

  
endmodule