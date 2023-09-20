module MyDesign (
//---------------------------------------------------------------------------
//Control signals
  input   wire dut_run                    , 
  output  reg dut_busy                   ,
  input   wire reset_b                    ,  
  input   wire clk                        ,
 
//---------------------------------------------------------------------------
//Input SRAM interface
  output reg        input_sram_write_enable    ,
  output reg [11:0] input_sram_write_addresss  ,
  output reg [15:0] input_sram_write_data      ,
  output reg [11:0] input_sram_read_address    ,
  input wire [15:0] input_sram_read_data       ,

//---------------------------------------------------------------------------
//output SRAM interface
  output reg        output_sram_write_enable    ,
  output reg [11:0] output_sram_write_addresss  ,
  output reg [15:0] output_sram_write_data      ,
  output reg [11:0] output_sram_read_address    ,
  input wire [15:0] output_sram_read_data       ,

//---------------------------------------------------------------------------
//Scratchpad SRAM interface
  output reg        scratchpad_sram_write_enable    ,
  output reg [11:0] scratchpad_sram_write_addresss  ,
  output reg [15:0] scratchpad_sram_write_data      ,
  output reg [11:0] scratchpad_sram_read_address    ,
  input wire [15:0] scratchpad_sram_read_data       ,

//---------------------------------------------------------------------------
//Weights SRAM interface                                                       
  output reg        weights_sram_write_enable    ,
  output reg [11:0] weights_sram_write_addresss  ,
  output reg [15:0] weights_sram_write_data      ,
  output reg [11:0] weights_sram_read_address    ,
  input wire [15:0] weights_sram_read_data       

);

  //YOUR CODE HERE

  parameter s0 = 5'b00000,s1 = 5'b00001,s2 = 5'b00010,s3 = 5'b00011,s4 = 5'b00100,s5 = 5'b00101,s6 = 5'b00110,s7 = 5'b00111,s8 = 5'b01000;
	parameter s9 = 5'b01001,s10 = 5'b01010,s11 = 5'b01011,s12 = 5'b01100,s13 = 5'b01101,s14 = 5'b01110,s15 = 5'b01111,s16 = 5'b10000,s17 = 5'b10001,s18  = 5'b10010;
  reg [4:0]	current_state,	next_state;
  reg [7:0] temp1, temp2;
  reg [15:0] final;
  reg [2:0]   addr_inputs_selection;
  reg [1:0]   addr_weights_selection;
  reg [1:0]   write_enable_addr;
  
  reg valid_convolution_begin;
  reg begin_get_data;
  reg [3:0] compl;

  reg [11:0] next_addr;
  reg next_addr_sel;
  
  reg signed [7:0] data_input_1, data_input_2, data_input_3, data_input_4, data_input_5, input_data_6, data_input_7, data_input_8;
  reg signed [7:0] data_input_9, data_input_10, data_input_11, data_input_12, data_input_13, data_input_14, data_input_15, data_input_16;

  reg signed [7:0] kerenel_00,kerenel_01,kerenel_02,kerenel_10,kerenel_11,kerenel_12,kerenel_20,kerenel_21,kerenel_22;
  reg signed [19:0] mac_1,mac_2, mac_3, mac_4;
  reg [11:0] input_sram_read_address1;
  reg [11:0] sram_write_addresss;


  reg clear_new;
  reg clear_address_selection;
  reg [5:0] cc;
  reg cc_sel;

  reg [5:0] rc;
  reg signed [19:0] pool_1, pool_2;
  reg signed [19:0] pool_final;
  reg [7:0] relu_final;
  reg s_sel;
  reg [15:0] output_dimension;

  reg clear_off;
  reg[19:0] off;

  reg wc;
  reg [1:0] wc_sel;

  reg signed [19:0] temp11, temp22, temp33, temp44, temp55, temp66, temp77, temp88;







  //FSM
	always @(posedge clk or negedge reset_b) 
  begin
		if (!reset_b)
			current_state <= 4'd0;
		else
			current_state <= next_state;
	end

  always @(*) begin
		casex (current_state)
      s0 :
       begin
        clear_new = 1;
        clear_address_selection = 1;
        clear_off = 1;
        s_sel = 1;
        cc_sel = 0;
        addr_inputs_selection = 2'd1;
        addr_weights_selection = 2'd1;
        next_addr_sel = 0;
        begin_get_data = 0;
        dut_busy = 0;
        valid_convolution_begin = 0;
        write_enable_addr = 2'd0;
        output_sram_write_enable = 0;
        wc_sel = 2'd0;
        if (dut_run == 1) next_state = s1;
        else next_state = s0;
      end

    s1 : 
    begin
        clear_new = 1;
        clear_address_selection = 1;
        clear_off = 1;
        s_sel = 1;
        cc_sel = 0;
        addr_inputs_selection = 2'd1;
        addr_weights_selection = 2'd1;
        next_addr_sel = 0;
        begin_get_data = 0;
        dut_busy = 1;
        valid_convolution_begin = 0;
        write_enable_addr = 2'd0;
        output_sram_write_enable = 0;
        wc_sel = 2'd0;
        next_state = s2;
      end


      s2:
       begin
        clear_new = 1;
        clear_address_selection = 0;
        clear_off = 0;
        s_sel = 0;
        cc_sel = 0;
        addr_inputs_selection = 2'd1;
        addr_weights_selection = 2'd1;
        next_addr_sel = 0;
        begin_get_data = 0;
        valid_convolution_begin = 0;
        write_enable_addr = 2'd1;
        output_sram_write_enable = 0;
        wc_sel = 2'd1;
        dut_busy = 1;
        next_state = s3;
      end

      s3: 
      begin
        clear_new = 0;
        clear_address_selection = 0;
        clear_off = 0;
        s_sel = 0;
        cc_sel = 0;
        addr_inputs_selection = 2'd2;
        addr_weights_selection = 2'd0;
        next_addr_sel = 0;
        begin_get_data = 0;
        valid_convolution_begin = 0;
        write_enable_addr = 2'd1;
        output_sram_write_enable = 0;
        wc_sel = 2'd1;
        dut_busy = 1;
        next_state = s4;
      end

      s4: 
      begin
        clear_new = 0;
        clear_address_selection = 0;
        clear_off = 0;
        s_sel = 1;
        cc_sel = 0;
        addr_inputs_selection = 2'd2;
        addr_weights_selection = 2'd0;
        next_addr_sel = 0;
        begin_get_data = 0;
        valid_convolution_begin = 0;
        write_enable_addr = 2'd1;
        output_sram_write_enable = 0;
        wc_sel = 2'd1;
        dut_busy = 1;
        if (output_dimension == 16'hffff) 
          next_state = s18;
        else 
          next_state = s5;
      end

      s5: 
      begin
        clear_new = 0;
        clear_address_selection = 0;
        clear_off = 0;
        s_sel = 1;
        cc_sel = 0;
        addr_inputs_selection = 2'd3;
        addr_weights_selection = 2'd2;
        next_addr_sel = 0;
        begin_get_data = 1;
        valid_convolution_begin = 0;
        write_enable_addr = 2'd1;
        output_sram_write_enable = 0;
        wc_sel = 2'd1;
        dut_busy = 1;
        next_state = s6;
      end

      
      s9: begin
        clear_new = 0;
        clear_address_selection = 0;
        clear_off = 0;
        s_sel = 1;
        cc_sel = 0;
        addr_inputs_selection = 2'd3;
        addr_weights_selection = 2'd2;
        next_addr_sel = 0;
        begin_get_data = 1;
        valid_convolution_begin = 0;
        write_enable_addr = 2'd1;
        output_sram_write_enable = 0;
        wc_sel = 2'd1;
        dut_busy = 1;
        next_state = s10;
      end

      s10:
       begin
        addr_weights_selection = 2'd1;
        next_addr_sel = 0;
        begin_get_data = 1;
        valid_convolution_begin = 0;
        write_enable_addr = 2'd1;
        output_sram_write_enable = 0;
        wc_sel = 2'd1;
        clear_new = 0;
        clear_address_selection = 0;
        clear_off = 0;
        s_sel = 1;
        cc_sel = 0;
        addr_inputs_selection = 2'd2;
        dut_busy = 1;
        next_state = s11;
      end

      s11:
       begin
        addr_weights_selection = 2'd1;
        next_addr_sel = 0;
        begin_get_data = 1;
        valid_convolution_begin = 0;
        write_enable_addr = 2'd1;
        output_sram_write_enable = 0;
        wc_sel = 2'd1;
        dut_busy = 1;
        clear_new = 0;
        clear_address_selection = 0;
        clear_off = 0;
        s_sel = 1;
        cc_sel = 1;
        addr_inputs_selection = 2'd1;
        next_state = s12;
      end

      s12: begin
        clear_new = 0;
        clear_address_selection = 0;
        clear_off = 0;
        s_sel = 1;
        cc_sel = 0;
        addr_inputs_selection = 2'd1;
        addr_weights_selection = 2'd1;
        next_addr_sel = 0;
        begin_get_data = 0;
        valid_convolution_begin = 0;
        write_enable_addr = 2'd1;
        output_sram_write_enable = 0;
        wc_sel = 2'd1;
        dut_busy = 1;
        next_state = s13;
      end
      s17: 
      begin
        
        addr_weights_selection = 2'd1;
        next_addr_sel = 0;
        begin_get_data = 0;
        valid_convolution_begin = 0;
        write_enable_addr = 2'd1;
        output_sram_write_enable = 0;
        wc_sel = 2'd2;
        clear_new = 1;
        clear_address_selection = 1;
        clear_off = 0;
        s_sel = 1;
        cc_sel = 0;
        addr_inputs_selection = 2'd1;
        dut_busy = 1;
        next_state = s2;
      end

      s18: 
      begin
        clear_new = 1;
        clear_address_selection = 1;
        clear_off = 0;
        s_sel = 1;
        cc_sel = 0;
        addr_inputs_selection = 2'b01;
        addr_weights_selection = 2'b01;
        next_addr_sel = 0;
        begin_get_data = 0;
        valid_convolution_begin = 0;
        write_enable_addr = 2'b01;
        output_sram_write_enable = 1;
        wc_sel = 2'b10;
        dut_busy = 1;
        next_state = s0;
      end


      s13: 
      begin
        addr_inputs_selection = 2'd1;
        addr_weights_selection = 2'd1;
        next_addr_sel = 1;
        begin_get_data = 0;
        valid_convolution_begin = 1;
        write_enable_addr = 2'd1;
        output_sram_write_enable = 0;
        wc_sel = 2'd1;
        clear_new = 0;
        clear_address_selection = 0;
        clear_off = 0;
        s_sel = 1;
        cc_sel = 0;
        dut_busy = 1;
        next_state = s14;
      end 

      s14: 
      begin
        clear_new = 0;
        clear_address_selection = 0;
        clear_off = 0;
        s_sel = 1;
        cc_sel = 0;
        addr_inputs_selection = 2'd1;
        addr_weights_selection = 2'd1;
        next_addr_sel = 0;
        begin_get_data = 0;
        valid_convolution_begin = 0;
        write_enable_addr = 2'd1;
        output_sram_write_enable = 0;
        wc_sel = 2'd1;
        dut_busy = 1;
        next_state = s15;
      end

      s15: 
      begin
        clear_new = 0;
        clear_address_selection = 0;
        clear_off = 0;
        s_sel = 1;
        cc_sel = 0;
        addr_inputs_selection = 2'd0;
        addr_weights_selection = 2'd1;
        next_addr_sel = 0;
        begin_get_data = 0;
        valid_convolution_begin = 0;
        write_enable_addr = 2'd1;
        output_sram_write_enable = 0;
        wc_sel = 2'd2;
        dut_busy = 1;
        if ((wc == 1) || ((rc ==(output_dimension-2'd2)) && (cc == 1))) 
            next_state = s16;
        else 
            next_state = s4;
  
      end

      s16: 
      begin
        next_addr_sel = 0;
        begin_get_data = 0;
        valid_convolution_begin = 0;
        write_enable_addr = 2'd2;
        output_sram_write_enable = 1;
        wc_sel = 2'd1;
        dut_busy = 1;
        clear_new = 0;
        clear_address_selection = 0;
        clear_off = 0;
        s_sel = 1;
        cc_sel = 0;
        addr_inputs_selection = 2'd1;
        addr_weights_selection = 2'd1;
        if ((rc ==(output_dimension-2'd2)) && (cc == 1)) 
           next_state = s17;
        else next_state = s4;
      end

      s6:
       begin
        clear_new = 0;
        clear_address_selection = 0;
        clear_off = 0;
        s_sel = 1;
        cc_sel = 0;
        addr_inputs_selection = 2'd2;
        addr_weights_selection = 2'd2;
        next_addr_sel = 0;
        begin_get_data = 1;
        valid_convolution_begin = 0;
        write_enable_addr = 2'd1;
        output_sram_write_enable = 0;
        wc_sel = 2'd1;
        dut_busy = 1;
        next_state = s7;
      end

      s7: 
      begin
        clear_new = 0;
        clear_address_selection = 0;
        clear_off = 0;
        s_sel = 1;
        cc_sel = 0;
        addr_inputs_selection = 2'd3;
        addr_weights_selection = 2'b10;
        next_addr_sel = 0;
        begin_get_data = 1;
        valid_convolution_begin = 0;
        write_enable_addr = 2'b01;
        output_sram_write_enable = 0;
        wc_sel = 2'b01;
        dut_busy = 1;
        next_state = s8;
      end

      s8: 
      begin
        next_addr_sel = 0;
        begin_get_data = 1;
        valid_convolution_begin = 0;
        write_enable_addr = 2'd1;
        clear_new = 0;
        clear_address_selection = 0;
        clear_off = 0;
        s_sel = 1;
        cc_sel = 0;
        addr_inputs_selection = 2'd2;
        addr_weights_selection = 2'd2;
        output_sram_write_enable = 0;
        wc_sel = 2'd1;
        dut_busy = 1;
        next_state = s9;
      end

      
      default :
       begin
        clear_new = 1;
        clear_address_selection = 1;
        clear_off = 1;
        addr_inputs_selection = 2'b01;
        addr_weights_selection = 2'b01;
        next_addr_sel = 0;

        dut_busy = 0;
        
        s_sel = 1;
        cc_sel = 0;
        
        begin_get_data = 0;
        
        valid_convolution_begin = 0;
        write_enable_addr = 2'b00;
        output_sram_write_enable = 0;
        wc_sel = 2'b00;
        next_state = s0;
			end
		endcase
  end

  always @(posedge clk) 
  begin

    if (clear_off == 1) 
        off <=0;
    else if (rc ==(output_dimension-3'd4)) 
    begin
      if(cc == (output_dimension>>1))
        off <= input_sram_read_address + 1;
    end
  end


/*assign compl = (begin_get_data==1) ? compl+1 : 0;*/
always @(posedge clk) 
  begin
  case(begin_get_data)
  1'b1:compl <= compl+1;
  1'b0:compl <=0;
  //default:compl <=0;
  endcase  
  end

  always @(posedge clk) 
  begin//datapath
    case(s_sel)
    1'b0:output_dimension <= input_sram_read_data;
    1'b1:output_dimension <= output_dimension;
    //default:output_dimension <= output_dimension;
  endcase
  end

  always @(posedge clk) 
  begin
  case(compl)
  4'b0000:
  begin
      data_input_1 <= input_sram_read_data[15:8];
      data_input_2 <= input_sram_read_data[7:0];
    end
  4'b0001:
  begin
      kerenel_00 <= weights_sram_read_data[15:8];
      kerenel_01 <= weights_sram_read_data[7:0];
      
      data_input_3 <= input_sram_read_data[15:8];
      data_input_4 <= input_sram_read_data[7:0];
      
    end
  4'b0010:
  begin
      kerenel_02 <= weights_sram_read_data[15:8];
      kerenel_10 <= weights_sram_read_data[7:0];

      data_input_5 <= input_sram_read_data[15:8];
      input_data_6 <= input_sram_read_data[7:0];
      
    end
  4'b0011:
  begin
      kerenel_11 <= weights_sram_read_data[15:8];
      kerenel_12 <= weights_sram_read_data[7:0];

      data_input_7 <= input_sram_read_data[15:8];
      data_input_8 <= input_sram_read_data[7:0];
      
    end
  4'b0100:
  begin
      kerenel_20 <= weights_sram_read_data[15:8];
      kerenel_21 <= weights_sram_read_data[7:0];

      data_input_9 <= input_sram_read_data[15:8];
      data_input_10 <= input_sram_read_data[7:0];
      
    end

  4'b0101:
  begin
      data_input_11 <= input_sram_read_data[15:8];
      data_input_12 <= input_sram_read_data[7:0];
      kerenel_22 <= weights_sram_read_data[15:8];
    end
  4'b0110:
  begin
      data_input_13 <= input_sram_read_data[15:8];
      data_input_14 <= input_sram_read_data[7:0];
    end
  4'b0111:
  begin
      data_input_15 <= input_sram_read_data[15:8];
      data_input_16 <= input_sram_read_data[7:0];
    end
  default:
  begin
      data_input_1 <= input_sram_read_data[15:8];
      data_input_2 <= input_sram_read_data[7:0];
    end
  endcase
  end

  always @(posedge clk)
   begin
    casez({ clear_new, (cc == ((output_dimension>>1))), cc_sel})
      3'b100 : cc <= 1;
      3'b010 : cc <= 1;
      3'b011 : cc <= 1;
      3'b000 : cc <= cc;
      3'b001 : cc <= cc + 1;
      default : cc <= 1;
    endcase
  end

  always @(posedge clk) 
  begin
    casex({clear_new, (cc == ((output_dimension>>1))) })
      2'b00 : rc <= rc;
      2'b01 : rc <= rc + 2;
      2'b1x : rc <= 0;
      //2'b11 : rc <= 0;
      //default: rc <= 0;
    endcase
  end

  /*always @(posedge clk) begin
    casex({clear_new, (cc == ((output_dimension>>1))) })
      2'b1x : rc <= 0;
      2'b01 : rc <= rc + 2;
      2'b00 : rc <= rc;
      default : rc <= 0; 
      endcase
    //if (col_count == ((size>>1)-1)) row_count <= row_count + 1;
    //else row_count <= row_count;
  end*/


  always @(posedge clk) 
  begin 
    if (next_addr_sel)
      next_addr = (rc * (output_dimension >> 1) + cc);  
    //else
      //next_addr = next_addr;
  end

// For input read addresses
  always @(posedge clk) 
  begin
    case({clear_address_selection, addr_inputs_selection}) 
      3'b000 : input_sram_read_address1 <= next_addr;
      3'b001 : input_sram_read_address1 <= input_sram_read_address1;
      3'b010 : input_sram_read_address1 <= input_sram_read_address1 + 1;
      3'b011 : input_sram_read_address1 <= input_sram_read_address1 + ((output_dimension>>1)-1 );
      3'b100 : input_sram_read_address1 <= 0;
      3'b111 : input_sram_read_address1 <= 0;
      //3'b100 : input_sram_read_address1 <= 0;
      3'b101 : input_sram_read_address1 <= 0; 
      3'b110:  input_sram_read_address1 <= 0;
      default : input_sram_read_address1 <= 0;
    endcase


  end

  always @(*) 
  begin
    input_sram_read_address = input_sram_read_address1 + off;
  end

 always @(posedge clk) 
 begin
    if (addr_weights_selection == 2'b00)
      weights_sram_read_address <= 0;
    else if (addr_weights_selection == 2'b01)
      weights_sram_read_address <= weights_sram_read_address;
    else if (addr_weights_selection == 2'b10 )
      weights_sram_read_address <= weights_sram_read_address + 1'b1; 
  end


always @(posedge clk) begin
  if (write_enable_addr == 2'b00)
    output_sram_write_addresss <= 12'b0 - 1;
  else if (write_enable_addr == 2'b01)
    output_sram_write_addresss <= output_sram_write_addresss;
  else if (write_enable_addr == 2'b10)
    output_sram_write_addresss <= output_sram_write_addresss + 12'b1;
 end 

 always @(posedge clk)
   begin
    if (wc == 0) 
    begin
      temp1 <= relu_final;
      temp2 <= 0; 
    end
    else 
    begin
      temp2 <= relu_final;
    end
    if (output_sram_write_enable == 1)  
       output_sram_write_data = {temp1, temp2};
    else 
        output_sram_write_data = output_sram_write_data;
  end
 
always @(posedge clk) 
begin//o/p writecount
  case(wc_sel)
  2'b00:wc<=0;
  2'b01:wc <= wc;
  2'b10:wc <= wc + 1;
  default: wc<=0;
  endcase
 end 

always@(*)
begin
  if(mac_1 > mac_2)
    pool_1=mac_1;
  else
    pool_1=mac_2;
  if(mac_3 > mac_4)
    pool_2=mac_3;
  else
   pool_2=mac_4;
  /*pool_1 = (mac_1 > mac_2) ? mac_1 : mac_2;
  pool_2 = (mac_3 > mac_4) ? mac_3 : mac_4;*/
end

  always @(*) 
  begin
    if (pool_1 > pool_2) pool_final = pool_1;
    else pool_final = pool_2;
  end
  
  always @(posedge clk) 
  begin
      if ((pool_final>0) && (pool_final<127))
         relu_final <= pool_final;
       else if (pool_final < 0)
         relu_final <= 0;
       else if(pool_final == 0)
         relu_final <= 0;
       else if (pool_final > 127)
         relu_final <= 127;
       else if (pool_final == 127)
         relu_final <= 127;
  end

 always @(posedge clk) 
  begin
    if (valid_convolution_begin == 1) 
    begin
      temp11 = (data_input_1 * kerenel_00)+(data_input_2 * kerenel_01)+(data_input_3 * kerenel_02) + (data_input_5 * kerenel_10);
      temp22 = (input_data_6 * kerenel_11)+(data_input_7 * kerenel_12) + (data_input_9 * kerenel_20)+(data_input_10 * kerenel_21)+(data_input_11 * kerenel_22);
      temp33 = (data_input_5*kerenel_00)+(input_data_6*kerenel_01)+(data_input_7*kerenel_02) + (data_input_9*kerenel_10)+(data_input_10*kerenel_11);
      temp44 = (data_input_11*kerenel_12) + (data_input_13*kerenel_20)+(data_input_14*kerenel_21)+(data_input_15*kerenel_22);
      temp55 = (data_input_2*kerenel_00)+(data_input_3*kerenel_01)+(data_input_4*kerenel_02) + (input_data_6*kerenel_10);
      temp66 = (data_input_7*kerenel_11)+(data_input_8*kerenel_12) + (data_input_10*kerenel_20)+(data_input_11*kerenel_21)+(data_input_12*kerenel_22);
      temp77 = (input_data_6*kerenel_00)+(data_input_7*kerenel_01)+(data_input_8*kerenel_02) + (data_input_10*kerenel_10);
      temp88 = (data_input_11*kerenel_11)+(data_input_12*kerenel_12) + (data_input_14*kerenel_20)+(data_input_15*kerenel_21)+(data_input_16*kerenel_22);
      mac_1 <= (temp11 + temp22 );
      mac_2 <= (temp55 + temp66);
      mac_3 <= (temp33 + temp44);      
      mac_4 <= (temp77 + temp88);
    end
  end

endmodule