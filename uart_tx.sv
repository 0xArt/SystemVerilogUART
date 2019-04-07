module uart_tx(

input logic clk,
input logic txDv,
input logic [7:0] incomingByte,
input logic [31:0] clocksPerBit,

output logic txActive,
output logic txDone,
output logic txSerial,
output logic [7:0] txByte
);

enum logic [2:0] {IDLE=3'b000, SEND_START_BIT=3'b001, SEND_PAYLOAD=3'b010, SEND_STOP_BIT=3'b011, DONE=3'b100} state;

logic [2:0] bitCounter = 0;
logic [7:0] clockCounter = 0;
logic [7:0] toSend;

always_ff @(posedge clk) begin

	casex (state)
		
		IDLE: begin
		
			txSerial <= 1; // tx Drive line is high during idle
			txDone <= 0;
			bitCounter <= 0;
			clockCounter <= 0;
			
			if(txDv == 1)begin //if data valid is high
				txActive <= 1;
				toSend <= incomingByte; //store incoming byte to a register
				state <= SEND_START_BIT;
			end
			else begin
				state <= IDLE;
			end
		
		end
		
		SEND_START_BIT: begin
			txSerial <= 0;
			
			if(clockCounter < clocksPerBit - 1) begin
				clockCounter<= clockCounter + 1;
			end
			else begin
				clockCounter <= 0;
				state<= SEND_PAYLOAD;
			end
		end
		
		SEND_PAYLOAD: begin
			txSerial <= toSend[bitCounter];
			
			if(clockCounter < clocksPerBit -1) begin
				clockCounter<= clockCounter + 1;
			end
			else begin
				bitCounter <= 0;
				state <= SEND_STOP_BIT;
			end
			
		end
		
		SEND_STOP_BIT: begin
			txSerial <= 1'b1;
			clockCounter <= 0;
			txActive <= 1'b0;
			state <= DONE;
		end
		
		DONE: begin
			txDone <= 1'b1;
			state <= IDLE;
		end
		
	endcase

end



endmodule
