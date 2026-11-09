class gpio_item extends uvm_sequence_item;
  `uvm_object_utils(gpio_item)

  // Driver side: the input pattern, and when to apply it
  rand bit [31:0]    gpio_i;
  rand int unsigned  delay_ns;
  constraint c_delay { soft delay_ns inside {[50:500]}; }   // random timing, unrelated to the clock

  // Monitor side: the observed outputs
  logic [31:0] gpio_o;
  logic [31:0] gpio_oe;
  bit          in_changed;     // gpio_i differs from the previous clock edge
  bit          out_changed;    // gpio_o or gpio_oe differs from the previous clock edge

  function new(string name = "gpio_item");
    super.new(name);
  endfunction

  virtual function string convert2string();
    return $sformatf("GPIO in=0x%08h (after %0d ns)  out=0x%08h oe=0x%08h",
                     gpio_i, delay_ns, gpio_o, gpio_oe);
  endfunction
endclass