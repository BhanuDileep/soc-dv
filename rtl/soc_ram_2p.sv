// Behavioral dual-port RAM: port A = data (via TL-UL adapter), port B = instruction fetch.
// Both ports take WORD addresses. Read data appears one cycle after a request.
module soc_ram_2p #(
  parameter int Depth = 262144          // words (1 MB)
) (
  input  logic                     clk_i,
  // Port A: read/write
  input  logic                     a_req_i,
  input  logic                     a_we_i,
  input  logic [3:0]               a_be_i,
  input  logic [$clog2(Depth)-1:0] a_addr_i,
  input  logic [31:0]              a_wdata_i,
  output logic [31:0]              a_rdata_o,
  // Port B: read only
  input  logic                     b_req_i,
  input  logic [$clog2(Depth)-1:0] b_addr_i,
  output logic [31:0]              b_rdata_o
);
  logic [31:0] mem [Depth];   // the testbench backdoor-loads this array

  always_ff @(posedge clk_i) begin
    if (a_req_i) begin
      if (a_we_i) begin
        for (int i = 0; i < 4; i++)
          if (a_be_i[i]) mem[a_addr_i][8*i +: 8] <= a_wdata_i[8*i +: 8];
      end
      a_rdata_o <= mem[a_addr_i];
    end
    if (b_req_i) b_rdata_o <= mem[b_addr_i];
  end
endmodule
