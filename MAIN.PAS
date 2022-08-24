program main;

uses crt, graph, bgsound, dos;

const
MAX_WIDTH: integer = 640;
MAX_HEIGHT: integer = 200;
BOX_SIZE: integer = 5;
START_X: integer = 35;
START_Y: integer = 20;
END_X: integer = 640 - 36;
END_Y: integer = 200 - 21;

var
ch: char;
main_x, main_y, parts_count, lowerx1, lowery1, lowerx2, lowery2, current_direction, faster, current_food : integer;
n, n2, state, temp_x, temp_y : integer;
last_part_x, last_part_y, last_part_direction: integer;
titledraw, gotbox, is_ok: boolean;
currentspeed: integer;
boxpointer, bodypointer: pointer;
boxsize, bodysize: word;
parts_x, parts_y, parts_direction, temp_parts_x, temp_parts_y, temp_parts_direction: array[0..29] of integer; 
food_x, food_y: array[0..19] of integer;

procedure playbgsound1;
begin
     getintvec($1c, int1csave);
     setintvec($1c, new1cint);
     startsound(@BGSound1, 100, 1);
end;

procedure playbgsound2;
begin
     getintvec($1c, int1csave);
     setintvec($1c, new1cint);
     startsound(@BGSound2, 100, 1);
end;

procedure stopsound;
begin
     setintvec($1c, int1csave);
     nosound;
end;

procedure init;
var gd, gm : integer;
begin
     gd := EGA;
     gm := EGALo;
     initgraph(gd, gm, '.\BGI');
     gd := graphresult;
     state := 0;
     currentspeed := 800;
     gotbox := false;
     titledraw := true;
     setbkcolor(black);

     if gd <> grok then
     begin
          writeln('Unable to initialize graphic card.');
          halt;
     end;
end;

procedure title;

begin

     if titledraw then
     begin
     {draw once}
     setcolor(lightcyan);

     rectangle(0, 0, MAX_WIDTH - 1, MAX_HEIGHT - 1);
     setfillstyle(xhatchfill, red);
     floodfill(1, 1, lightcyan);

     setcolor(white);
     rectangle(50, 50, MAX_WIDTH - 51, MAX_HEIGHT - 51);
     setfillstyle(solidfill, green);
     floodfill(51, 51, white);

     setcolor(black);
     settextstyle(0, 0, 5);
     outtextxy(103, 72, 'Larong Ahas');
     settextstyle(0, 0, 1);
     outtextxy(240, 125, 'PRESS ENTER TO START');
     titledraw := false;
     end;

end;

procedure game;
begin
     if not gotbox then
     begin

          main_x := 100 + START_X;
          main_y := 100 + START_Y;
          parts_count := 5;
          is_ok := false;
          lowerx1 := 0;
          lowery1 := 0;
          lowerx2 := 0;
          lowery2 := 0;
          current_direction := 2;
          {
               0 - down
               1 - left
               2 - up
               3 - right
          }

          for n := 0 to 29 do
          begin
               parts_x[n] := 0;
               parts_y[n] := 0;
               parts_direction[n] := 0;
               temp_parts_x[n] := 0;
               temp_parts_y[n] := 0;
               temp_parts_direction[n] := 0;
          end;

          last_part_x := 0;
          last_part_y := 0;
          last_part_direction := 0;

          current_food := 0;

          for n := 0 to 19 do
          begin
               food_x[n] := 0;
               food_y[n] := 0;
          end;

          {init blue blox}
          setcolor(brown);
          rectangle(START_X, START_Y, END_X, END_Y);
          setfillstyle(solidfill, blue);
          floodfill(START_X + 1, START_X + 1, brown);
          boxsize := imagesize(START_X, START_Y, END_X, END_Y);
          getmem(boxpointer, boxsize);
          getimage(START_X, START_Y, END_X, END_Y, boxpointer^);

          {init snake body}
          temp_x := START_X + main_x;
          temp_y := START_Y + main_y;
          setcolor(lightgreen);
          for n := 1 to BOX_SIZE do
          begin
               temp_x := START_X + main_x;
               for n2 := 1 to BOX_SIZE do
               begin

                    if (n2 = 1) or (n = 1) or (n = BOX_SIZE) or (n2 = BOX_SIZE) then 
                    putpixel(temp_x, temp_y, cyan) 
                    else 
                    putpixel(temp_x, temp_y, lightgreen);

                    temp_x := temp_x + 1;
               end;
               temp_y := temp_y + 1;
          end;

          bodysize := imagesize(main_x + START_X, main_y + START_Y, main_x + BOX_SIZE + START_X, main_y + BOX_SIZE + START_Y);
          getmem(bodypointer, bodysize);
          getimage(main_x + START_X, main_y + START_Y, main_x + BOX_SIZE + START_X, main_y + BOX_SIZE + START_Y, bodypointer^);

          gotbox := true;
     end
     else
     begin
          {start of double buffering}
          
          setvisualpage(0);
          setactivepage(1);
          putimage(START_X, START_Y, boxpointer^, 0);
          putimage(main_x + START_X, main_y + START_Y, bodypointer^, 0);
          
          setvisualpage(1);
          setactivepage(0);
          putimage(START_X, START_Y, boxpointer^, 0);
          putimage(main_x + START_X, main_y + START_Y, bodypointer^, 0);
          
          {end of double buffering}

          main_x := main_x + BOX_SIZE;
     end;

end;

begin
     playbgsound1;
     init;
     {main loop}
     while true do
     begin

           case state of
               0:
               begin
               { title }
               title;
               end;
               1:
               begin
               { main game }
               game;
               end;
           end;

          if keypressed then
          begin
               ch := readkey;

               if ord(ch)=13 then
               begin
                    if state=0 then
                    begin
                         cleardevice;
                         playbgsound2;
                         state := 1;
                         stopsound;
                         titledraw := true;
                    end;
               end;

               if ord(ch)=27 then break;
          end;

          delay(currentspeed);
     end;
     {end of main loop}
     freemem(boxpointer, boxsize);
     freemem(bodypointer, bodysize);
     stopsound;
     closegraph;
end.