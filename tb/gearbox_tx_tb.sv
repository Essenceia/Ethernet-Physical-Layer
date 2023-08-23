module gearbox_tx_tb;
localparam DATA_W = 64;
localparam HEAD_W = 2;
localparam SEQ_N = DATA_W/HEAD_W + 1;
localparam SEQ_W  = $clog2(SEQ_N);
localparam TB_BUF_W = SEQ_N * ( HEAD_W + DATA_W );

reg   clk = 1'b0;

logic [SEQ_W-1:0]  seq_i;
logic [HEAD_W-1:0] head_i;
logic [DATA_W-1:0] data_i;
logic              full_v_o; // backpressure, buffer is full, need a cycle to clear 
logic [DATA_W-1:0] data_o;

logic [TB_BUF_W-1:0] tb_buf;
reg   [TB_BUF_W-1:0] got_buf;
logic [TB_BUF_W-1:0] db_buf_diff;

/* verilator lint_off BLKSEQ */
always clk = #5 ~clk;
/* verilator lint_on BLKSEQ */

// generate a random array of 66b of data for a given sequence and
// check it is correctly outputed aligned on 64b
task new_seq();
	// set default values
	logic [HEAD_W-1:0] h;
	logic [DATA_W-1:0] d;
	for( int seq = 0; seq< SEQ_N; seq++ ) begin
		h = 2'b11;
		d = { $random(), $random() };
		// fill tb buffer
		tb_buf = { tb_buf[TB_BUF_W-(HEAD_W+DATA_W)-1:0],d, h };
		// drive uut
		seq_i = SEQ_W'(seq);
		head_i = h;
		data_i = d;
		#1
		assert(~full_v_o);
		#9
		$display("Seq %d", seq);
	end	
	assert(full_v_o);
endtask

always @(posedge clk) begin
	got_buf <= { got_buf[TB_BUF_W-DATA_W-1:0] , data_o};	
end

assign db_buf_diff = got_buf ^ tb_buf; 

initial begin
	$dumpfile("wave/gearbox_tx_tb.vcd");
	$dumpvars(0, gearbox_tx_tb);
	#10
	$display("test 1 %t", $time);
	new_seq();
	#10
	// self check
	// no difference between got and expected
	assert( ~|db_buf_diff );
	#10
	$display("Sucess");	
	$finish;
end

// uut 
gearbox_tx #(.DATA_W(DATA_W))
m_gearbox_tx(
.clk(clk),
.seq_i(seq_i),
.head_i(head_i),
.data_i(data_i),
.full_v_o(full_v_o),
.data_o(data_o)
);
endmodule
