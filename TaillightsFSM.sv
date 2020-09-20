// TCES 330
// Project A: Thunderbird Tail Light  
// Rohan Seam and Trung Do
// 5/16/2020
//
// Tail light finite state machine module. This module is to implement the state transition
// of the LEDs of the tail lights that follow the Ford Thunderbird tail light implementation.
// The Clock input allows the state machine to propagate from one state to the next on the 
// rising edge of the clock signal. The Enable input allows the state to transition from one 
// state to the next, if Enable = 1. The inputs L, R, and H represent the left turn, right turn
// and hazard signal respectively. The H signal takes precedence over the L and R inputs. The 
// output out represents the state of the LEDs of the tail lights at each state. 
module TaillightsFSM(Clock, Enable, L, R, H, out);
	
	input Clock, Enable;								// Clock input and reset (high)
	input H, L, R;     								// H = hazard input, L = left turn signal, 
															// R = right turn signal
	
	output logic [5:0] out;							// Lc, Lb, La | Ra, Rb, Rc	
															// Lc = MSB, Rc = LSB. Represents the outputs for the 
															// tail lights. 
	
	localparam S0 = 3'h0,							// State names
				  S1 = 3'h1, 				 
				  S2 = 3'h2,
				  S3 = 3'h3,
				  S4 = 3'h4,
				  S5 = 3'h5,
				  S6 = 3'h6,
				  S7 = 3'h7;
				  
	// Start at state S0, which is the idle state: All lights off.
	logic [2:0] CurrentState = S0; 
	logic [2:0] NextState;
	
	// Define all the state transitions, included the default state, S0.
	always_comb begin
		out = 6'b0;
		case (CurrentState)
			S0: if (H && L && ~R || H && ~L && R || H && ~L && ~R) NextState = S7;		// Go to the "all lights on" state 
																												// only if L and R are not both on.
				 
				 else if (L && ~R) NextState = S1;							// Go to the left turn 
			    else if (~L && R) NextState = S4;							// Go to the right turn
				 else NextState = S0;											// Stay at all lights off.
					
			S1: if (H) NextState = S0;											// Go to state S0 if H is active. H takes precedence.
				 else if (L && ~R) begin 										// Now go to next state as long as L is only on.
					NextState = S2; out = 6'b001000;
				 end
				 else NextState = S0;											// Any other input sets current state to default state.
				 
			S2: if (H) NextState = S0;											
				 else if (L && ~R) begin 										// Now go to next state as long as L is only on.
					NextState = S3; out = 6'b011000;
				 end
				 else NextState = S0;											
					
			S3: begin NextState = S0; out = 6'b111000; end				
			
			S4: if (H) NextState = S0;											 
				 else if (~L && R) begin 										// start right tail light if R is only one active.
					NextState = S5; out = 6'b000100;
				 end
				 else NextState = S0;											
			
			S5: if (H) NextState = S0;											
				 else if (~L && R) begin 										// If R is only one active, move to next state in cycle.
					NextState = S6; out = 6'b000110;
				 end
				 else NextState = S0;											

			S6: begin NextState = S0; out = 6'b000111; end
			
			S7: begin NextState = S0; out = 6'b111111; end
			
			// Default state (All lights are off).
			default: NextState = S0;
		endcase
	end 

	// Propagate the states on the positive edge of the clock signal. 
	// If Enable = 1, propagate to the next state, else hold the current state. 
	always_ff @(posedge Clock) begin
		if (Enable) CurrentState <= NextState;
		else CurrentState <= CurrentState;
	end 
endmodule 

// Testbench
module TaillightsFSM_tb();
	logic Clock, H, L, R, Enable;     
	logic [5:0] out;

	// Instantiate the Tailights FSM.
	TaillightsFSM DUT(Clock, Enable, L, R, H, out);
	
	// Clock signal. (20ns period)
	always begin
		Clock = 0; #10;
		Clock = 1; #10;
	end
	
	initial begin 
		$display("Time \t\t  L  R  H \t Enable \t out");
		
		// Check the hazard signal and see if the tailights are blinking. 
		Enable = 1;
		L = 0; R = 0; H = 0; #105;
		L = 0; R = 0; H = 1; #55;
		L = 1; #75;
		L = 0; R = 1; #105;
		
		// Both left and right signal are on: All lights off.
		L = 1; R = 1; #105;
		
		// All signals are on.
		H = 1; #105;
		
		// Check with the hazard off and left turn signal on.
		H = 0; R = 0; L = 1; #145;
		
		// Check right turn signal.
		L = 0; R = 1; #145;
		
		// Check if H takes precedence over R signal. 
		H = 1; #105;
		
		// Check if system stays at current state with Enable = 0.
		Enable = 0; L = 1; R = 0; H = 0; #105;
		L = 0; R = 1; #105;
		L = 1; R = 1; #105;
		H = 1; #105;
		$stop;
	end
	
	initial $monitor($time,,,,L,,,,R,,,,H,,,,,Enable,,,,"%b", out);
	
endmodule 