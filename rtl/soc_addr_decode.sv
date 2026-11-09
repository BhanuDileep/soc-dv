module soc_addr_decode(
input logic[31:0] addr_i,
output logic[2:0] dev_sel_o);
localparam logic[31:0] UART_BASE = 32'h0000_1000;
localparam logic[31:0] UART_MASK = ~(32'h0000_003F);
localparam logic[31:0] GPIO_BASE = 32'h0000_2000;
localparam logic[31:0] GPIO_MASK = ~(32'h0000_007F);
localparam logic[31:0] SIMCTRL_BASE = 32'h0002_0000;
localparam logic[31:0] SIMCTRL_MASK = ~(32'h0000_03FF);
localparam logic[31:0] TIMER_BASE = 32'h0003_0000;
localparam logic[31:0] TIMER_MASK = ~(32'h0000_03FF);
localparam logic[31:0] RAM_BASE = 32'h0010_0000;
localparam logic[31:0] RAM_MASK = ~(32'h000F_FFFF);
localparam logic[31:0] RV_PLIC_BASE = 32'h1000_0000;
localparam logic[31:0] RV_PLIC_MASK = ~(32'h07FF_FFFF);

always_comb begin
if((addr_i & UART_MASK) == UART_BASE) dev_sel_o = 0;
else if((addr_i & GPIO_MASK) == GPIO_BASE) dev_sel_o = 1;
else if((addr_i & SIMCTRL_MASK) == SIMCTRL_BASE) dev_sel_o = 2;
else if((addr_i & TIMER_MASK) == TIMER_BASE) dev_sel_o = 3;
else if((addr_i & RAM_MASK) == RAM_BASE) dev_sel_o = 4;
else if((addr_i & RV_PLIC_MASK) == RV_PLIC_BASE) dev_sel_o = 5;
else dev_sel_o = 6;
end
endmodule
