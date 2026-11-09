interface ib_dbus_if(
    input logic clk, rst_n
);
logic req;
logic gnt;
logic we;
logic rvalid;
logic err;
logic[3:0] be;
logic[31:0] addr;
logic[31:0] wdata;
logic[31:0] rdata;

endinterface