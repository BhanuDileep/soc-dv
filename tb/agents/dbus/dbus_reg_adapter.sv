class dbus_reg_adapter extends uvm_reg_adapter;
    `uvm_object_utils(dbus_reg_adapter)

    function new(string name = "dbus_reg_adapter");
        super.new(name);
        supports_byte_enable = 1;     // dbus_item carries byte enables
    endfunction

    // Required by the base class; unused here, since software, not RAL, drives the bus
    // Builds a bus REQUEST from a register operation. Unused here (software, not RAL,
    // drives the bus), but the base class requires it, so it's kept correct.
    virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
        dbus_item t = dbus_item::type_id::create("t");
        t.we    = (rw.kind == UVM_WRITE);
        t.addr  = rw.addr[31:0];
        t.wdata = rw.data[31:0];      // meaningful for writes only; ignored by the bus on reads
        t.be    = rw.byte_en;
        return t;                     // rdata and err are RESULTS: they come back via bus2reg
    endfunction

    // Called by the predictor for every observed bus transaction
    virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
        dbus_item t;                                                   // 1. declare it
        if (!$cast(t, bus_item))                                       // 2. check the cast
            `uvm_fatal("REG_ADAPTER", "bus2reg: item is not a dbus_item")
        rw.kind    = t.we ? UVM_WRITE : UVM_READ;
        rw.addr    = t.addr;
        rw.data    = t.we ? t.wdata : t.rdata;                         // 3. t.rdata, with a dot
        rw.byte_en = t.be;
        rw.status  = t.err ? UVM_NOT_OK : UVM_IS_OK;                   // 4. t.err   5. UVM_IS_OK
    endfunction
endclass