`timescale 1ns/1ps

module top();

///parameter half_clk_period = 2;
/////// clk_count =  [$clog2(half_clock_period * 2)-1 : 0 ]  --> [2-1 : 0]  -> [1:0]
//////  clk_edges = total_data_bits * 2;

reg ready = 1;
integer spi_edges = 0;
reg start = 0;
reg [1:0] clk_count = 0;
reg spi_l = 0 , spi_t = 0; //SPI Leading edge and trailing edge
reg sclk = 0;
reg clk = 0; //clock
reg cpol = 0; //C Polarity is 1 which means that the clock is active low


//////////////Stimuli Gen //////////////////////////
always #5 clk = ~clk;

initial begin
    @(posedge clk)
     start = 1;
    @(posedge clk)
     start = 0;
end

reg start_t = 0;

always @(posedge clk ) begin
    start_t <= start;
end

//////////////////////////Logic for sclk /////////////////
always @(posedge clk) begin
    if(start_t == 1'b1) begin
        ready <= 1'b0;
        spi_edges <= 16;
        sclk <= cpol;
    end
    else if(spi_edges > 0) begin
        spi_l <= 1'b0;
        spi_t <= 1'b0;

        if(clk_count == 1) begin
            spi_l <= 1'b1;
            sclk = ~sclk;
            spi_edges <= spi_edges - 1;
            clk_count <= clk_count + 1;
        end
        else if(clk_count == 3) begin
            spi_t <= 1'b1;
            sclk <= ~sclk;
            spi_edges <= spi_edges - 1;
            clk_count <= clk_count + 1;
        end
        else begin
            clk_count <= clk_count + 1;
        end
    end
    else begin
        ready <= 1'b1;
        spi_l <= 1'b0;
        spi_t <= 1'b0;
        sclk <= cpol; // Reset sclk to cpol state
    end
end

/////////////////////////////CPHASE ///////////////////////////////////////


reg mosi = 0; 
reg cpha = 1; //c phase state
reg [7:0] tx_data = 8'b10101010; 
reg [2:0] bit_count = 3'b111;
reg ready_t = 0;
reg [7:0] tx_data_t ;
reg [2:0] state = 0;
reg cs = 1;
integer count = 0;

//////////////////////////////////////////////////////////////

always @(posedge clk ) begin
    case(state)
     
     0: begin
        if(start) begin
            if(!cpha) begin
                state <= 1;
                cs <= 1'b0;
            end
            else begin
                state <= 3 ;
                cs <= 1'b0;
            end
        end
        else 
         state <= 0 ;
    end

    1 : begin
        if(count < 3) begin
            count <= count + 1;
            state <= 1;
            mosi <= tx_data[bit_count] ;
        end
        else begin
            count <= 0; 
            if(bit_count != 0) begin
                bit_count <= bit_count - 1;
                state <= 1;
            end
            else
             state <= 2;
        end
    end

    2 : begin
        cs <= 1'b1;
        bit_count <= 3'b111;
        state <= 0;
        mosi <= 1'b0;
    end

    3 : begin
        state <= 4 ;
    end

    4 : begin
        state <= 1;
    end

    endcase

end

//////////////////////////////////////////////////////////
///////////////////////////
//slave

reg [7:0] rx_data = 7'h0;
integer r_count = 0;

always@(posedge sclk)
begin
if(cs == 0)
begin
 if(r_count < 8)
   begin
     rx_data <= {rx_data[6:0],mosi};
     r_count  <= r_count + 1;
   end 
   else
   begin
   r_count <= 8'h0;
   end
end
end

endmodule