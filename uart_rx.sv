module uart_rx(

input logic clk,
input logic [31:0] clocksPerBit,
input logic rxData,

output logic rxDv,
output logic [7:0] rxByte

);

	logic [2:0] bitCounter = 0;
	logic [31:0] clockCounter = 0;

	enum logic [2:0] {IDLE=3'b000, SCAN_START_BIT=3'b001, SCAN_PAYLOAD=3'b010, SCAN_STOP_BIT=3'b011, DONE=3'b100} state;


	always_ff @(posedge clk) begin
	
		casex(state) 
		
			IDLE: begin
			
				rxDv <= 1'b0;
				clockCounter <= 0;
				bitCounter <= 0;
				
				if(rxData == 1'b0) begin
					state <= SCAN_START_BIT;
				end 
				else begin
					state <= IDLE;
				end
			
			end
			
			SCAN_START_BIT: begin
			
				if(clockCounter == ((clocksPerBit-1)/2)) begin
					if(rxData == 1'b0) begin
						clockCounter <= 0;
						state <= SCAN_PAYLOAD;
					end
					else begin
						state <= IDLE;
					end
				end 
				else begin
					clockCounter++;
				end
				
			end
			
			SCAN_PAYLOAD: begin
			
				if(clockCounter < clocksPerBit - 1) begin
					clockCounter++;
				end
				else begin
					clockCounter <= 0;
					rxByte[bitCounter] <= rxData;
					if(bitCounter < 7) begin
						bitCounter++;
					end
					else begin
						bitCounter <= 0;
						state <= SCAN_STOP_BIT;
					end
				end
			
			end
			
			SCAN_STOP_BIT: begin
			
				if( clockCounter < clocksPerBit - 1) begin
					clockCounter++;
				end
				else begin
					if (rxData == 1'b1) begin
						rxDv <= 1'b1;
						state <= DONE;
					end 
					else begin
						state <= IDLE;
					end
				end
				
			end
			
			DONE: begin
				state <= IDLE;
			end
				
		
		
		
		endcase 
	
	
	end

endmodule