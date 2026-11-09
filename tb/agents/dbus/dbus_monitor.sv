class dbus_monitor extends uvm_monitor;
`uvm_component_utils(dbus_monitor)


dbus_item dbus_queue[$];
virtual ib_dbus_if vif;
uvm_analysis_port #(dbus_item) ap;

function new(string path = "dbus_monitor", uvm_component parent = null);
super.new(path, parent);
ap = new("ap", this);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
if(!uvm_config_db #(virtual ib_dbus_if)::get(this, "", "vif", vif)) `uvm_fatal("MON", $sformatf("Cannot find the interface. Terminaing the simulation"));
endfunction

task run_phase(uvm_phase phase);
dbus_item transaction_item, item;
forever begin
    @(posedge vif.clk);
    if(!vif.rst_n) begin
        dbus_queue.delete();
    end else begin
        if(vif.rvalid) begin
            if(dbus_queue.size() == 0) `uvm_error("MON", $sformatf("response with no request"))
            else begin
                item = dbus_queue.pop_front();
                item.rdata = vif.rdata;
                item.err = vif.err;
                `uvm_info("MON", item.convert2string(), UVM_MEDIUM)
                ap.write(item);
            end
        end

        if(vif.req && vif.gnt) begin
            transaction_item = dbus_item::type_id::create("transaction_item");
            transaction_item.addr = vif.addr;
            transaction_item.we = vif.we;
            transaction_item.be = vif.be;
            transaction_item.wdata = vif.wdata;
            //transaction_item.rdata = vif.rdata;
            //transaction_item.err = vif.err;
            dbus_queue.push_back(transaction_item);
        end
    end
end
endtask
endclass