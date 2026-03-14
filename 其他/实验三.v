module top (
    input [3:0] A,        // 操作数A（补码）
    input [3:0] B,        // 操作数B（补码）
    input [2:0] f,        // 功能选择
    output [3:0] result,  // 运算结果
    output zero,          // 结果为零标志
    output overflow,      // 溢出标志（仅加减有效）
    output carry          // 进位/借位标志（仅加减有效）
);

    // 加法
    wire [4:0] add_full = {1'b0, A} + {1'b0, B};   // 扩展一位以获取进位
    wire [3:0] add_res = add_full[3:0];
    wire add_cout = add_full[4];
    wire add_overflow = (A[3] == B[3]) && (add_res[3] != A[3]);

    // 减法
    wire [4:0] sub_full = {1'b0, A} + {1'b0, ~B} + 1'b1;
    wire [3:0] sub_res = sub_full[3:0];
    wire sub_cout = sub_full[4];
    wire [3:0] B_neg = ~B + 1'b1;                  // -B 的补码
    wire sub_overflow = (A[3] == B_neg[3]) && (sub_res[3] != A[3]);

    // 逻辑运算
    wire [3:0] not_res = ~A;
    wire [3:0] and_res = A & B;
    wire [3:0] or_res  = A | B;
    wire [3:0] xor_res = A ^ B;

    // 比较运算 
    wire lt = ($signed(A) < $signed(B));            // 带符号数小于
    wire [3:0] cmp_res = {3'b0, lt};
    wire eq = (A == B);
    wire [3:0] eq_res = {3'b0, eq};

    // 功能选择
    assign {overflow, carry, zero, result} = 
        (f == 3'b000) ? {add_overflow, add_cout, (add_res == 4'b0), add_res} :
        (f == 3'b001) ? {sub_overflow, sub_cout, (sub_res == 4'b0), sub_res} :
        (f == 3'b010) ? {1'b0, 1'b0, (not_res == 4'b0), not_res} :
        (f == 3'b011) ? {1'b0, 1'b0, (and_res == 4'b0), and_res} :
        (f == 3'b100) ? {1'b0, 1'b0, (or_res == 4'b0), or_res} :
        (f == 3'b101) ? {1'b0, 1'b0, (xor_res == 4'b0), xor_res} :
        (f == 3'b110) ? {1'b0, 1'b0, (cmp_res == 4'b0), cmp_res} :
                        {1'b0, 1'b0, (eq_res == 4'b0), eq_res};

endmodule