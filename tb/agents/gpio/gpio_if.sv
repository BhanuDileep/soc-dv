interface gpio_if(
    input logic clk
);
    logic[31:0] gpio_i;
    logic[31:0] gpio_o;
    logic[31:0] gpio_oe;
endinterface