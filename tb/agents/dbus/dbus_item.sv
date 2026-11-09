class dbus_item extends uvm_sequence_item;
`uvm_object_utils(dbus_item)

logic[31:0] addr;
logic we;
logic[3:0] be;
logic[31:0] wdata;
logic[31:0] rdata;
logic err;

function new(string path = "dbus_item");
super.new(path);
endfunction

function string convert2string();
if(we) begin
    return $sformatf("ST addr = %h be = %h wdata = %h err=%d", addr, be, wdata, err);
end else begin
    return $sformatf("LD addr = %h be = %h rdata = %h err=%d", addr, be, rdata, err);
end

endfunction

endclass