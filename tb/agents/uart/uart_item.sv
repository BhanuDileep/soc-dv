class uart_item extends uvm_sequence_item;
    `uvm_object_utils(uart_item)

    rand logic[7:0] data;
    logic frame_err;

    function new(string path = "uart_item");
        super.new(path);
    endfunction

    virtual function string convert2string();
        // Show the byte as a character only if printable ASCII (0x20-0x7E), else '.'
        logic [7:0] c = (data >= 8'h20 && data <= 8'h7E) ? data : 8'h2E;   // 8'h2E = '.'
        return $sformatf("UART data=0x%02h '%c' frame_err=%0d", data, c, frame_err);
    endfunction
endclass