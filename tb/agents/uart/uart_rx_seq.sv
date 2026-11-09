class uart_rx_seq extends uvm_sequence #(uart_item);
    `uvm_object_utils(uart_rx_seq);

    rand int unsigned num_bytes;
    constraint c_num { num_bytes inside {[4:16]}; } 

    function new(string name = "uart_rx_seq");
        super.new(name);
    endfunction

    task body();
        repeat (num_bytes) begin
            req = uart_item::type_id::create("req");
            start_item(req);                            // wait until the driver is ready
            if (!req.randomize()) `uvm_error("UART_SEQ", "randomize() failed")
            finish_item(req);                           // hand it over; waits for item_done
        end
    endtask
endclass