`timescale 1ns/1ns

module uart_recv_tb;
  parameter baudRate = 115200;
  parameter timePerBit = 1e9 / baudRate;
  parameter clkHalfPeriod = 5ns;
  parameter clkFreq = 1e9 / (2 * clkHalfPeriod); // ns

  logic clk;
  logic tx_line;

  logic[7:0] dataReceived;
  logic dataReceivedFlag;

  logic[7:0] toSend;

  uart_recv #(
    .baudRate(baudRate),
    .clkFreq(clkFreq)
  ) dut(
    .clk(clk),
    .signal(tx_line),
    .data(dataReceived),
    .dataReceivedFlag(dataReceivedFlag)
  );

  initial begin
    $display("--- Starting Simulation ---");
    tx_line <= 1;

    for (logic[7:0] i = 0; i <= 8'hff; i++) begin
      uart_send(i);
      if (dataReceived != i) begin
        $error("Received %b, expected %b", dataReceived, i);
      end
    end

    $display("--- Ending Simulation ---");
  end

  always @(posedge dataReceivedFlag) begin
    // $display("[i] Data Received: %b", dataReceived);
  end

  always begin
    clk <= 1; #5;
    clk <= 0; #5;
  end
  
  task uart_send(logic[7:0] data);
    tx_line <= 0; #timePerBit; // Start bit
    for (int i = 0; i < 8; i++) begin // Data Bits
      tx_line <= data[i]; #timePerBit;
    end
    tx_line <= 1; #timePerBit; // Stop bit

  endtask

endmodule