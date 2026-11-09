class gpio_in_seq extends uvm_sequence #(gpio_item);
  `uvm_object_utils(gpio_in_seq)

  rand int unsigned n_inputs;
  constraint c_n { n_inputs inside {[6:16]}; }

  logic [15:0] last_gpio_i = '0;      // matches the driver's starting value

  function new(string name = "gpio_in_seq");
    super.new(name);
  endfunction

  task body();
    repeat (n_inputs) begin
      req = gpio_item::type_id::create("req");
      start_item(req);
      if (!req.randomize() with {
            gpio_i[31:16] == '0;                       // pins 16-31 are outputs in this test
            gpio_i[15:0]  != local::last_gpio_i;       // a real change: at least one edge
            delay_ns inside {[3000:6000]};             // slower than software can respond
          })
        `uvm_fatal("GPIO_SEQ", "randomize() failed")
      last_gpio_i = req.gpio_i[15:0];                  // remember what was actually sent
      finish_item(req);
    end
  endtask
endclass