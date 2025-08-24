module fsm_spi(
    input wire clk,
    input wire rst,
    input wire tx_enable,
    output reg mosi,
    output reg cs,
    output wire sclk
);

    typedef enum logic [1:0] {idle = 0, start_tx = 1, tx_data = 2, end_tx = 3 } state_type;
    state_type state, next_state;
    
    
    reg [7:0] din = 8'hef;

    reg spi_sclk = 0;
    reg [2:0] ccount = 0;
    reg [2:0] count = 0; // 0 -7 
    integer bit_count = 0;
    
    always@(posedge clk)
    begin
    if(!rst && tx_enable)
    begin
    if(ccount < 3)
      ccount <= ccount + 1;
    else
      begin
      ccount <= 0;
      spi_sclk <= ~spi_sclk;
      end
    end
    end
    
   //////////////////////////////////////// 
    always@(posedge sclk)
    begin
    case(state)
    
    idle : 
    begin
    mosi <= 1'b0;
    cs   <= 1'b1; 
    if(tx_enable && !rst)
    begin
    state <= tx_data;
    cs <= 1'b0;
    end
    else
    state <= idle;
    end
    

    tx_data:
    begin
    if(count < 8)
      begin
      mosi  <= din[7-count]; 
      count <= count + 1;
      end
    else
      begin
      mosi <= 0;
      cs   <= 1'b1;
      state <= idle;
      end
    end
    
    default: state <= idle;
    endcase
    end
   
 assign sclk = spi_sclk;
  
 endmodule


 module spi_slave (
input sclk, mosi,cs,
output [7:0] dout,
output reg done 
);

integer count = 0;
typedef enum logic  {idle = 0, sample = 1 } state_type;
state_type state;

reg [7:0] data = 0;

  
always@(negedge sclk)
begin
case (state)

idle: begin
done <= 1'b0;

if(cs == 1'b0)
state <= sample;
else
state <= idle;
end

sample: 
begin
        if(count < 8)
        begin
        count <= count + 1;
        data <= {data[6:0],mosi};
        state <= sample;
        end
        else
        begin
        count <= 0;
        state <= idle;
        done  <= 1'b1;
        end
end

default : state <= idle;
endcase

end

assign dout = data;

endmodule

module top
(
input clk, rst, tx_enable,
output [7:0] dout,
output done
);

wire mosi, ss, sclk;

fsm_spi    spi_m (clk, rst, tx_enable, mosi, ss, sclk);
spi_slave  spi_s (sclk, mosi,ss, dout, done);

endmodule

////////////////// TB Code

module tb;

    reg clk = 0;
    reg rst = 0;
    reg tx_enable = 0;
    wire [7:0] dout;
    wire done;
    
    
    always #5 clk = ~clk;
    
    initial begin
    rst = 1;
    repeat(5) @(posedge clk);
    rst = 0;
    end

    initial begin
    tx_enable = 0;
    repeat(5) @(posedge clk);
    tx_enable = 1;
    end

top dut (clk, rst, tx_enable, dout, done);

endmodule