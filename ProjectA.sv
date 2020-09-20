// Trung Do and Rohan Seam
// 5/18/2020
//
// Top level module that connects out implementation of the thunderbird tail light to the 
// DE2-115 board. The CLOCK_50 input is the 50 MHz clock that is supplied by the board. This 
// is used as an input to our module to control the flip-flops and allow the system to propagate
// from state to state. The SW inputs allow us to control the left turn signal (SW[2]), the right 
// turn signal (SW[1]), and the hazard signal (SW[0]). The LEDRs are used to display the state of 
// our switches to the user. The LEDGs are used to display the state of the tail lights at each 
// state. LEDG[5:3] represent the left tail lights, while the LEDG[2:0] represent the right tail 
// light. 
module ProjectA(CLOCK_50, SW, LEDR, LEDG);
	input CLOCK_50;
	input [2:0] SW;					// SW[0] = hazard, SW[1] = right, SW[2] = left
	output [2:0] LEDR;
	output [5:0] LEDG;				// LEDG[5:3] = LcLbLa, LEDG[2:0] = RaRbRc
	logic oneHzClk;
	
	assign LEDR = SW;					// Assign the switches to the LEDRs to display state of switches.
	
	// module Timer(Clock, Out);
	Timer u1(CLOCK_50, oneHzClk);
	
	// TaillightsFSM(Clock, Enable, L, R, H, out);
	TaillightsFSM u2(CLOCK_50, oneHzClk, SW[2], SW[1], SW[0], LEDG[5:0]);
endmodule 