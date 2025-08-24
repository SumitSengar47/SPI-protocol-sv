//This Code is part of SPI => Serial Peripheral Interface Protocol
//It consists of a master and a slave ,working synchronously on a common clock

module  fsm_spi(
    input wire clk,
    input wire rst,
    input wire tx_enable, // Transmit enable 
    output reg mosi , //Master out Slave in
    output reg cs, // Chip select
    output wire sclk // Serial clock
);

typedef enum logic[1:0] { idle=0 , start_tx=1 , tx_data=2 , end_tx=3 } state_type;
state_type state , next_state;

reg [7:0] din = 8'b10101010 ; // Data to be transmitted

reg spi_sclk = 0; //Spi serial clock
//reg [2:0] ccount = 0; //Count for spi_sclk
reg [2:0] count = 0; //0-7 for SPI clk
integer bit_count = 0; //Count for the data bitsf

//////////////////////////////generating sclk ////////////////////////////////////////////
always@(posedge clk)
begin
    case(next_state)

     idle : begin
        spi_sclk <= 0;
     end

     start_tx : begin
        if(count < 3'b011 || count == 3'b111) 
         spi_sclk <= 1'b1;
        else
         spi_sclk <= 1'b0;
     end

     tx_data : begin
        if(count < 3'b011 || count == 3'b111) 
         spi_sclk <= 1'b1;
        else
         spi_sclk <= 1'b0;
     end

     end_tx : begin
        if(count < 3'b011)
         spi_sclk <= 1'b1;
        else
         spi_sclk <= 1'b0;
     end

     default : spi_sclk <= 1'b0;

    endcase
end 

//////////////////////Sense Reset /////////////////////////////
always @(posedge clk ) begin
    if(rst)
     state <= idle;  //reset
    else
     state <= next_state; //move to next state
end

//////////////////////////////Next_State Decoder /////////////////////////
always@(*) begin
    case(state)
    
        idle : begin
            mosi = 1'b0; //In idle state mosi is low
            cs = 1'b1; // Chip select is high
            if(tx_enable)
             next_state = start_tx;
            else
             next_state = idle;
        end

        start_tx : begin
            cs = 1'b0; // Chip select is low ,chip or slave is selected and transmition starts
            
            if(count == 3'b111)
             next_state = tx_data ;
            else
             next_state = start_tx;
        end

        tx_data : begin
            mosi = din[7 - bit_count] ; //MSB bits are transmitted first
            if(bit_count != 8) begin
                next_state = tx_data ;
            end
            else begin
                next_state = end_tx;
                mosi = 1'b0 ; //End of transmission
            end
        end

        end_tx : begin
            cs = 1'b1; // Chip select is high ,transmission is complete
            mosi = 1'b0; //End of transmission
            if(count == 3'b111) 
             next_state = idle;
            else
             next_state = end_tx;
        end

        default : next_state = idle; //default state

    endcase
end

//////////////////////////////Counter 

always @(posedge clk ) begin
    case(state)
        idle : begin
            count <= 0;
            bit_count <= 0;
        end

        start_tx : begin
            count <= count + 1;
        end

        tx_data : begin
            if(bit_count != 8) begin
                 if(count < 3'b111)
                    count <= count + 1;
                else begin
                    count <= 0;
                    bit_count <= bit_count + 1;
                end
            end
        end

        end_tx : begin
            count <= count + 1;
            bit_count <= 0;
        end

        default : begin
            count <= 0;
            bit_count <= 0;
        end

    endcase
end

////////////////////////////////////////////////

assign sclk = spi_sclk;

endmodule

//////////////////////////////////Testbench/////////////////////////////////////////////

module tb;
 
 reg clk = 0;
 reg rst = 0;
 reg tx_enable = 0;
 wire mosi ;
 wire ss;
 wire sclk;

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

 fsm_spi dut(clk,rst,tx_enable,mosi,ss,sclk);

endmodule
