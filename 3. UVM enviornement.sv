`include "uvm_macros.svh"
import uvm_pkg::*;

//class
class packet extends uvm_sequence_item;
  rand bit [3:0] src, dst;
  rand bit [7:0] data;
  // constraint valid {payload.size inside {[2:100]};}
  
  `uvm_object_utils_begin(packet) // support method
    `uvm_field_int(src, UVM_DEFAULT)
    `uvm_field_int(dst, UVM_DEFAULT)
    `uvm_field_int(data, UVM_DEFAULT)
  `uvm_object_utils_end
  
  function new(string name = "packet");
    super.new(name);
  endfunction
endclass


// Sequencer class
class packet_sequencer extends uvm_sequencer #(packet);
  `uvm_component_utils(packet_sequencer)
  
  function new(string name="packet_sequencer", uvm_component parent=null);
    super.new(name, parent);
  endfunction
endclass
    
  
// Sequence class
class packet_sequence extends uvm_sequence #(packet);
  `uvm_object_utils(packet_sequence)
    packet req;
    
  function new (string name = "packet_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    begin
      `uvm_info("SEQ", "Give sequence to sequencer", UVM_MEDIUM);
      req = packet::type_id::create("req"); 
      `uvm_do(req);
      `uvm_do(req);
      `uvm_do(req);
      `uvm_do_with(req, {src == 3;})
    end
  endtask
endclass
    
// Driver class
class driver extends uvm_driver #(packet);
  `uvm_component_utils(driver)
  packet pkt;
  
  function new(string name = "driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  virtual task run();
    `uvm_info("Trace", "Driver received the sequence", UVM_MEDIUM)
    forever
      begin
      seq_item_port.get_next_item(pkt);
      pkt.print();
      seq_item_port.item_done();
    end
  endtask
endclass
    
// Environment class
class environment extends uvm_env;
  `uvm_component_utils(environment)
   
  packet_sequencer seqr;
  driver drv;
  packet pkt;
  
  function new(string name = "environment", uvm_component parent = null);
    super.new(name, parent);
  endfunction
   
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    seqr = packet_sequencer::type_id::create("seqr", this);
    drv = driver::type_id::create("drv", this);
  endfunction
   
  virtual function void connect_phase(uvm_phase phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction
endclass
    
// Test case class
class test_base extends uvm_test;
   
  environment env;
  packet pkt;
  packet_sequence pkt_seq;
  
  `uvm_component_utils(test_base)
  
  function new(string name = "test_base", uvm_component parent = null);
    super.new(name, parent);
  endfunction
   
  virtual function void build();
    super.build();
    env = environment::type_id::create("env", this);
    pkt_seq = packet_sequence::type_id::create("pkt_seq");
  endfunction
  
  virtual task run();
    phase_started(uvm_run_phase::get()); 
   // env.pkt_seq = pkt_seq;
    pkt_seq.start(env.seqr);
    phase_ended(uvm_run_phase::get());
  endtask
endclass

// Testbench module
module tb_top;
  initial begin
    run_test("test_base");
  end
endmodule
