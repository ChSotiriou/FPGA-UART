module main (
	output logic tx,
	input logic rx,
	input logic clk,
	output logic led_red,
	output logic led_green
);

parameter clkFreq = 12e6;
parameter baudRate = 115200;

logic[7:0] receivedData, sentData;
logic dataReceivedFlag;
logic dataSendFlag = 0;

uart_recv #(
	.baudRate(baudRate),
	.clkFreq(clkFreq)
) recv(
	.clk(clk),
	.signal(rx),
	.data(receivedData),
	.dataReceivedFlag(dataReceivedFlag)
);

uart_send #(
	.baudRate(baudRate),
	.clkFreq(clkFreq)
) send(
	.clk(clk),
	.data(sentData),
	.send_trigger(dataSendFlag),
	.signal(tx)
);

always_comb begin
	led_red = rx;
	led_green = tx;
	
	dataSendFlag = dataReceivedFlag;
	sentData = receivedData;
end

endmodule