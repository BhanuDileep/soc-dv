class soc_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(soc_scoreboard);

    uvm_analysis_imp #(dbus_item, soc_scoreboard) a_imp;
    string bus_string = "";

    function new(string path = "soc_scoreboard", uvm_component parent = null);
        super.new(path, parent);
        a_imp = new("a_imp", this);
    endfunction

    function void write(dbus_item item);
        if (item.we && item.addr == 32'h0002_0000 && item.be[0])
            bus_string = {bus_string, $sformatf("%c", item.wdata[7:0])};
    endfunction

    function void check_phase(uvm_phase phase);
        int    fd, c;
        string log_string = "";
        super.check_phase(phase);

        // Read the log file that SimCtrl wrote, character by character
        fd = $fopen("ibex_simple_system.log", "r");
        if (fd == 0) begin
            `uvm_error("SCB", "Cannot open ibex_simple_system.log")
            return;
        end
        forever begin
            c = $fgetc(fd);
            if (c == -1) break;                 // -1 means end of file
            log_string = {log_string, $sformatf("%c", c)};
        end
        $fclose(fd);

        // Compare the two independent views
        if (bus_string == log_string)
            `uvm_info("SCB", $sformatf("Bus and log match (%0d characters)", bus_string.len()), UVM_LOW)
        else
            `uvm_error("SCB", $sformatf("MISMATCH\n  bus: \"%s\"\n  log: \"%s\"", bus_string, log_string))
    endfunction
endclass

