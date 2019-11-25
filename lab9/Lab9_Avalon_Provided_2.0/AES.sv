/************************************************************************
AES Decryption Core Logic

Dong Kai Wang, Fall 2017

For use with ECE 385 Experiment 9
University of Illinois ECE Department
************************************************************************/

module AES (
	input	 logic CLK,
	input  logic RESET,
	input  logic AES_START,
	output logic AES_DONE,
	input  logic [127:0] AES_KEY,
	input  logic [127:0] AES_MSG_ENC,
	output logic [127:0] AES_MSG_DEC
);

enum logic [4:0] {Wait, Load_Enc, Key_Schedule_Check, Key_Schedule_Check_one, Key_Schedule_Check_two, Key_Schedule_Check_three, Key_Schedule_Check_four, Key_Schedule_Check_five,
 Add_Round_Key, Check_Counter, Judge_Add_Round_Key_Path, Inv_Shift_Rows, Inv_Subbytes, Inv_Mix_Columns, Finish, Decrement_Counter_Signal, Inv_Mix_Columns_One,Inv_Mix_Columns_Two
 ,Inv_Mix_Columns_Three,Inv_Mix_Columns_Four} current_state, next_state;
logic [3:0] counter;
logic add_round_key_signal, inv_shift_rows_signal, inv_subbytes_signal, inv_mix_columns, decrement_counter_signal
, done_signal, add_round_key_type_increment, load_enc_signal,inv_mix_columns_final_load ; 
logic [1:0] add_round_key_type;
logic [1407:0] key_schedule;
logic [127:0] state, inv_shift_rows_result, inv_mix_columns_result;
logic [7:0] bytes_input [15:0];
logic [7:0] bytes_output[15:0];
logic [1:0] inv_mix_columns_mux;
logic [31:0] columns_input;
logic [31:0] columns_output;
logic [31:0] inv_mix_columns_result_one,inv_mix_columns_result_two,inv_mix_columns_result_three,inv_mix_columns_result_four;

