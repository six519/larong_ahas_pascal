program main;

uses crt, graph, bgsound, dos;

const
MAX_WIDTH: integer = 640;
MAX_HEIGHT: integer = 200;
BOX_SIZE: integer = 5;
ANIM_SPEED: integer = 10;
START_X: integer = 35;
START_Y: integer = 20;
END_X: integer = 640 - 36;
END_Y: integer = 200 - 21;

var
ch: char;
state, main_x, main_y, parts_count, lowerx1, lowery1, lowerx2, lowery2, current_direction, faster, current_food : integer;
last_part_x, last_part_y, last_part_direction: integer;
titledraw, gotbox, is_ok: boolean;
currentspeed: integer;
boxpointer: pointer;
boxsize: word;
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
     gd := EGA64;
     gm := EGA64Lo;
     initgraph(gd, gm, '.\BGI');
     gd := graphresult;
     state := 0;
     currentspeed := 500;
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

          main_x := 100;
          main_y := 100;

          setcolor(brown);
          rectangle(START_X, START_Y, END_X, END_Y);
          setfillstyle(solidfill, blue);
          floodfill(36, 36, brown);
          boxsize := imagesize(START_X, START_Y, END_X, END_Y);
          getmem(boxpointer, boxsize);
          getimage(START_X, START_Y, END_X, END_Y, boxpointer^);
          gotbox := true;
     end
     else
     begin
          putimage(START_X, START_Y, boxpointer^, 0);
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

          delay(ANIM_SPEED + currentspeed);
     end;
     {end of main loop}
     freemem(boxpointer, boxsize);
     stopsound;
     closegraph;
end.