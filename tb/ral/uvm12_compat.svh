// Compatibility shim: OpenTitan's DV library is written against UVM 1.2 and
// uses internal UVM 1.2 macros that uvm-core (IEEE 1800.2) no longer provides.
// Each macro is defined only if missing, so this file is harmless otherwise.

// UVM 1.2: declares the type-name string and get_type_name().
// (uvm-core's closest equivalent, uvm_type_name_decl, declares a function
// instead of a variable, so it isn't a drop-in replacement.)
`ifndef m_uvm_get_type_name_func
`define m_uvm_get_type_name_func(T) \
  const static string type_name = `"T`"; \
  virtual function string get_type_name(); \
    return type_name; \
  endfunction
`endif
