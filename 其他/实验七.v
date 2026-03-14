module ps2_keyboard(
    input clk,
    input resetn,
    input ps2_clk,
    input ps2_data,
    output reg [7:0] key_code,
    output reg key_valid      
);
    reg [9:0] buffer;        // ps2_data bits （0：起始位，1-8数据位，9奇偶校验）
    reg [3:0] count;         // count ps2_data bits
    reg [2:0] ps2_clk_sync;

    always @(posedge clk) begin
        ps2_clk_sync <= {ps2_clk_sync[1:0], ps2_clk};
    end

    wire sampling = ps2_clk_sync[2] & ~ps2_clk_sync[1];

    always @(posedge clk) begin
        if (resetn == 0) begin
            count <= 0;
            key_code <= 8'h00;
            key_valid <= 1'b0;
        end else begin
            key_valid <= 1'b0;               // 默认拉低
            if (sampling) begin
                if (count == 4'd10) begin
                    if ((buffer[0] == 0) && ps2_data && (^buffer[9:1])) begin
                        key_code <= buffer[8:1];
                        key_valid <= 1'b1;    // 产生一个时钟周期的高脉冲
                    end
                    count <= 0;
                end else begin
                    buffer[count] <= ps2_data;
                    count <= count + 3'b1;
                end
            end
        end
    end
endmodule


//七段数显驱动模块
// 七段数显驱动模块：4位BCD输入 → 8位段码输出
module bcd_seg_driver(
    input en,
    input [3:0] bcd,    
    output [7:0] seg    
);
assign seg = (en == 1'b0) ? 8'b11111111 : // 灭灯（全1）
             (bcd == 4'd0) ? 8'b00000011 : // 0：A,B,C,D,E,F亮(0)，G灭(1)，DP灭(1)
             (bcd == 4'd1) ? 8'b10011111 : // 1：B,C亮(0)，其余灭(1)
             (bcd == 4'd2) ? 8'b00100101 : // 2：A,B,G,E,D亮(0)
             (bcd == 4'd3) ? 8'b00001101 : // 3：A,B,G,C,D亮(0)
             (bcd == 4'd4) ? 8'b10011001 : // 4：F,G,B,C亮(0)
             (bcd == 4'd5) ? 8'b01001001 : // 5：A,F,G,C,D亮(0)
             (bcd == 4'd6) ? 8'b01000001 : // 6：A,F,G,C,D,E亮(0)
             (bcd == 4'd7) ? 8'b00011111 : // 7：A,B,C亮(0)（顶段A=0，亮）
             (bcd == 4'd8) ? 8'b00000001 : // 8：全亮(0)
             (bcd == 4'd9) ? 8'b00001001 : // 9：A,B,C,D,F,G亮(0)
             8'b11111110; // 非0-9灭灯，留着小数点当溢出
endmodule

module hex_seg_driver(
    input en,
    input [3:0] hex,
    output [7:0] seg
);

assign seg = (en == 1'b0) ? 8'b11111111 : // 灭灯（全1）
             (hex == 4'd0)  ? 8'b00000011 : // 0
             (hex == 4'd1)  ? 8'b10011111 : // 1
             (hex == 4'd2)  ? 8'b00100101 : // 2
             (hex == 4'd3)  ? 8'b00001101 : // 3
             (hex == 4'd4)  ? 8'b10011001 : // 4
             (hex == 4'd5)  ? 8'b01001001 : // 5
             (hex == 4'd6)  ? 8'b01000001 : // 6
             (hex == 4'd7)  ? 8'b00011111 : // 7（A,B,C亮，顶段A=0，亮，和1区分）
             (hex == 4'd8)  ? 8'b00000001 : // 8
             (hex == 4'd9)  ? 8'b00001001 : // 9
             (hex == 4'd10) ? 8'b00010001 : // A（A,B,C,E,F,G亮）
             (hex == 4'd11) ? 8'b11000001 : // B（F,G,E,D,C亮）
             (hex == 4'd12) ? 8'b01100011 : // C（A,F,E,D亮）
             (hex == 4'd13) ? 8'b10000101 : // D（A,B,G,E,D亮，顶段A=0，亮）
             (hex == 4'd14) ? 8'b01100001 : // E（A,F,E,D,G亮）
             (hex == 4'd15) ? 8'b01110001 : // F（A,F,E,G亮）
             8'b11111111; // 其他灭灯

endmodule


//扫描码转ascii
module scan2ascii(
    input [7:0] scan_code,
    output reg [7:0] ascii_code
);

always @(*) begin
    case(scan_code)
        // 数字键（0-9）
        8'h16: ascii_code = 8'h31; // 1 → 0x31
        8'h1E: ascii_code = 8'h32; // 2 → 0x32
        8'h26: ascii_code = 8'h33; // 3 → 0x33
        8'h25: ascii_code = 8'h34; // 4 → 0x34
        8'h2E: ascii_code = 8'h35; // 5 → 0x35
        8'h36: ascii_code = 8'h36; // 6 → 0x36
        8'h3D: ascii_code = 8'h37; // 7 → 0x37
        8'h3E: ascii_code = 8'h38; // 8 → 0x38
        8'h46: ascii_code = 8'h39; // 9 → 0x39
        8'h45: ascii_code = 8'h30; // 0 → 0x30

        // 字母键（q-w-e-r-t-y-u-i-o-p）
        8'h15: ascii_code = 8'h71; // q → 0x71
        8'h1D: ascii_code = 8'h77; // w → 0x77
        8'h24: ascii_code = 8'h65; // e → 0x65
        8'h2D: ascii_code = 8'h72; // r → 0x72
        8'h2C: ascii_code = 8'h74; // t → 0x74
        8'h35: ascii_code = 8'h79; // y → 0x79
        8'h3C: ascii_code = 8'h75; // u → 0x75
        8'h43: ascii_code = 8'h69; // i → 0x69
        8'h44: ascii_code = 8'h6F; // o → 0x6F
        8'h4D: ascii_code = 8'h70; // p → 0x70

        // 字母键（a-s-d-f-g-h-j-k-l）
        8'h1C: ascii_code = 8'h61; // a → 0x61
        8'h1B: ascii_code = 8'h73; // s → 0x73
        8'h23: ascii_code = 8'h64; // d → 0x64
        8'h2B: ascii_code = 8'h66; // f → 0x66
        8'h34: ascii_code = 8'h67; // g → 0x67
        8'h33: ascii_code = 8'h68; // h → 0x68
        8'h3B: ascii_code = 8'h6A; // j → 0x6A
        8'h42: ascii_code = 8'h6B; // k → 0x6B
        8'h4B: ascii_code = 8'h6C; // l → 0x6C

        // 字母键（z-x-c-v-b-n-m）
        8'h1A: ascii_code = 8'h7A; // z → 0x7A
        8'h22: ascii_code = 8'h78; // x → 0x78
        8'h21: ascii_code = 8'h63; // c → 0x63
        8'h2A: ascii_code = 8'h76; // v → 0x76
        8'h32: ascii_code = 8'h62; // b → 0x62
        8'h31: ascii_code = 8'h6E; // n → 0x6E
        8'h3A: ascii_code = 8'h6D; // m → 0x6D
        default: ascii_code = 8'b00000000;
    endcase
end

endmodule

/* verilator lint_off UNUSEDSIGNAL */
/* verilator lint_off WIDTHTRUNC */
module bin8_to_bcd2(
    input [7:0] bin_data,    
    output [3:0] bcd10,  
    output [3:0] bcd01   
);
  wire useless_bit;
  assign {useless_bit, bcd10} = (bin_data / 10); //取十位
  assign bcd01 = (bin_data % 10); //取个位 

endmodule
/* verilator lint_off WIDTHTRUNC */
/* verilator lint_off UNUSEDSIGNAL */


module bin8_2_bin42(
    input [7:0] bin8,
    output[3:0] bin41,
    output[3:0] bin42
);
    assign bin41 = bin8 [7:4];
    assign bin42 = bin8 [3:0];
endmodule



module key_counter(
    input clk,
    input resetn,
    input [7:0] key_code,
    input key_valid,          // 有效脉冲
    output reg [7:0] key_count,
    output reg key_pressed
);

reg xia_yi_ge_shi_bu_shi_song_kai_de_jian_ma;  //下一个是不是松开的键码 

always @(posedge clk) begin
    if (!resetn) begin
        xia_yi_ge_shi_bu_shi_song_kai_de_jian_ma <= 1'b0;
        key_pressed <= 1'b0;
        key_count <= 8'h00;
    end else begin
        if (key_valid) begin                      // 每收到一个新码就处理
            if (key_code == 8'hF0) begin            //开始松开，收到f0 ，下一个必是松开的键码
                xia_yi_ge_shi_bu_shi_song_kai_de_jian_ma <= 1'b1;
            end
            else if (xia_yi_ge_shi_bu_shi_song_kai_de_jian_ma) begin  //接收到松开的键码，正式松开
                key_pressed <= 1'b0;              // 松开
                xia_yi_ge_shi_bu_shi_song_kai_de_jian_ma <= 1'b0;
            end
            else if (!key_pressed && (key_code != 8'h00)) begin  //按新键的状态
                key_pressed <= 1'b1;               // 按下
                // 计数器加1，并限制在0~99
                key_count <= (key_count == 8'd99) ? 8'd0 : key_count + 1'b1;
            end
        end
    end
end

endmodule



module top(
    input clk,
    input resetn,
    input ps2_clk,
    input ps2_data,
    output [7:0] seg_cnt10,
    output [7:0] seg_cnt01,
    output [7:0] seg_ascii10,
    output [7:0] seg_ascii01,
    output [7:0] seg_key10,
    output [7:0] seg_key01,
    output [7:0] seg_2,
    output [7:0] seg_5
);

assign seg_2 = 8'b11111111;
assign seg_5 = 8'b11111111;

wire [7:0] key_code;
wire       key_valid;          // 新增：有效码脉冲
wire [7:0] ascii_code;
wire [7:0] key_count;
wire key_pressed;

wire [3:0] key_bin41;
wire [3:0] key_bin42;
wire [3:0] ascii_bin41;
wire [3:0] ascii_bin42;

wire [3:0] cnt_bcd10;
wire [3:0] cnt_bcd01;

ps2_keyboard u_ps2_keyboard(.clk(clk), .resetn(resetn), .ps2_clk(ps2_clk), .ps2_data(ps2_data), .key_code(key_code), .key_valid(key_valid));
scan2ascii u_scan2ascii(.scan_code(key_code), .ascii_code(ascii_code));
key_counter u_key_counter(.clk(clk), .resetn(resetn), .key_code(key_code), .key_valid(key_valid), .key_count(key_count), .key_pressed(key_pressed));
bin8_to_bcd2 u_cnt_bcd(.bin_data(key_count), .bcd10(cnt_bcd10), .bcd01(cnt_bcd01));
bin8_2_bin42 u_key_bin8_42(.bin8(key_code), .bin41(key_bin41), .bin42(key_bin42));
bin8_2_bin42 u_ascii_bin8_42(.bin8(ascii_code), .bin41(ascii_bin41), .bin42(ascii_bin42));
bcd_seg_driver u_seg_cnt10(.en(1'b1), .bcd(cnt_bcd10), .seg(seg_cnt10));
bcd_seg_driver u_seg_cnt01(.en(1'b1), .bcd(cnt_bcd01), .seg(seg_cnt01));
hex_seg_driver u_seg_ascii10(.en(key_pressed), .hex(ascii_bin41), .seg(seg_ascii10));
hex_seg_driver u_seg_ascii01(.en(key_pressed), .hex(ascii_bin42), .seg(seg_ascii01));
hex_seg_driver u_seg_key10(.en(key_pressed), .hex(key_bin41), .seg(seg_key10));
hex_seg_driver u_seg_key01(.en(key_pressed), .hex(key_bin42), .seg(seg_key01));

endmodule

