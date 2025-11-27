module Modulo_k_Counter (Q, Clk, Reset, En, Rollover);
	parameter n = 5;
    	parameter k = 20;

    	input  Clk, Reset, En;
    	output reg [n-1:0] Q;
    	output reg Rollover; 
    	always @(posedge Clk or negedge Reset) 
    	begin
        	if (!Reset) 
		begin
            		Q <= 0;
            		Rollover <= 0;
        	end

        	else if (En) 
		begin
			if (Q == k - 1) begin
                	Q <= 0;
             		Rollover <= 1;  
            	end

            else 
	    begin
                Q <= Q + 1;
                Rollover <= 0;   
            end

        end

        else
            Rollover <= 0;
    
end

endmodule
