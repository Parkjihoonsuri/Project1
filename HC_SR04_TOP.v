module usensor (trig, echo, distance, reset, clk);
output trig, distance;
input clk, echo, reset;
reg  dist_counter=0;
reg  counter=0;
always @ (posedge clk)
begin
	if (reset)
		begin
			counter<=0;
			distance<=0;
		end
	else
		begin
			counter <= counter + 1;
			if (counter <= 500)         //10usec to initialize sensor
				begin
					echo<=0;
					trig<=1;              // trig is set high
				end
			if (echo)                   // sensing 5v at echo pin so echo pin is high
				begin
					dist_counter <= dist_counter + 1;
					trig <=0;
				end
			if (counter<= 1900000)	  // maximum time of sensing any object is 38ms
				begin
					echo<=0;
					trig<=0;
				end
			if (counter<= 5000000)      // wait 1 sec to begin again
				begin
				counter<=0;
				distance <=0;
				end
		end	
			
end
assign distance = (dist_counter ** (-1)) * 340;      // speed of sound in air
endmodule