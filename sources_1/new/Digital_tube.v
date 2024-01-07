`timescale 1ns / 1ps

module Digital_tube(
    input clk,
    input [2:0] state,
    input [7:0] mistakes_count,
    input [7:0] song_id,
    input [2:0] account,
    input [9:0] score,
    input login,
    input record,
    input left,right,mid,
    output reg [7:0] tube_charl,reg [7:0]tube_charr,reg [7:0]tube_switch
    );
    
    wire [23:0] characters;
    wire [23:0] scorechar;
    wire [23:0] idchar;
    reg clk_out;
    reg [2:0] scan_cnt;
    reg [2:0] counter;
    reg [31:0] counter_scan = 0;
    reg [63:0] on_showing_eight_chars;
    reg [2:0] cube_onshowing_index = 3'b000;
    integer second_cnt = 0;
          //the state
  parameter WAIT = 3'b000;
  parameter FREEPLAY = 3'b100;
  parameter AUTOPLAY = 3'b010;
  parameter STUDY = 3'b001;
  parameter ADJUSTMENT = 3'b011;
  parameter SELECT = 3'b111;
  parameter CHALLENGE = 3'b101;
  //the difficulty of the challenge state
  parameter EASY = 3'b100;
  parameter NORMAL = 3'b010;
  parameter HARD = 3'b001;
  parameter interval_easy = 60;
  parameter interval_normal = 45;
  parameter interval_hard = 30;
  parameter interval_study = 120;
  
  //the period of changing char
  parameter scan_period = 200000;
  parameter second = 100000000;
  parameter pause = 110000;
  
  //the chars
  parameter zero = 8'b00000000;
  parameter WAIT_ = 64'b10110110_11001110_11101110_00001010_10011110_00000000_00000000_00000000;
  parameter FREEPLAY_ = 64'b10001110_00001010_10011110_10011110_11001110_00011100_11101110_01110110;
  parameter RECORD_ = 64'b00001010_10011110_00011010_00111010_00001010_01111010_00000000_00000000;
  parameter AUTOPLAY_ = 64'b11101110_01111100_00011110_11111100_11001110_00011100_11101110_01110110;
  parameter STUDY_ = 64'b10110110_00011110_01111100_01111010_01110110_00000000_00000000_00000000;
  parameter CHA = 32'b10011100_01101110_11101110_00000000;
  parameter SELECT_ = 64'b10110110_10011110_00011100_10011110_10011100_00011110_00000000_00000000;
  parameter ADJUST_ = 64'b11101110_01111010_11110000_01111100_10110110_00011110_00000000_00000000;
  parameter TRACK = 48'b00011110_00001010_11101110_10011100_00011110_00000010;
  
  
  //7-seg display characters
  parameter SEP = 8'b00000010;
  parameter ZERO = 8'b11111100;
  parameter ONE =  8'b01100000;
  parameter TWO =  8'b11011010;
  parameter THREE =8'b11110010;
  parameter FOUR = 8'b01100110;
  parameter FIVE = 8'b10110110;
  parameter SIX =  8'b10111110;
  parameter SEVEN =8'b11100000;
  parameter EIGHT =8'b11111110;
  parameter NINE = 8'b11110110;
  parameter S = 8'b10110110;
  parameter A = 8'b11101110;
  parameter B = 8'b00111110;
  parameter C = 8'b10011100;
  parameter D = 8'b01111010;
  parameter E = 8'b10011110;
  //321start
  parameter ONE_ = 64'b00000000_00000000_00000000_01100000_00000000_00000000_00000000_00000000;
  parameter TWO_ = 64'b00000000_00000000_00000000_00000000_11011010_00000000_00000000_00000000;
  parameter THREE_ = 64'b00000000_00000000_00000000_00000000_00000000_11110010_00000000_00000000;
  parameter START = 64'b00000000_00000000_10110110_00011110_11101110_00001010_00011110_00000000;
  
  //users account
  parameter HOPE = 40'b01101110_11111100_11001110_10011110_00000000;
  parameter ALAN = 40'b11101110_00011100_11101110_00101010_00000000;
  parameter BOB = 40'b00111110_00111010_00111110_00000000_00000000;
  parameter PAT = 40'b11001110_11101110_00011110_00000000_00000000;
  parameter PETER = 40'b11001110_10011110_00011110_10011110_00001010;
  parameter ANNA =40'b11101110_00101010_00101010_11101110_00000000;
  parameter ALICE = 40'b11101110_00011100_01100000_10011100_10011110;
  parameter JOHN = 40'b11110000_11111100_00101110_00101010_00000000;
      
  //songsname
  parameter HB = 32'b01101110_00111110_00000000_00000000;
  parameter Jn = 32'b11110000_00101010_00000000_00000000;
  parameter CR = 32'b10011100_00001010_00000000_00000000;
  parameter TS = 32'b00011110_10110110_00000000_00000000;
  parameter TT = 32'b00011110_00011110_00000000_00000000;
  
  parameter CR_ = 16'b10011100_00001010;
  parameter HB_ = 16'b01101110_00111110;
  parameter Jn_ = 16'b11110000_00101010;
  parameter TS_ = 16'b00011110_10110110;
  parameter TT_ = 16'b00011110_00011110;
  parameter RD_ = 16'b00001010_01111010;
  
  
  
  //the frequency of the note
  parameter do_low = 191110;
  parameter re_low = 170259;
  parameter me_low = 151685;
  parameter fa_low = 143172;
  parameter so_low = 127554;
  parameter la_low = 113636;
  parameter si_low = 101239;
  parameter do = 93941;
  parameter re = 85136;
  parameter me = 75838;
  parameter fa = 71582;
  parameter so = 63776;
  parameter la = 56818;
  parameter si = 50618;
  parameter do_high = 47778;
  parameter re_high = 42567;
  parameter me_high = 37921;
  parameter fa_high = 36498;
  parameter so_high = 31888;
  parameter la_high = 28409;
  parameter si_high = 25309;
  
  // the basic param of music
  parameter beat = 40 * 400;
  parameter base_beat = 4*400;
  parameter min_beat = 12 * 400;
  parameter max_beat = 100 * 400;
  parameter gap =  7 * 400;
  parameter index_period_3 = 70 * 400;
  parameter index_period_2 = 80 * 400;
  parameter index_period_1 = 100 * 400;
  parameter index_period_0 = 45 * 400;
  parameter index_beat_3 =  60 * 400;
  parameter index_beat_2 =  70 * 400;
  parameter index_beat_1 =  80 * 400;
  parameter index_beat_3_4 =  30 * 400;
  parameter index_beat_2_4 =  20 * 400;
  parameter index_beat_1_4 =  10 * 400;
  parameter silence = 580000;
  parameter song_count = 3;
  
  //the music notebook
  parameter JiangNan = 2324'b00000000001111000000000100000000000001000000100010010010000000000000000000000001000000000000001111001000100100100010011001000100100100010001001001000011110000000000000000000000010011001001100011110001111000000000101000010100000110100011000001110000111000000000000000000000000011100000000001000000011110010000001000100100000001111000111000011110010000001000100100010000000000000000000000010000000000000011110010001001001000100110010010001000100100010010001001000000011110000000000000000000000010000000000000011110010001001001000100110010001001001000100010010010000111100000000000000001001100100110001111000111100000000000000001010000101000001101000110000011100000000000000000000000001110000000000100000001111000000000100000010001001000000011110001110000111100100000010001001000100000000000000000000000100000000000000111100100010010010001001100100100010001001000100100010010000000111100000000000000000000000100110010011001001100000000010100000000000011110001111001001100011010001111000000000011110001111001001100011110001111000000000011110001111001000000011110010001001000100000000010001001000000100010010001001000100100010010001001000100100010010001000000000100010010001001000100100010010001001000100000000000000000000000011010001100000111000011110010000000111100011100001110000111000000000000000000000000011010001111001000100000000010011000111100011100001101000000000000000000000000110100011110001101000000000011000001110000111100011100001110000111000000000000000000000000011010001111000000000100010010011000111100011100001101000000000000000000000000110100000000001100000111000011110010000000111100011100001110000111000000000000000000000000011010001111000000000100010010011000111100011100001101000110100000000000000000000000011010001100000000000011100001111000111000011100001110000000000000000000000000110100011110000000001000100100110001111000111000011010000000000000000100010010001001000000011110001110000110100010100000110000111000011110001111000111000011010001100000100100001010000000001000100000000001101000110000010110001000000110100011110010001001001100011110001110000110100010100000110001000100100000010001000111100011100001101000101000001100001110000111100011110001110000110100011000001001000010100000000010001000000000011010001100000101100010000001101000111100100010010011000111100011100001101000101000001100000000;
  parameter HappyBirthday = 182'b00011110010000000111100100010010010000000000000000001101000111000011110010001001001100011000001111000111100100000001100000110100011000001110000111000011110001100000110100001010000101;
  parameter MerryChristmas = 469'b0001111000111100011110001110001000000011010001100000110000100110001111001000000100010010000000000000011000001100000110100011100001111000111000000000001110000111100011110001111000110000000000001111000111100011100010000000110100011000001100000000000011010001111001000000100010010010001000100100010000000000110000011000000000000110000011100001111001000000100010010000001000000000000001101000000000000000001101000110100011100001111001000000011110001111000000000011000001100;
  parameter LittleStar = 336'b000000000010000001001000100100010100001010000101100010110000000000110000011010001101000110000011000001000000100000000000001001000101000010100001011000101100011000001100000000000010010001010000101000010110001011000110000011000000000000100000010010001001000101000010100001011000101100000000001100000110100011010001100000110000010000001000;
  parameter TwoTiger = 252'b000000000010000001100000100000000000001000000110000010000001000000101001011011101100010110111011000001000000101001011011101100010110111011000000000000110000010110001010000000000011000001011000101000010000001010000100100010000001000000101000010010001000;
  
  parameter JN_length = 332;
  parameter HB_length = 26;
  parameter MC_length = 67;
  parameter LS_length = 48;
  parameter TT_length = 36;
  
  //the mode of scale
  parameter high_key = 3'b100;
  parameter mid_key = 3'b010;
  parameter low_key = 3'b001;
    Binary_to_Decimal u1({2'b00,mistakes_count},characters);
    Binary_to_Decimal u2({2'b00,song_id},idchar);
    Binary_to_Decimal u3(score,scorechar);
    
    always @(state,song_id,mistakes_count,account,counter) begin
        case(state)
        WAIT:begin //wait for login,select login account
        if (login)
        begin
        if(score < 4'd10)//show users scores
        on_showing_eight_chars[7:0] = E;
        else if(score >= 4'd10 && score < 5'd20)
        on_showing_eight_chars[7:0] = D;
        else if(score >= 5'd20 && score < 5'd30)
        on_showing_eight_chars[7:0] = C;
        else if(score >= 5'd30 && score < 6'd40)
        on_showing_eight_chars[7:0] = B; 
        else if(score >= 6'd40 && score < 7'd60)
        on_showing_eight_chars[7:0] = A; 
        else on_showing_eight_chars[7:0] = S;             
        case(account)//show login account
            3'b000:on_showing_eight_chars[63:8] =  {HOPE,scorechar[15:0]};
            3'b001:on_showing_eight_chars[63:8] =  {ALAN,scorechar[15:0]};
            3'b010:on_showing_eight_chars[63:8] =  {BOB,scorechar[15:0]};
            3'b011:on_showing_eight_chars[63:8] =  {PAT,scorechar[15:0]};
            3'b100:on_showing_eight_chars[63:8] =  {PETER,scorechar[15:0]};
            3'b101:on_showing_eight_chars[63:8] =  {JOHN,scorechar[15:0]};
            3'b110:on_showing_eight_chars[63:8] =  {ALICE,scorechar[15:0]};
            3'b111:on_showing_eight_chars[63:8] =  {ANNA,scorechar[15:0]};    
            default:on_showing_eight_chars = WAIT_;
        endcase
        end
        else
            on_showing_eight_chars = WAIT_;
        end
        
        FREEPLAY:begin //play freely
        if(record)
        on_showing_eight_chars = RECORD_;
        else
        on_showing_eight_chars = FREEPLAY_;
        end
        
        STUDY:begin //select songs and study 
            case(song_id)
                8'b0000_0001:on_showing_eight_chars[63:32] = HB;
                8'b0000_0010:on_showing_eight_chars[63:32] = Jn;
                8'b0000_0011:on_showing_eight_chars[63:32] = CR;
                8'b0000_0100:on_showing_eight_chars[63:32] = TS;
                8'b0000_0101:on_showing_eight_chars[63:32] = TT;
            default:on_showing_eight_chars[63:32] = {idchar,SEP};
            endcase
            
            if(mistakes_count < 4'd10)
            on_showing_eight_chars[31:0] = {characters,A};
            else if(mistakes_count >= 4'd10 && mistakes_count < 5'd20)
            on_showing_eight_chars[31:0] = {characters,B};
            else if(mistakes_count >= 5'd20 && mistakes_count < 5'd30)
            on_showing_eight_chars[31:0] = {characters,C};
            else if(mistakes_count >= 5'd30 && mistakes_count < 6'd40)
            on_showing_eight_chars[31:0] = {characters,D}; 
            else
            on_showing_eight_chars[31:0] = {characters,E}; 
        end
        
        CHALLENGE:begin
        if (counter == 3'b000)on_showing_eight_chars = THREE_;
        else if(counter == 3'b001)on_showing_eight_chars = TWO_;
        else if(counter == 3'b010)on_showing_eight_chars = ONE_;
        else if(counter == 3'b011)on_showing_eight_chars = START;
        else begin
        case(song_id)
        8'b0000_0001:on_showing_eight_chars[63:48] = HB_;
        8'b0000_0010:on_showing_eight_chars[63:48] = Jn_;
        8'b0000_0011:on_showing_eight_chars[63:48] = CR_;
        8'b0000_0100:on_showing_eight_chars[63:48] = TS_;
        8'b0000_0100:on_showing_eight_chars[63:48] = TT_;
        default:on_showing_eight_chars[63:48] = RD_;
        endcase
        
        if(mistakes_count < 4'd10)
        on_showing_eight_chars[47:0] = {zero,SEP,characters,A};
        else if(mistakes_count >= 4'd10 && mistakes_count < 5'd20)
        on_showing_eight_chars[47:0] = {zero,SEP,characters,B};
        else if(mistakes_count >= 5'd20 && mistakes_count < 5'd30)
        on_showing_eight_chars[47:0] = {zero,SEP,characters,C};
        else if(mistakes_count >= 5'd30 && mistakes_count < 6'd40)
        on_showing_eight_chars[47:0] = {zero,SEP,characters,D}; 
        else
        on_showing_eight_chars[47:0] = {zero,SEP,characters,E}; 
        end
        end
        
        AUTOPLAY:begin
        case(song_id)
                8'b0000_0001:on_showing_eight_chars = {HB,zero,SEP,ZERO,ONE};
                8'b0000_0010:on_showing_eight_chars = {Jn,zero,SEP,ZERO,TWO};
                8'b0000_0011:on_showing_eight_chars = {CR,zero,SEP,ZERO,THREE};
                8'b0000_0100:on_showing_eight_chars = {TS,zero,SEP,ZERO,FOUR};
                8'b0000_0101:on_showing_eight_chars = {TT,zero,SEP,ZERO,FIVE};
                default:on_showing_eight_chars = {TRACK,idchar[15:0]};
        endcase
        end
       
        SELECT:begin //select songs,changing with song_id
            case(song_id)
                8'b0000_0001:on_showing_eight_chars = {HB,zero,SEP,ZERO,ONE};
                8'b0000_0010:on_showing_eight_chars = {Jn,zero,SEP,ZERO,TWO};
                8'b0000_0011:on_showing_eight_chars = {CR,zero,SEP,ZERO,THREE};
                8'b0000_0100:on_showing_eight_chars = {TS,zero,SEP,ZERO,FOUR};
                8'b0000_0101:on_showing_eight_chars = {TT,zero,SEP,ZERO,FIVE};
                default:on_showing_eight_chars = {TRACK,idchar[15:0]};   
            endcase
         end
            
        ADJUSTMENT:begin //adjust mode
        on_showing_eight_chars = ADJUST_;
        end 
        
        default:
        on_showing_eight_chars = WAIT_;
        endcase
     end 
    
 
        
    
    always @(posedge clk)begin //frequency division
            if(counter_scan == (scan_period>>1) - 1) begin
            clk_out <= ~clk_out;
            counter_scan <= 0;        
        end
        else counter_scan <= counter_scan + 1; 

        if(state == CHALLENGE)begin//achieve countdown prompt in challenge mode
            if(second_cnt >= second) begin
                second_cnt <= 0;
                if(counter <= 3'b101) counter <= counter + 1;
            end
            else second_cnt <= second_cnt + 1;
        end
        else begin
        second_cnt <= 0;
        counter <= 3'b000;
        end
        end
    
    always@(posedge clk_out)
        begin
        if(scan_cnt == 3'b111)
            scan_cnt <= 0;
        else
            scan_cnt <= scan_cnt + 1;
        end   
        
    always@(scan_cnt)
    begin
        case(scan_cnt)
           3'b000:tube_switch =  8'b10000000;
           3'b001:tube_switch =  8'b01000000;
           3'b010:tube_switch =  8'b00100000;
           3'b011:tube_switch =  8'b00010000;
           3'b100:tube_switch =  8'b00001000;
           3'b101:tube_switch =  8'b00000100;
           3'b110:tube_switch =  8'b00000010;
           3'b111:tube_switch =  8'b00000001;
           default:tube_switch =  8'b10000000;
        endcase
        if(tube_switch > 8'b00001000)//control tube
            tube_charl = on_showing_eight_chars[(7-scan_cnt) * 8 + 7 -:8];        else
            tube_charr = on_showing_eight_chars[(7-scan_cnt) * 8 + 7 -:8];
    end
    
    
    
endmodule
