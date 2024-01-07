`timescale 1ns / 1ps
//`include "parameter.hv"
module Music(
    input clk,              // clock
    input [2:0] mode,       // free / play /  learn / WAIT / ADJUSTMENT / SELECT
    input [7:0] song_id,    // choose song in autoplay, study, challenge mode
    input [2:0] difficulty, // the difficulty of challenge mode
    input [7:0] key,        // the keys to audio
    input up,               // high key(U4) 
    input mid,              // middle key(R15)
    input down,             // low key(R17)
    input left,
    input right,
    input is_record,        // start record
    output reg music,       // play
    output reg[7:0] reminder,
    output reg[7:0] next_reminder,
    output reg isEnd
    );
//    `include "parameters.v"
    reg[6:0] note;                  // the present note
    reg[6:0] next_note;             // the next note
    integer frequency = silence;    // initial frequency
    integer index_count = 0;        // count2 control beat;
    integer index = 0;              // index control the location music playing
    reg en;
    `timescale 1ns / 1ps
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

    
    
    /*
    0 - silence
    1 - 7 low
    8 - 14 mid
    15 - 21 high
    */
    
    // AUTOPLAY, 
    reg [9:0] length;
    reg [2323:0] songs;         
    reg [2:0] last_mode = 0;
    reg [2:0] keymode;
    reg [6:0] last_note;
    reg next;
    reg [7:0] key_order[7:0];
    reg [10:0] cnt;
    reg [19:0] record_cnt;
    wire check = cnt[10];
    integer key_cnt;
    reg [777:0] record [4:0]; // 5 songs, max length is 777
    reg [9:0] record_len[4:0]; // length of record
    integer record_pos; //  the position to put notes
    integer record_index; // which son
    integer j;
    initial begin
        keymode = mid_key; 
        music = 1;
        key_order[0] = 8'b1000_0000;
        for (j = 1; j < 8; j = j + 1) begin
            key_order[j] = key_order[j-1] >> 1;
        end
        record_pos=0;
        record_index = 0;
    end
    //get reminder and next_reminder from note
    always @(note,next_note)
    begin
    case (note[4:0])
        5'd0:reminder = 8'b00000000;
        5'd1,5'd8, 5'd15:reminder = key_order[0];
        5'd2,5'd9, 5'd16:reminder = key_order[1];
        5'd3,5'd10,5'd17:reminder = key_order[2];
        5'd4,5'd11,5'd18:reminder = key_order[3];
        5'd5,5'd12,5'd19:reminder = key_order[4];
        5'd6,5'd13,5'd20:reminder = key_order[5];
        5'd7,5'd14,5'd21:reminder = key_order[6];
        default:reminder = 8'b00000000;
    endcase 
        case (next_note[4:0])
                5'd0:next_reminder = 8'b00000000;
                5'd1,5'd8, 5'd15:next_reminder = key_order[0];
                5'd2,5'd9, 5'd16:next_reminder = key_order[1];
                5'd3,5'd10,5'd17:next_reminder = key_order[2];
                5'd4,5'd11,5'd18:next_reminder = key_order[3];
                5'd5,5'd12,5'd19:next_reminder = key_order[4];
                5'd6,5'd13,5'd20:next_reminder = key_order[5];
                5'd7,5'd14,5'd21:next_reminder = key_order[6];
                default:next_reminder = 8'b00000000;
    endcase 
    end
    //adjust the scale
    always@(posedge check)begin
        if(up != 0) keymode <= high_key;
        else if(down != 0) keymode <= low_key;
        else if(mid != 0) keymode <= mid_key;
    end
    integer index_period = beat + gap;
    integer index_beat = beat;
    integer reg_period;
    integer reg_beat;
    integer i;
    integer start;
    integer second_cnt;
    integer frequency_count = 0;
    reg [4:0]reg_mid;
    reg [4:0]reg_left;
    reg [4:0]reg_right;
    reg move;
    // debounce
    always @(posedge check)begin
       if(mid != 0)if(reg_mid[4] != 1)reg_mid <= reg_mid+1;
         
       else reg_mid<=0;
       if(left != 0)begin
             if(reg_left[4] != 1)
               reg_left <= reg_left+1;
         end
       else reg_left<=0;
      if(right != 0)begin
             if(reg_right[4] != 1)
               reg_right <= reg_right+1;
         end
       else reg_right<=0;
     end
    // main controller
    always @(posedge check) begin
        if(mode != last_mode)begin
            // init for each mode
            last_mode <= mode;
            i <= 0;
            isEnd <= 0;
            index_count <= 0;
            next <= 0;
            length <= 100;
            note <= 7'd0;
            next_note <= 7'd0;
            if(last_mode == CHALLENGE || mode == CHALLENGE)begin
                index_beat <= beat;
                index_period <= index_period_0;
            end
            key_cnt <= 0;
            start <= 0;
            second_cnt <=0;
            record_pos <= 0;
        end
        if(mode == CHALLENGE)begin
            // adjust the speed 
            case(difficulty)
                EASY:    begin index_period <= index_period_1; index_beat <= index_beat_1;end
                NORMAL:  begin index_period <= index_period_2; index_beat <= index_beat_2;end
                default: begin index_period <= index_period_3; index_beat <= index_beat_3;end
            endcase
            //control the start
            if (~start)
               if(second_cnt >= pause) begin
                   second_cnt <= 0;
                   start <= 1;
               end
               else begin
                    second_cnt <= second_cnt + 1;
               end       
        end
        else if (mode != SELECT) begin
            //control the speed of song for autoplay
                if(reg_left[4] && index_beat != min_beat && move == 0) 
                begin
                    index_beat <= index_beat - base_beat;
                    index_period <= index_period - base_beat;
                    move <= 1;
                end
                else if(reg_right[4] && index_beat != max_beat && move == 0) 
                begin
                    index_beat <= index_beat + base_beat;
                    index_period <= index_period + base_beat;
                    move <= 1;
                end
                else if(!reg_right[4] && !reg_left[4]) move <= 0;
            end
        // AUTOPLAY STUDY
        if(mode == AUTOPLAY || mode == CHALLENGE || mode == STUDY)begin
        // choose song
            case(song_id) 
                8'd1:begin length <= HB_length;songs <= HappyBirthday;end
                8'd2:begin length <= JN_length;songs <= JiangNan;end
                8'd3:begin length <= MC_length;songs <= MerryChristmas;end   
                8'd4:begin length <= LS_length;songs <= LittleStar;end
                8'd5:begin length <= TT_length;songs <= TwoTiger;end
                8'd6:begin length <= record_len[0];songs <= record[0];end             
                8'd7:begin length <= record_len[1];songs <= record[1];end             
                8'd8:begin length <= record_len[2];songs <= record[2];end             
                8'd9:begin length <= record_len[3];songs <= record[3];end             
                8'd10:begin length <= record_len[4];songs <= record[4];end                         
                default: begin length <= LS_length; songs <= LittleStar; end
            endcase
        end
        if(mode == AUTOPLAY || mode == CHALLENGE)
        begin
            if(index_count>reg_beat) note <= 7'd0;
            else 
                begin
                if(i <= length - 1) next_note <= songs[i * 7 + 6 -: 7];
                if(i >= 1) note <= songs[i * 7 - 1 -: 7];
                end
            // adjust the time for the note
            if(mode == AUTOPLAY)
                case(note[6:5])
                    2'b01: begin reg_beat <= (index_beat >> 2); reg_period <= (index_period >> 2); end
                    2'b10: begin reg_beat <= (index_beat >> 1); reg_period <= (index_period >> 1); end
                    2'b11: begin reg_beat <= (index_beat >> 1) + (index_beat >> 2); reg_period <= (index_period >> 1) +  (index_period >> 2); end
                    default:begin reg_beat <= index_beat; reg_period <= index_period; end
                endcase
            else begin
                 reg_beat <= index_beat; reg_period <= index_period;
            end
            if(!isEnd && ((mode==CHALLENGE && start)|| mode!=CHALLENGE))
            begin
                index_count <= index_count + 1;
                if(index_count >= reg_period)begin
                    i <= i + 1;
                    index_count <= 0;
                end
                if(i > length) isEnd <= 1'b1;
            end
        //  FREEPLAY
        end 
        else if(mode == FREEPLAY)begin
            case(keymode)
                3'b100: begin
                    case(key)
                        key_order[0]: note <= 7'd15;
                        key_order[1]: note <= 7'd16;
                        key_order[2]: note <= 7'd17;
                        key_order[3]: note <= 7'd18;
                        key_order[4]: note <= 7'd19;
                        key_order[5]: note <= 7'd20;
                        key_order[6]: note <= 7'd21;
                        default: note <= 7'd0;
                    endcase 
                end
                3'b010: begin
                    case(key)
                        key_order[0]: note <= 7'd8;
                        key_order[1]: note <= 7'd9;
                        key_order[2]: note <= 7'd10;
                        key_order[3]: note <= 7'd11;
                        key_order[4]: note <= 7'd12;
                        key_order[5]: note <= 7'd13;
                        key_order[6]: note <= 7'd14;
                        default: note <= 7'd0;
                    endcase
                end
                3'b001: begin
                    case(key)
                        key_order[0]: note <= 7'd1;
                        key_order[1]: note <= 7'd2;
                        key_order[2]: note <= 7'd3;
                        key_order[3]: note <= 7'd4;
                        key_order[4]: note <= 7'd5;
                        key_order[5]: note <= 7'd6;
                        key_order[6]: note <= 7'd7;
                        default: note <= 7'd0;
                    endcase  
                end
            endcase
            //record
            if(is_record && ~isEnd)begin
                next <= 1;
                record_cnt <= record_cnt + 1;
                if(record_pos==0 && record_len[record_index] != 0) record_len[record_index] <=0;
                else if (record_len[record_index] > 100) begin 
                    isEnd <= 1;
                    record_index <= record_index + 1;
                end
                if(note != last_note || record_cnt >= index_beat)begin
                    last_note <= note;
                    record_cnt <= 0;
                    record_pos <= record_pos + 1;
                    if(record_cnt <= index_beat_1_4)begin
                            record[record_index][record_pos * 7 + 6 -: 7] <= {2'b01,note[4:0]};
                    end
                    else if(record_cnt <= index_beat_2_4)begin
                            record[record_index][record_pos * 7 + 6 -: 7] <= {2'b10,note[4:0]};
                    end
                    else if(record_cnt <= index_beat_3_4)begin
                            record[record_index][record_pos * 7 + 6 -: 7] <= {2'b11,note[4:0]};
                        end
                    else begin
                            record[record_index][record_pos * 7 + 6 -: 7] <= {2'b00,note[4:0]};
                    end
                    record_len[record_index] <= record_len[record_index] + 1'b1;
                end
            end 
            else begin
                isEnd <= 0; 
                record_pos <= 0;
                if(next==1)begin
                record_index <= record_index + 1;
                next <= 0;
                end
            end
        end
        else if (mode == STUDY)begin
            next_note <= songs[i * 7 + 13 -: 7];
            note <= songs[i * 7 + 6 -: 7];
//          the controller of the STUDY state
            if(!isEnd)
                if(next && key==reminder)begin
                    i <= i + 1;
                    next <= 0;
                end
                else if(i>length)begin
                    isEnd <= 1;
                    i <= 0;
                end
                else if(key==reminder && ~next) next <= 1; 
        end        
        else if (mode == ADJUSTMENT)
        begin
            if(~reg_mid[4] && key_cnt==0)
                note <= 7'd8; // do
            if(reg_mid[4] && next == 1) 
            begin
                note <= note+1'b1;
                key_order[key_cnt] <= key;
                key_cnt <= key_cnt + 1; // next key
                next <= 0;
            end
            else if(~reg_mid[4] && next==0)
                next <= 1;
            if(key_cnt == 7) 
            begin
                note <= 7'd0; 
                isEnd <= 1'b1;
            end
        end
    end
    
    
    // frequency
    always @(posedge check) begin
        if(isEnd)
        begin
            frequency <= silence;
        end
        else 
        begin
        if(mode == STUDY || mode == CHALLENGE)begin
            case(keymode)
                3'b100: begin
                    case(key)
                        key_order[0]: frequency <= do_high;
                        key_order[1]: frequency <= re_high;
                        key_order[2]: frequency <= me_high;
                        key_order[3]: frequency <= fa_high;
                        key_order[4]: frequency <= so_high;
                        key_order[5]: frequency <= la_high;
                        key_order[6]: frequency <= si_high;
                        default: frequency <= silence;
                    endcase 
                end
                3'b010: begin
                    case(key)
                        key_order[0]: frequency <= do;
                        key_order[1]: frequency <= re;
                        key_order[2]: frequency <= me;
                        key_order[3]: frequency <= fa;
                        key_order[4]: frequency <= so;
                        key_order[5]: frequency <= la;
                        key_order[6]: frequency <= si;
                        default: frequency <= silence;
                    endcase
                end
                3'b001: begin
                    case(key)
                        key_order[0]: frequency <= do_low;
                        key_order[1]: frequency <= re_low;
                        key_order[2]: frequency <= me_low;
                        key_order[3]: frequency <= fa_low;
                        key_order[4]: frequency <= so_low;
                        key_order[5]: frequency <= la_low;
                        key_order[6]: frequency <= si_low;
                        default: frequency <= silence;
                    endcase
                end
            endcase
        end
        
        // AUTOPLAY FREEPLAY ADJUSTMENT: 
        else if(mode == AUTOPLAY || mode == FREEPLAY || mode == ADJUSTMENT)begin
            case(note[4:0])
                5'd0 : frequency <= silence;
                5'd1 : frequency <= do_low;
                5'd2 : frequency <= re_low;
                5'd3 : frequency <= me_low;
                5'd4 : frequency <= fa_low;
                5'd5 : frequency <= so_low;
                5'd6 : frequency <= la_low;
                5'd7 : frequency <= si_low;
                5'd8 : frequency <= do;
                5'd9 : frequency <= re;
                5'd10 : frequency <= me;
                5'd11 : frequency <= fa;
                5'd12 : frequency <= so;
                5'd13 : frequency <= la;
                5'd14 : frequency <= si;
                5'd15 : frequency <= do_high;
                5'd16 : frequency <= re_high;
                5'd17 : frequency <= me_high;
                5'd18 : frequency <= fa_high;
                5'd19 : frequency <= so_high;
                5'd20 : frequency <= la_high;
                5'd21 : frequency <= si_high;
            endcase
        end
        else frequency <= silence;
        end
    end
    
    always@(posedge clk)begin
        //frequency demultiplication
        cnt <= cnt + 1;
        //control the buzzer
        if(frequency_count >= frequency) begin
            frequency_count <= 0;
            music <= ~music;
        end
        else frequency_count <= frequency_count + 1;
    end
endmodule
