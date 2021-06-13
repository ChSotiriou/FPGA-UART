`timescale 1ns/1ns

module uart_send_tb;

parameter baudRate = 115200;
parameter timePerBit = 1e9 / baudRate;
parameter clkHalfPeriod = 5ns;
parameter clkPerieod = 2*clkHalfPeriod;
parameter clkFreq = 1e9 / (2 * clkHalfPeriod); // ns
parameter fullTransctionDelay = (10e9 / baudRate) + 1000;

logic clk;
logic sendTrigger = 0;
logic signal;
logic[7:0] dataReceived, dataToSend;
logic dataReceivedFlag;
logic dataSendTrigger;

uart_recv #(
  .baudRate(baudRate),
  .clkFreq(clkFreq)
) recv(
  .clk(clk),
  .signal(signal),
  .data(dataReceived),
  .dataReceivedFlag(dataReceivedFlag)
);

uart_send #(
  .baudRate(baudRate),
  .clkFreq(clkFreq) 
) send(
  .clk(clk),
  .data(dataToSend),
  .send_trigger(dataSendTrigger),
  .signal(signal)
);

initial begin
  $display("--- Starting Simulation ---");

  for (int i = 0; i <= 8'hff; i++) begin
    dataToSend <= i;
    dataSendTrigger <= 1; #clkPerieod;
    dataSendTrigger <= 0; #clkPerieod;
    #fullTransctionDelay;

    if (dataReceived != i[7:0]) begin
      $error("Received %b, expected %b", dataReceived, i[7:0]);
    end
  end

  $display("--- Ending Simulation ---");
end

always @(posedge dataReceivedFlag) begin
  // $display("Received %b", dataReceived);
end

always begin
  clk <= 1; #clkHalfPeriod;
  clk <= 0; #clkHalfPeriod;
end
  
endmodule