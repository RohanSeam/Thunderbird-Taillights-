// Rohan Seam & Trung Do
// 5/3/2020
//
// Timer module that takes in a clock signal and output 1 Hz pulses. The parameter
// MaxCount can be altered to specify the Max of the input. 
// The always block is triggered on the positive edge of the clock signal. 
module Timer(Clock, Out);
	input Clock;    // 50 MHz System Clock
	output reg Out; // One pulse per second
	reg [25:0] Q = 24'b0;   // Count 
	parameter MaxCount = 50_000_000 - 1;
	
	always @(posedge Clock) begin
		if ( Q == MaxCount) begin // Go back to 0 and output the pulse signal. 
			Q <= 0;
			Out <= 1'b1;
		end
		else begin  				  // We are not ready to output the signal, so output 
										  // a 0 and increment the Q. 
			Q <= Q + 1'b1;
			Out <= 1'b0;
		end
	end
endmodule 

// Testbench for the Timer module. Displays to the monitor for easy debugging. 
module Timer_testbench();
	logic Clock;
	logic Out;
	
	Timer #(.MaxCount(10)) DUT(Clock, Out);
	
	// Clock implementation.
	always begin
		Clock <= 0;
		#1;
		Clock <= 1;
		#1;
	end
	
	initial begin
//		wait(Out == 1); assert(Out == 1) else $error("Incorrect!");
//		wait(Out == 0); assert(Out == 0) else $error("Incorrect!");
		#1000;
		$stop;
	end
	
	initial $monitor($time,,,,Clock,,,,Out);
	
endmodule 
















