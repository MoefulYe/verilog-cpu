module ALU (
    input [31:0] _lhs,
    input [31:0] _rhs,
    input rst_n,
    input clk,
    /// input | op
    /// 0000  | add signed
    /// 0001  | sll
    /// 0010  | slt
    /// 0011  | sltu
    /// 0100  | xor
    /// 0101  | srl
    /// 0110  | or
    /// 0111  | and
    /// 1000  | sub signed
    /// 1001  | sra
    /// 1010  | add unsigned
    /// 1011  | sub unsigned
    /// ****  | unvalid
    input [3:0] op, 
    output reg [31:0] res,
    output reg [3:0] flags // [is_zero, is_positive, carry, overflow]
);

reg [31:0] lhs,rhs;

@always(negedge rst_n or posedge clk) begin
    if(!rst_n)begin
        lhs <= 32'b0;
        rhs <= 32'b0;
    end else begin
        lhs <= _lhs;
        rhs <= _rhs;
    end
end

always @(*) begin
    case(op)
        4'b0000:begin //add signed
            res = lhs + rhs;
            flags[0] = lhs[31]==rhs[31] && res[31]!=lhs[31];
        end 
        4'b0001:begin  res = lhs << rhs; end // sll
        4'b0010:begin res = $signed(lhs) < $signed(rhs); end //slt
        4'b0011:begin res = lhs < rhs; end //sltu
        4'b0100:begin res = lhs ^ rhs; end //xor
        4'b0101:begin res = lhs >> rhs; end //srl
        4'b0110:begin res = lhs | rhs; end //or
        4'b0111:begin res = lhs & rhs; end //and
        4'b1000:begin //sub signed
            res  = lhs - rhs;
            flags[0] = lhs[31]==0&&rhs[31]==1&&res[31]==1 ||
                lhs[31]==1&&rhs[31]==0&&res[31]==0;
        end
        4'b1001:begin 
            res = $signed(lhs) >>> rhs;
        end
        4'b1010:begin { flags[1], res } = lhs + rhs; end //add
        4'b1011:begin { flags[1], res } = lhs - rhs; end //add
        default: begin res = 0; end
    endcase 
    flags[3] <= res == 32'h0000_0000 ? 1 : 0;
    flags[2] <= res[32];
end
endmodule