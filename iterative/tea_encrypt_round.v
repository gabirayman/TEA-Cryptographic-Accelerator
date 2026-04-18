module tea_encrypt_round(
    input [63:0] v,
    input [127:0] k,
    input [31:0] sum,
    output [63:0] out
);

wire [31:0] v0 = v[63:32];
wire [31:0] v1 = v[31:0];
wire [31:0] k0 = k[127:96];
wire [31:0] k1 = k[95:64];
wire [31:0] k2 = k[63:32];
wire [31:0] k3 = k[31:0];

wire [31:0] v0_new = v0 + (((v1 << 4) + k0) ^ (v1 + sum) ^ ((v1 >> 5) + k1));
wire [31:0] v1_new = v1 + (((v0_new << 4) + k2) ^ (v0_new + sum) ^ ((v0_new >> 5) + k3));

assign out = {v0_new, v1_new};
endmodule