always_ff @ (posedge CLK) begin

	if(RESET == 1) begin

		current_state <= Wait;

	end

	else begin

		current_state <= next_state;

	end
	
	if(RESET == 1) 
		add_round_key_type <= 2'b00;
	else if(add_round_key_type_increment == 1'b1) begin
		if(add_round_key_type == 2'b00)
			add_round_key_type <= 2'b01;
		else if(add_round_key_type == 2'b01)
			add_round_key_type <= 2'b10;
		else 
			add_round_key_type <= 2'b11;		
	end	
	else
		add_round_key_type <= add_round_key_type;
		
	if(RESET == 1)
		counter <= 4'b1011;
	else if(decrement_counter_signal == 1'b1) begin
	if(counter == 4'b1011)
		counter <= 4'b1010;
	else if(counter == 4'b1010)
		counter <= 4'b1001;
	else if(counter == 4'b1001)
		counter <= 4'b1000;
	else if(counter == 4'b1000)
		counter <= 4'b0111;
	else if(counter == 4'b0111)
		counter <= 4'b0110;	
	else if(counter == 4'b0110)
		counter <= 4'b0101;
	else if(counter == 4'b0101)
		counter <= 4'b0100;
	else if(counter == 4'b0100)
		counter <= 4'b0011;
	else if(counter == 4'b0011)
		counter <= 4'b0010;
	else if(counter == 4'b0010)
		counter <= 4'b0001;
	else
		counter <= 4'b0000;
	end
	else
		counter <= counter;	
	
	if(RESET == 1)
		state <= 128'd100;
	else if(load_enc_signal == 1'b1)
		state <= AES_MSG_ENC;
	else if(add_round_key_signal == 1'b1) begin
			if(counter == 4'b1011)
				state <= key_schedule[127:0] ^ state;
			else if(counter == 4'b0001)
				state <= key_schedule[1407:1280] ^ state;	
			else if(counter == 4'b1010)
				state <= key_schedule[255:128] ^ state;
			else if(counter == 4'b1001)
				state <= key_schedule[383:256] ^ state;
			else if(counter == 4'b1000)
				state <= key_schedule[511:384] ^ state;
			else if(counter == 4'b0111)
				state <= key_schedule[639:512] ^ state;
			else if(counter == 4'b0110)
				state <= key_schedule[767:640] ^ state;
			else if(counter == 4'b0101)
				state <= key_schedule[895:768] ^ state;
			else if(counter == 4'b0100)
				state <= key_schedule[1023:896] ^ state;
			else if(counter == 4'b0011)
				state <= key_schedule[1151:1024] ^ state;
			else if(counter == 4'b0010)
				state <= key_schedule[1279:1152] ^ state;
			else
				state <= state;
			
		end
	else if(inv_shift_rows_signal == 1'b1)
		state <= inv_shift_rows_result;
	else if(inv_subbytes_signal == 1'b1)
		state <= {bytes_output[15],bytes_output[14],bytes_output[13],bytes_output[12],bytes_output[11],bytes_output[10],bytes_output[9],bytes_output[8],
		bytes_output[7],bytes_output[6],bytes_output[5],bytes_output[4],bytes_output[3],bytes_output[2],bytes_output[1],bytes_output[0]};
//	else if(inv_mix_columns == 1'b1) begin
//		if(inv_mix_columns_mux == 2'b00)	
//			inv_mix_columns_result_one <= columns_output;
//		else if(inv_mix_columns_mux == 2'b01)
//			inv_mix_columns_result_two <= columns_output;
//		else if(inv_mix_columns_mux == 2'b10)
//			inv_mix_columns_result_three <= columns_output;
//		else
//			inv_mix_columns_result_four <= columns_output;
//		end
//	else if(inv_mix_columns_final_load == 1'b1)
//		state <= {inv_mix_columns_result_four,inv_mix_columns_result_three,inv_mix_columns_result_two,inv_mix_columns_result_one};
	else if(inv_mix_columns == 1'b1)
		state <= inv_mix_columns_result;
	else 
		state <= state;
		
		
	if(done_signal == 1'b1) begin
		AES_MSG_DEC <= state;
		AES_DONE <= 1'b1;
	end
	else begin
		AES_MSG_DEC <= AES_MSG_DEC;
		AES_DONE <= 1'b0;
	end
	
end


always_comb begin

	next_state = current_state;
	add_round_key_type_increment = 1'b0;
	add_round_key_signal = 1'b0;
	inv_shift_rows_signal = 1'b0;
	inv_subbytes_signal = 1'b0;
	inv_mix_columns = 1'b0;
	decrement_counter_signal = 1'b0;
	done_signal = 1'b0;
	load_enc_signal = 1'b0;
	inv_mix_columns_final_load = 1'b0;
	
	unique case(current_state) 
	
		Wait: begin
			
			if (AES_START == 1'b1)
				next_state = Load_Enc;
				
			else 
				next_state = Wait;
			
			end
		Load_Enc: begin
		
			load_enc_signal =1'b1;
		
			next_state = Key_Schedule_Check;
			
			end		
		Key_Schedule_Check: begin

				next_state = Key_Schedule_Check_one;
		
			end
			
		Key_Schedule_Check_one: begin
				
				next_state = Key_Schedule_Check_two;
			
			end
			
		Key_Schedule_Check_two: begin
				
				next_state = Key_Schedule_Check_three;
			
			end
		Key_Schedule_Check_three: begin
				
				next_state = Key_Schedule_Check_four;
			
			end
		Key_Schedule_Check_four: begin
				
				next_state = Key_Schedule_Check_five;
			
			end
		Key_Schedule_Check_five: begin
				
				next_state = Add_Round_Key;
			
			end
		Add_Round_Key: begin
			add_round_key_signal = 1'b1;	

			next_state = Decrement_Counter_Signal;
			
			end
		Decrement_Counter_Signal: begin
			decrement_counter_signal = 1'b1;		
			
			next_state = Check_Counter;
			
			end
		Check_Counter: begin
			
			if((counter == 4'b1001) || (counter == 4'b0000))                   // first entering loop 
				add_round_key_type_increment = 1'b1;  
			
			next_state = Judge_Add_Round_Key_Path;			
			
			end
			
		Judge_Add_Round_Key_Path: begin
		
		
			if(add_round_key_type == 2'b00) 
				next_state = Inv_Shift_Rows;
			
			else if(add_round_key_type == 2'b01) 
				next_state = Inv_Mix_Columns;		
			
			else 
				next_state = Finish;
				
		end
			
		Inv_Shift_Rows: begin
			inv_shift_rows_signal = 1'b1;
			
			next_state = Inv_Subbytes;
			
			end
			
		Inv_Subbytes: begin
			inv_subbytes_signal = 1'b1;
				
			next_state = Add_Round_Key;
			
			end
			
//		Inv_Mix_Columns_One: begin
//			inv_mix_columns = 1'b1;
//			
//			inv_mix_columns_mux = 2'b00;			
//			
//			next_state = Inv_Mix_Columns_Two;
//			end
//			
//		Inv_Mix_Columns_Two: begin
//			inv_mix_columns = 1'b1;
//			
//			inv_mix_columns_mux = 2'b01;
//			
//			next_state = Inv_Mix_Columns_Three;
//			end
//			
//		Inv_Mix_Columns_Three: begin
//			inv_mix_columns = 1'b1;
//			
//			inv_mix_columns_mux = 2'b10;
//
//		
//			next_state = Inv_Mix_Columns_Four;
//			end
//		
//		Inv_Mix_Columns_Four: begin
//			inv_mix_columns = 1'b1;
//			
//			inv_mix_columns_mux = 2'b11;
//		
//			next_state = Inv_Mix_Columns;
//			
//			end
		Inv_Mix_Columns: begin
//			inv_mix_columns_final_load = 1'b1;

			inv_mix_columns = 1'b1;
			next_state = Inv_Shift_Rows; 
			
			end
		Finish: begin
			done_signal = 1'b1;
			
			if (AES_START == 1'b1) 
				next_state = Finish;
				
			else
				next_state = Wait;
			
			end
			
	endcase

end

KeyExpansion key_expansion(.clk(CLK), .Cipherkey(AES_KEY), .KeySchedule(key_schedule));   // AES_KEY cannot be changed during AES decrypt
//InvMixColumns invmixcolumns(.in(state), .out(inv_mix_columns_result)); // pass 128 bit to invmixcolumn
InvShiftRows invshiftrows(.data_in(state), .data_out(inv_shift_rows_result));
//SubBytes subbytes(.clk(CLK), .in(state), .out(subbytes_result)); // pass 128 bit to subbytes

assign {bytes_input[15],bytes_input[14],bytes_input[13],bytes_input[12],bytes_input[11],bytes_input[10],bytes_input[9],bytes_input[8],
bytes_input[7],bytes_input[6],bytes_input[5],bytes_input[4],bytes_input[3],bytes_input[2],bytes_input[1],bytes_input[0]} =state;

InvSubBytes subbytes_fifteen(.clk(CLK), .in(bytes_input[15]), .out(bytes_output[15]));
InvSubBytes subbytes_fourteen(.clk(CLK), .in(bytes_input[14]), .out(bytes_output[14]));
InvSubBytes subbytes_thirdteen(.clk(CLK), .in(bytes_input[13]), .out(bytes_output[13]));
InvSubBytes subbytes_twelve(.clk(CLK), .in(bytes_input[12]), .out(bytes_output[12]));
InvSubBytes subbytes_eleven(.clk(CLK), .in(bytes_input[11]), .out(bytes_output[11]));
InvSubBytes subbytes_ten(.clk(CLK), .in(bytes_input[10]), .out(bytes_output[10]));
InvSubBytes subbytes_nine(.clk(CLK), .in(bytes_input[9]), .out(bytes_output[9]));
InvSubBytes subbytes_eight(.clk(CLK), .in(bytes_input[8]), .out(bytes_output[8]));
InvSubBytes subbytes_seven(.clk(CLK), .in(bytes_input[7]), .out(bytes_output[7]));
InvSubBytes subbytes_six(.clk(CLK), .in(bytes_input[6]), .out(bytes_output[6]));
InvSubBytes subbytes_five(.clk(CLK), .in(bytes_input[5]), .out(bytes_output[5]));
InvSubBytes subbytes_four(.clk(CLK), .in(bytes_input[4]), .out(bytes_output[4]));
InvSubBytes subbytes_three(.clk(CLK), .in(bytes_input[3]), .out(bytes_output[3]));
InvSubBytes subbytes_two(.clk(CLK), .in(bytes_input[2]), .out(bytes_output[2]));
InvSubBytes subbytes_one(.clk(CLK), .in(bytes_input[1]), .out(bytes_output[1]));
InvSubBytes subbytes_zero(.clk(CLK), .in(bytes_input[0]), .out(bytes_output[0]));

InvMixColumns invmixcolumns_one(.in(state[31:0]), .out(inv_mix_columns_result_one));
InvMixColumns invmixcolumns_two(.in(state[63:32]), .out(inv_mix_columns_result_two));
InvMixColumns invmixcolumns_three(.in(state[95:64]), .out(inv_mix_columns_result_three));
InvMixColumns invmixcolumns_four(.in(state[127:96]), .out(inv_mix_columns_result_four));

assign inv_mix_columns_result = {inv_mix_columns_result_four,inv_mix_columns_result_three,inv_mix_columns_result_two,inv_mix_columns_result_one};
//always_comb begin         // mux for inv_mix_columns
//
//if(inv_mix_columns_mux == 2'b00)
//	columns_input = state[31:0];
//else if(inv_mix_columns_mux == 2'b01)
//	columns_input = state[63:32];
//else if(inv_mix_columns_mux == 2'b10)
//	columns_input = state[95:64];
//else
//	columns_input = state[127:96];
//
//end

endmodule
