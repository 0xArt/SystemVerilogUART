`timescale 1ns/1ns
module uart_testbench();

	logic clk;
	logic [31:0] clocksPerBit;
	logic [7:0] incomingByte;
	logic txDv;
	
	logic [7:0] rxByte;
	logic rxData;
	logic rxDv;
	
	
	logic txActive;
	logic txDone;
	logic txSerial;
	logic [7:0] txByte;
	
	
	real baudRate = 115200;
	real clock = 50e6;	
	real clockDelay = ((1/clock)/2)*(1e9);
	real bitDelay = (1/baudRate)*(1e9);
	
	uart_tx uart_tx_inst (clk, txDv, incomingByte, clocksPerBit, txActive, txDone, txSerial, txByte);

	uart_rx uart_rx_inst (clk, clocksPerBit, rxData, rxDv, rxByte);
	
	task sendData(input [7:0] toSend);
		int i;
		rxData <= 1'b0;
		#bitDelay;
		
		for (i=0; i<8; i++) begin
			rxData <= toSend[i];
			#bitDelay;
		end
		
		rxData <= 1'b1;
		#bitDelay;
	endtask

	initial begin
		incomingByte = 8'd7;
		txDv = 1'b0;
		clocksPerBit = int'(clock/baudRate);
		
		@(posedge clk);
		@(posedge clk);
		sendData(8'h37);
		@(posedge clk);


		if( rxByte == 8'h37) begin 
		  $display("RX Passed");
		  $stop;
		end
		else begin
		  $display("RX Failed");
		  $stop;
		end

	end
	
	always begin
		#clockDelay;
		clk = 1'b1;
		#clockDelay;
		clk = 1'b0;
	end
	


endmodule
