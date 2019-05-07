//Program Wrote by Patrick Scott
//5/1/19
//ECE 583 final project
//
//CMD, 000 = Add, 001 = Sub, 010 = Mult, 011 = div, 100 = modulo, 
//101 = shift right(shift a by b), 110 = shift left, 111 = Factorial(of a) 
module ALU( clk, sw, c, d, led, dp );
  input [15:0] sw; // [15:10] = A, [9:4] = B; [3:1] = cmd;
  input clk;
  output reg dp;
  output reg [0:6] c = 0;
  output reg [3:0] d;
  reg [2:0] cmd;
  reg signed [5:0] A, B;
  reg [15:0] out = 0; //goes up to decimal 16,383
  output reg [15:0] led; //[15] = overflow, [14] = error;
  reg [5:0] temp;
  reg [13:0] factorial = 1;
  reg [5:0] i;
  reg negFlag;
  //variables for 7 seg display
  reg [31:0] count = 0;
  reg [31:0] num = 0;
  reg [1:0] cycle;
  reg [31:0] digit = 0;
    
  //floating point var's
  reg [31:0] aboveRadix = 0;
  reg [31:0] belowRadix = 0;
  
  always @ ( posedge clk ) begin
    A = sw[15:10];
    B = sw[9:4];
    cmd = sw[3:1];
    factorial = 1;
    negFlag = 0;
    case(cmd) 
      3'b000 : begin //add
        out <= A + B;
      end
      3'b001 : begin //sub
        out <= A - B;
      end
      3'b010 : begin //mult
        out <= A * B;
        if( sw[0] == 1 )
            out = out >>> 3;
      end
      3'b011 : begin //div
        out <= A / B;
        if( sw[0] == 1 )
            out = out <<< 3;
      end
      3'b100 : begin //modulo
        out <= A % B;
      end
      3'b101 : begin //shift right
        out <= A >>> B;
        if( B == 0 )
            out = A;
      end
      3'b110 : begin //shift left
        out <= A <<< B;
        if( B == 0 )
            out = A;
      end
      3'b111 : begin //factorial of A
        temp = A;
        for( i = 0; i < 50; i=i+1 ) begin
            if( i < A-1 ) begin
        	   factorial = factorial*temp;
        	   temp = temp - 1;
        	end
    	end
    	if( A == 0 )
    	   factorial = 1;
    	if( A < 8 )
            out = factorial;
        else 
            out = 10000;
      end
    endcase
    //negFlag set
    if( out[15] == 1 ) begin
        out = (out*-1);
        negFlag = 1;
    end
    led[13] = negFlag;
    if( out > 9999 ) begin
    	led[15] <= 1;
    	out <= 0;
    end
 	else
    	led[15] <= 0;
    if( cmd == 3'b011 && B == 0 ) begin
        led[14] <= 1;
        out <= 0;
    end
    else
        led[14] <= 0;
    //interpret out as floating point
    if( sw[0] == 1 ) begin
        aboveRadix = out >> 3;
        case(out[2:0])
            3'b000 : belowRadix = 0;
            3'b001 : belowRadix = 12;
            3'b010 : belowRadix = 25;
            3'b011 : belowRadix = 37;
            3'b100 : belowRadix = 50;
            3'b101 : belowRadix = 52;
            3'b110 : belowRadix = 75;
            3'b111 : belowRadix = 87;
            default : belowRadix = 0; 
        endcase
        out = aboveRadix*100 + belowRadix;
    end
        num <= out;
    //Begining of the display handling
    count <= count + 32'd1;
        cycle <= count[19:18];
        if( (count%32'd100_000 == 0) ) begin
            case( cycle )
                2'b00: begin
                    digit = num%32'd10;
                    update( digit );
                    d <= 4'b1110;
                    dp <= 1;
                end
                2'b01: begin
                    digit = ( num%32'd100 )/32'd10;
                    update( digit );
                    d <= 4'b1101;
                    dp <= 1;
                end
                2'b10: begin
                    digit = ( num%32'd1000 )/32'd100;
                    update(digit);
                    d <= 4'b1011;
                    dp <= (sw[0]==1) ? 0 : 1;
                end
                2'b11: begin
                    digit = ( num%32'd10000 )/32'd1000;
                    update(digit);
                    d <= 4'b0111;
                    dp <= 1;
                end
            endcase  
        end
  end
  task update( input [31:0] num );
        case( num )
            32'd0: c <= 7'b0000001;
            32'd1: c <= 7'b1001111;
            32'd2: c <= 7'b0010010;
            32'd3: c <= 7'b0000110;
            32'd4: c <= 7'b1001100;
            32'd5: c <= 7'b0100100;
            32'd6: c <= 7'b0100000;
            32'd7: c <= 7'b0001111;
            32'd8: c <= 7'b0000000;
            32'd9: c <= 7'b0000100;
            //32'd10: c <= 7'b0001000; //A
            //32'd11: c <= 7'b1100000; //b
            //32'd12: c <= 7'b0110000; //C
            //32'd13: c <= 7'b1000010; //d
            //32'd14: c <= 7'b0110000; //E
            //32'd15: c <= 7'b0111000; //F
            default: c <= 7'b0000001;
        endcase   
    endtask
    
endmodule 
