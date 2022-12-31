module matrix_control(
    input clk_in,
    output [2:0] spi_out,
    output [7:0] led
);
    //steps to control the matrix
    //array of 16 bytes:
    //data[7:0],row,data[15:8],row,data[23:16],row,data[31:24],row,0,0,0,0,0,0,0,0
    //row is the row to be displayed (1-8) (0 is off)

    //to send the array:
    //turn off chip select (spi_out[2])
    //for each bit in the array
        //send 1 bit (spi_out[1])
        //turn on clock (spi_out[0])
        //turn off clock (spi_out[0])
    //turn on chip select (spi_out[2])

    //do this 8 times for each row
    //before sending the array you must send the configuration arrays
    //configuration arrays:
    //0x00,0x09,0x00,0x09,0x00,0x09,0x00,0x09,0x00,0x09,0x00,0x09,0x00,0x09,0x00,0x09 //turn off decode mode
    //INTENSITY,0x0a,INTENSITY,0x0a,INTENSITY,0x0a,INTENSITY,0x0a,INTENSITY,0x0a,INTENSITY,0x0a,INTENSITY,0x0a,INTENSITY,0x0a //set intensity
    //0x07,0x0b,0x07,0x0b,0x07,0x0b,0x07,0x0b,0x07,0x0b,0x07,0x0b,0x07,0x0b,0x07,0x0b //set scan limit to 8 rows
    //0x01,0x0c,0x01,0x0c,0x01,0x0c,0x01,0x0c,0x01,0x0c,0x01,0x0c,0x01,0x0c,0x01,0x0c //turn on display
    //0x00,0x0f,0x00,0x0f,0x00,0x0f,0x00,0x0f,0x00,0x0f,0x00,0x0f,0x00,0x0f,0x00,0x0f //turn off display test

    //to send the configuration arrays do the same as the data array

    //declaration of configuration array
    reg [16*8:0] config_array_0=128'hf0090009000900090009000900090009;//send when state=1
    reg [16*8:0] config_array_1=128'h000a000a000a000a000a000a000a000a;//send when state=2
    reg [16*8:0] config_array_2=128'h070b070b070b070b070b070b070b070b;//send when state=3
    reg [16*8:0] config_array_3=128'h010c010c010c010c010c010c010c010c;//send when state=4
    reg [16*8:0] config_array_4=128'h000f000f000f000f000f000f000f000f;//send when state=5

    //declaration of data arrays
    reg [16*8:0] data_array_0=128'haa01aa01aa01aa01aa01aa01aa01aa01;//send when state=8
    reg [16*8:0] data_array_1=128'haa02aa02aa02aa02aa02aa02aa02aa02;//send when state=9
    reg [16*8:0] data_array_2=128'haa03aa03aa03aa03aa03aa03aa03aa03;//send when state=10
    reg [16*8:0] data_array_3=128'haa04aa04aa04aa04aa04aa04aa04aa04;//send when state=11
    reg [16*8:0] data_array_4=128'haa05aa05aa05aa05aa05aa05aa05aa05;//send when state=12
    reg [16*8:0] data_array_5=128'haa06aa06aa06aa06aa06aa06aa06aa06;//send when state=13
    reg [16*8:0] data_array_6=128'haa07aa07aa07aa07aa07aa07aa07aa07;//send when state=14
    reg [16*8:0] data_array_7=128'haa08aa08aa08aa08aa08aa08aa08aa08;//send when state=15

    reg [25:0] slower_clock;
    always @(posedge clk_in)
        slower_clock=slower_clock+1;

    reg [15:0] counter;
    wire [5:0] state;
    always @(*) begin
        state = counter[14:10];
        //led=counter[7:0];
        led[0]=spi_out[0];//clock
        led[1]=spi_out[1];//data
        led[2]=spi_out[2];//chip select
    end
    
    
    //increment bit_to_send
    always @(posedge slower_clock[10])
        counter=counter+1;

    //multiplexor to select the array to send
    reg [16*8:0] array_to_send;
    always @(posedge clk_in) begin
        case(state)
            1: array_to_send=config_array_0;
            3: array_to_send=config_array_1;
            5: array_to_send=config_array_2;
            7: array_to_send=config_array_3;
            9: array_to_send=config_array_4;
            11: array_to_send=data_array_0;
            13: array_to_send=data_array_1;
            15: array_to_send=data_array_2;
            17: array_to_send=data_array_3;
            19: array_to_send=data_array_4;
            21: array_to_send=data_array_5;
            23: array_to_send=data_array_6;
            25: array_to_send=data_array_7;
        endcase
    end
    
    //send the bit
    always @(posedge clk_in) begin
        if(state[0]==0)begin
            spi_out[0]=0;//clock
            spi_out[1]=0;//data
            spi_out[2]=1;//chip select
        end
        else begin
            spi_out[2]=0;//chip select
            case(counter[1:0])
                2'b00: begin
                    spi_out[0]=0;//clock
                    spi_out[1]=0;//data
                end
                2'b01: begin
                    spi_out[0]=0;//clock
                    if(counter[10:2]==0)
                    spi_out[1]=array_to_send[128-counter[10:2]];//data

                end
                2'b10: begin
                    spi_out[0]=1;//clock
                    spi_out[1]=array_to_send[128-counter[10:2]];//data

                end
                2'b11: begin
                    spi_out[0]=0;//clock
                    spi_out[1]=array_to_send[128-counter[10:2]];//data
                end
            endcase
        end
    end
endmodule