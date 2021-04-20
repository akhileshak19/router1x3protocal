module router_fifo #(parameter DEPTH=16, WIDTH=9, ADD_SIZE=5)
(input clock, resetn, write_enb, read_enb, lfd_state, soft_reset, 
 input [7:0]data_in, 
 output reg full, empty, 
 output reg [7:0]data_out);

integer i;
reg [3:0]count;
reg [8:0]mem[15:0];
reg [ADD_SIZE-1:0]rd_add;
reg [ADD_SIZE-1:0]wr_add;

always@(posedge clock)
begin			
	if(~resetn) 		
		data_out<= 0;			
else if(soft_reset) 	
		data_out<= 8'bz;
else if (read_enb && ~empty) 	
		data_out <= mem[rd_add[3:0]][7:0];
else if(count==0)
		data_out<=8'bz;
end 

// full logic
always@*		
begin
	if(~resetn )
		full<= 1'b0;			
else if(soft_reset)
		full<= 1'b0;
else if((wr_add[4]!=rd_add[4])&&(wr_add[3:0] == rd_add[3:0]))
		full <= 1'b1;
else
		full <= 1'b0;				
end

// empty logic
always@*		
begin
	if(~resetn)
		empty<= 1'b1;
	else if(soft_reset)
		empty<= 1'b1;
	else if(rd_add == wr_add)
		empty <= 1'b1;
	else 
		empty <= 1'b0;
end	

//write address generator
always@(posedge clock) 	
begin
	if(~resetn)
		wr_add<= 0;
	else if(write_enb && ~full)
		wr_add<=wr_add +1;
end	

//read address generator
always@(posedge clock) 	
begin
	if(~resetn)
		rd_add <= 0;
	else if(read_enb && ~empty)
		rd_add <= rd_add +1;
end

always@(posedge clock)
begin
	if(~resetn)
		begin
			 for(i=0;i<16;i=i+1)
			 mem[i]<=0;
		end
	else if(soft_reset)
		begin
			for(i=0;i<16;i=i+1)
			mem[i]<=0;
		end	
		// lfd_state logic
	else if(write_enb && ~full)
		begin
 			if(lfd_state==1) 		
{mem[wr_add[3:0]][8], mem[wr_add[3:0]][7:0]} <= {1'b1,data_in};
			else 	
{mem[wr_add[3:0]][8],mem[wr_add[3:0]][7:0]}<={1'b0,data_in};
		end
end		

//loadable downcounter
always@(posedge clock) 	
begin	
if(read_enb && ~empty)
begin
		if (mem[rd_add][8]==1'b1)
				count <= mem[rd_add[3:0]][7:2]+1'b1;
		else if(count!=0)
count <= count-1;
end
end			
endmodule
