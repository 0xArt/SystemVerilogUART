`timescale 1ns/1ns
module uart_testbench();

	logic clk;
	logic [31:0] clocksPerBit;
	logic [7:0] incomingByte;
	logic txDv;
	
	
	logic txActive;
	logic txDone;
	logic txSerial;
	logic [7:0] txByte;
	
	
	real baudRate = 9600;
	real clock = 50e6;	
	real clockDelay = ((1/clock)/2)*(1e9);
	
	uart_tx uart_tx_inst (clk, txDv, incomingByte, clocksPerBit, txActive, txDone, txSerial, txByte);

	uart_rx uart_rx_inst (clk);

	initial begin
		incomingByte = 8'd7;
		txDv = 1'b0;
		clocksPerBit = int'(clock/baudRate);
	end
	
	always begin
		#clockDelay;
		clk = 1'b1;
		#clockDelay;
		clk = 1'b0;
	end

endmodule
