#!/bin/bash
# Mini regression: build once, run every test, check each against its rules.
SIMDIR=~/soc-dv/build/sim
SWDIR=~/soc-dv/sw/tests     # C tests stay here for now
cd $SIMDIR

~/soc-dv/scripts/build.sh || exit 1

pass=0; fail=0

# run_test <test> <rule> <rule> ...
#   a rule "text"  -> output must contain text
#   a rule "!text" -> output must NOT contain text
run_test () {
  #local test=$1; shift
  local spec=$1; shift
  local test=${spec%@*}                       # the part before '@': the C program
  local uvm=${spec#*@}                        # the part after '@': the UVM test
  [ "$uvm" = "$spec" ] && uvm=soc_base_test   # no '@' given: use the default
  rm -f ibex_simple_system.log trace_core_00000000.log
  ./obj_tb/tb_sim +vmem=$SWDIR/$test/$test.vmem +UVM_TESTNAME=$uvm > $test.out 2>&1
  cp ibex_simple_system.log $test.log 2>/dev/null || touch $test.log
  cat $test.out $test.log > $test.all          # check sim output + program log together

  local ok=1
  for rule in "$@"; do
    if [[ $rule == !* ]]; then
      grep -qF -- "${rule:1}" $test.all && { echo "    [$test] found forbidden: ${rule:1}"; ok=0; }
    else
      grep -qF -- "$rule" $test.all || { echo "    [$test] missing: $rule"; ok=0; }
    fi
  done

  if [ $ok -eq 1 ]; then echo "PASS  $test"; pass=$((pass+1))
  else                   echo "FAIL  $test"; fail=$((fail+1)); fi
}

# ---- Test list ----
run_test hello_test \
  "Hello simple system" \
  "Terminating simulation by software request" \
  "UVM_ERROR :    0" \
  "UVM_FATAL :    0" \
  "!EXCEPTION" "!TIMEOUT" "!ERROR:"

run_test unmapped_test \
  "Hello simple system" \
  "MCAUSE: 0x00000007" \
  "MTVAL:  0x00040000" \
  "Terminating simulation by software request" \
  "UVM_ERROR :    0" \
  "UVM_FATAL :    0" \
  "!TIMEOUT" "!ERROR:"

run_test uart_test \
  "TEST PASSED" \
  "Terminating simulation by software request" \
  "UVM_ERROR :    0" \
  "UVM_FATAL :    0" \
  "!TEST FAILED" "!TIMEOUT" "!ERROR:" \
  "!EXCEPTION"

run_test gpio_test \
  "TEST PASSED" \
  "Terminating simulation by software request" \
  "UVM_ERROR :    0" \
  "UVM_FATAL :    0" \
  "!TEST FAILED" "!EXCEPTION" "!TIMEOUT" "!ERROR:"

run_test plic_test \
  "TEST PASSED" \
  "Terminating simulation by software request" \
  "UVM_ERROR :    0" \
  "UVM_FATAL :    0" \
  "!TEST FAILED" "!EXCEPTION" "!TIMEOUT" "!ERROR:"

run_test uart_tx_test \
  "TEST PASSED" \
  "TX bytes matched" \
  "UART_MON" \
  "Terminating simulation by software request" \
  "UVM_ERROR :    0" \
  "UVM_FATAL :    0" \
  "!TEST FAILED" "!EXCEPTION" "!TIMEOUT" "!ERROR:"

run_test uart_echo_test@uart_echo_test \
  "TEST PASSED" \
  "TX bytes matched" \
  "Echo: all" \
  "Terminating simulation by software request" \
  "UVM_ERROR :    0" \
  "UVM_FATAL :    0" \
  "!TEST FAILED" "!EXCEPTION" "!TIMEOUT" "!ERROR:" 

run_test gpio_in_test@gpio_in_test \
  "TEST PASSED" \
  "GPIO echo: all" \
  "Terminating simulation by software request" \
  "UVM_ERROR :    0" \
  "UVM_FATAL :    0" \
  "!TEST FAILED" "!EXCEPTION" "!TIMEOUT" "!ERROR:"

run_test soc_concurrent_test@soc_concurrent_test \
  "TEST PASSED" \
  "TX bytes matched" \
  "Echo: all" \
  "GPIO echo: all" \
  "Terminating simulation by software request" \
  "UVM_ERROR :    0" \
  "UVM_FATAL :    0" \
  "!TEST FAILED" "!EXCEPTION" "!TIMEOUT" "!ERROR:"

echo "----"
echo "PASSED: $pass   FAILED: $fail"
[ $fail -eq 0 ]
