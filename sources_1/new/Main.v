`timescale 1ns / 1ps
module main(input clk,rst,
    input [7:0] key,                            // key of piano from left to right,do re mi fa so la xi
    input [7:0] mode,                           // select mode  
    input up,down,mid,left,right,               // control the  
    output [7:0] tube_charl, [7:0] tube_charr,[7:0] tube_switch,   // control the tube
    output [7:0] key_led,[7:0] mode_led,        // control the led
    output music,                                // play music
    output reg pwm
    );
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

    reg [2:0]account; 
    reg [9:0] score [0:7];
    reg login = 0;
    reg [7:0] key_order[7:0];
    reg [2:0] state,next_state;
    wire[7:0] reminder;
    wire[7:0] next_reminder;
    reg [7:0] last_reminder;
    wire[7:0] song_id;
    reg [2:0] difficulty;
    reg [7:0] mistakes_count = 0;
    wire isEnd;
    wire check;
    reg[7:0] i;
    reg count;
    reg isScored;
    reg[7:0] interval;
    reg [19:0] cnt; 
    reg select_music;
    
    Music u1(clk,state,song_id,difficulty,key,up,mid,down,left,right,mode[3],music,reminder,next_reminder,isEnd);
    Digital_tube u2(clk,state,mistakes_count,song_id,account,score[account],login,mode[3],left,right,mid,tube_charl,tube_charr,tube_switch);
    Led u3(check,state,reminder,next_reminder,difficulty,isEnd,key_led,mode_led);
    Select_music u4(check,state,left,right,song_id);
    assign check = cnt[19];
    initial begin 
        isScored = 0;
        pwm = 0;
        state = WAIT;
        next_state = WAIT;
    end
    always @ (posedge clk) 
        begin
            cnt <= cnt + 1;
        end
    always @ (difficulty) //set the interval for each difficulty
    begin
        case(difficulty)
            EASY:   interval = interval_easy;
            NORMAL: interval = interval_normal;
            HARD:   interval = interval_hard;
            default:interval = interval_easy;
        endcase
    end
    always @ (posedge check)
    begin
        if(login)
        begin
            if(~rst)
            begin 
                next_state <= WAIT;
                login <= 0;
            end
            else
                case(state)              //according to the modekey, changing the state 
            SELECT:
            begin
            case(mode[7:3])
                5'b00000: next_state <= WAIT;
                5'b01000: if(mid) next_state <= AUTOPLAY;
                5'b00100: if(mid) begin next_state <= STUDY; mistakes_count <= 0;end
                5'b00010: if(mid) begin next_state <= CHALLENGE; mistakes_count <= 0;isScored <= 0; end
                default: next_state <= SELECT;
            endcase
            case(mode[2:0])
                3'b100: difficulty <= EASY;
                3'b010: difficulty <= NORMAL;
                3'b001: difficulty <= HARD;
                default: difficulty <= EASY;
            endcase
            end
            WAIT:begin
                    case(mode[7:4])
                        4'b0010,4'b0100,4'b0001: next_state <= SELECT;
                        4'b1000: next_state <= FREEPLAY;
                        default: next_state <= WAIT;
                    endcase
                    if(down) next_state <= ADJUSTMENT;
                  end
            STUDY,FREEPLAY,AUTOPLAY:
            begin
                case(mode[7:4])
                    4'b0000: next_state <= WAIT;
                    default: next_state <= next_state;
                endcase
            end
            CHALLENGE:
            case(mode[7:4])
                4'b0000: begin next_state <= WAIT; difficulty <= EASY;end
                default: next_state <= next_state;
            endcase
            default: next_state <= WAIT;
            ADJUSTMENT:if(isEnd) next_state <= WAIT;
        endcase
            state <= next_state;
            if(state==CHALLENGE&&!isEnd)        //the controller of CHALLENGE state
            begin
                if(reminder != last_reminder)
                begin
                    last_reminder <= reminder;
                    i <= 0;
                    count <= 0;
                end
                if(key != reminder&&count==0)  i <= i + 1;
                if(i==interval&&count==0) 
                begin
                    count <= 1;
                    mistakes_count <= mistakes_count + 1;
                end
            end
            else if(state==STUDY&&!isEnd)
            begin
                if(reminder != last_reminder || key == reminder)begin
                    last_reminder <= reminder;
                    i <= 0;
                    count <= 0;
                end
                else if(key != reminder&&count==0)  i <= i + 1;
                else if(i==interval_study&&count==0) 
                begin
                    count <= 1;
                    mistakes_count <= mistakes_count + 1;
                end
            end
            else if(state==CHALLENGE&&isEnd&&~isScored)
            begin                      //get score in the end
                if(mistakes_count <= 4'd10)
                score[account] <= score[account] + 5;
                else if(mistakes_count > 4'd10 && mistakes_count <= 5'd20)
                score[account] <= score[account] + 3;
                else if(mistakes_count > 5'd20 && mistakes_count <= 5'd30)
                score[account] <= score[account] + 2;
                else if(mistakes_count > 5'd30 && mistakes_count <= 6'd40)
                score[account] <= score[account] + 1;
                else
                score[account] <= score[account];
                isScored <= 1;
            end
        end
        else 
        begin
            if(mid)     //confirm the login
                case(key)
                8'b10000000: begin account <= 0;login <= 1; end
                8'b01000000: begin account <= 1;login <= 1; end
                8'b00100000: begin account <= 2;login <= 1; end
                8'b00010000: begin account <= 3;login <= 1; end
                8'b00001000: begin account <= 4;login <= 1; end
                8'b00000100: begin account <= 5;login <= 1; end
                8'b00000010: begin account <= 6;login <= 1; end
                8'b00000001: begin account <= 7;login <= 1; end
                endcase 
        end
    end
endmodule
