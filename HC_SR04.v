
module ultra_sonic(
    input clk,
    input reset_p,
    input echo,							// HCSR04 Output -> MCU Input
    output reg trigger,					// MCU Output -> HCSR04 Input
    output reg [15:0] distance,			
    output reg [7:0] led_bar			// debugging
    );
    
    //* Define Parameters */
    parameter S_IDLE		 = 1;			// wait for next correct action
    parameter S_T_HIGH_10US = 2;			// output trigger to HCSR04
    parameter S_E_READ		 = 3;			// input echo read pedge and nedge
    parameter S_READ_DATA	 = 4;			// calculate distance
    
    parameter S_WAIT_PEDGE = 5;			// when pedge detect
    parameter S_WAIT_NEDGE = 6;			// when nedge detect
    
    wire clk_usec;
    wire hc_nedge, hc_pedge;					
    
    reg count_usec_e;
    reg [15:0] count_usec;							// 
    reg [3:0] state, next_state, read_state;		// state
    reg [15:0] count_start, count_end;				// start : pedge, end : nedge
    
    reg [16:0] echo_pw;
    reg [16:0] temp_value [15:0];
    reg [15:0] sum_value;
    reg [3:0] index;
    
    // Clock
    clock_usec clk_us(.clk(clk), .reset_p(reset_p), .clk_usec(clk_usec));
    
    // usec Count
    always @(negedge clk or posedge reset_p)begin
    	if(reset_p)count_usec = 0;												// reset
    	else if(count_usec_e && clk_usec) count_usec = count_usec + 1;			// when count_usec enable(1) and sync clk nedge and clk_usec => count time per usec
    	else if(!count_usec_e) count_usec = 0;									// when count_usec disable(0) => reset count_usec = 0 and stop counting
    end
    
    // Status Register
    always @(negedge clk or posedge reset_p)begin                               
    	if(reset_p)state = S_IDLE;												// reset
    	else state = next_state;												// when clk negde => state get next_state
    end
    
    // echo signal Edge Detecter
    edge_detector_n ed_dec (.clk(clk), .cp_in(echo), .reset_p(reset_p), .n_edge(hc_nedge), .p_edge(hc_pedge));
    																			// echo Edge Detecter, when clk nedge => echo negde : hc_nedge, echo pedge : hc_pedge
    // Communication Part
    always @(posedge clk or posedge reset_p)begin								// when clk pedge
    	// all state and variable RESET 
    	if(reset_p)begin
    		index = 0;
    		count_usec_e <= 0;
    		next_state <= S_IDLE;
    		read_state <= S_WAIT_PEDGE;
    		trigger <= 0;
    		count_start <= 0;
    		count_end <= 0;
    		distance <= 0;
    		led_bar <= 8'b1111_1111;
    	end
    	else begin
    		case(state)
    			S_IDLE : begin							// wait for next action
    				led_bar[0] <= 0;
    				if(count_usec < 16'd65_535)begin	// 65.535ms(datasheet = 60ms)
    					count_usec_e <= 1;				// count start
    					trigger <= 0;					// trigger reset
    				end
    				else begin							// when time over 65.535ms
    					led_bar <= 8'b1111_1111;
    					next_state <= S_T_HIGH_10US;		// state change
    					count_usec_e <= 0;				// count stop
    				end
    			end
    			S_T_HIGH_10US : begin						// start trigger sign to HCSR04, trigger 10us
    				led_bar[1] <= 0;
    				if(count_usec < 16'd16)begin		// 16us trigger
    					count_usec_e <= 1;				// count start
    					trigger <= 1;					// trigger High
    				end
    				else begin							// when time over 16us 
    				count_usec_e <= 0;					// count stop
    				next_state <= S_E_READ;				// state change
    				trigger <= 0;						// trigger Low
    				read_state <= S_WAIT_PEDGE;			// read_state reset
    				end
    			end
    			S_E_READ : begin						// echo Edge Detect & save start and end time Part
    				led_bar[2] <= 0;
    				case(read_state)					// echo Edge Detect read state
    					S_WAIT_PEDGE : begin			// pedge wait
    						led_bar[3] <= 0;
    						if(hc_pedge)begin			// when pedge detect
    							read_state <= S_WAIT_NEDGE;	// change read_state
    							count_start <= count_usec;	// start = current usec
    						end
    						else if(count_usec > 16'd23_201) begin	// when 4m overflow
    							read_state <= S_WAIT_PEDGE;			// read_state reset
    							next_state <= S_IDLE;				// state reset
    						end
    						else count_usec_e <= 1;					// wait, count start
    					end
    					S_WAIT_NEDGE : begin						// nedge wait
    						led_bar[4] <= 0;
    						if(count_usec < 16'd23_201)begin		// maximum 4m
    							if(hc_nedge)begin					// when nedge detect
    								next_state <= S_READ_DATA;		// state change
    								temp_value[index] <= count_usec;		// end = current usec
    								index = index + 1;
    							end
    							else begin							// continue detect negde
    								count_usec_e <= 1;				// count start
    								read_state <= S_WAIT_NEDGE;		// read_state continue
    							end
    						end
    						else begin								// when distance beyond 4m
    							read_state <= S_WAIT_PEDGE;			// read_state reset
    							next_state <= S_IDLE;				// state reset
    						end
    					end
    					default : begin								// when state occured error
    						read_state = S_WAIT_PEDGE;				// read_state reset
    						next_state = S_IDLE;					// state reset
    					end
    				endcase	
    			end
    			S_READ_DATA : begin									// when echo Edge detection success
    				led_bar[5] <= 0;								
    				distance <= (temp_value[index] - count_start) / 58;		// calculate distance
    				count_start <= 0;								// count reset
    				count_end <= 0;								
    				next_state <= S_IDLE;							// state reset
    				read_state <= S_WAIT_PEDGE;						// read_state reset
    			end
    			default : next_state = S_IDLE;						// when state occured error => reset
    		endcase
    	end
    end
    reg [4:0] i;
    always@(posedge clk_usec or posedge reset_p)begin
        if(reset_p)begin
            sum_value = 0;
            i = 0;
        end
        else begin
            sum_value = 0;
            for(i=0; i<16; i=i+1)begin
                sum_value = sum_value + temp_value[i];
            end
        end
    end
    always@(posedge clk_usec or posedge reset_p)begin
        if(reset_p) distance = 0;
        else distance = sum_value[20:4] / 58;
    end
    
endmodule

module ultra_sonic_top(
	input clk, reset_p,
	input echo,
	output trigger,
	output [3:0] com,
	output [7:0] seg_7,
	output [7:0] led_bar
    );
    
    wire [15:0] distance;
    wire [15:0] bcd_distance;
   // wire [15:0] distance_fnd;
    
    ultra_sonic distance_check(.clk(clk), .reset_p(reset_p), .echo(echo), .trigger(trigger), .distance(distance), .led_bar(led_bar));	// get distance value
    
    bin_to_dec btd_distance(.bin(distance), .bcd(bcd_distance));																		// change to decimal_distance
    		
    fnd_4digit_cntr FND_distance(.clk(clk), .value(bcd_distance), .com(com), .seg_7(seg_7));											// FND print decimal_distance
    // FND_4digit_cntr FND_distance(.clk(clk), .value(distance), .com(com), .seg_7(seg_7));
    
endmodule
