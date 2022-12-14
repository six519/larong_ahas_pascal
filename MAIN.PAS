program main;

uses crt, graph, bgsound, dos;

const
MAX_WIDTH: integer = 640;
MAX_HEIGHT: integer = 200;
BOX_SIZE: integer = 10;
START_X: integer = 120;
START_Y: integer = 40;
END_X: integer = 640 - 120;
END_Y: integer = 200 - 40;
SCORE_X: integer = 123;
SCORE_Y: integer = 30;

var
ch: char;
main_x, main_y, parts_count, lowerx1, lowery1, lowerx2, lowery2, current_direction, faster, current_food : integer;
n, n2, n3, state, temp_x, temp_y : integer;
last_part_x, last_part_y, last_part_direction: integer;
titledraw, gotbox, is_ok: boolean;
currentspeed, score: integer;
boxpointer, bodypointer, blankpointer, foodpointer: pointer;
boxsize, bodysize, blanksize, foodsize: word;
parts_x, parts_y, parts_direction, temp_parts_x, temp_parts_y, temp_parts_direction: array[0..29] of integer; 
food_x, food_y: array[0..19] of integer;
score_string: string;

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

procedure playsoundeffect1;
begin
     getintvec($1c, int1csave);
     setintvec($1c, new1cint);
     startsound(@PhaserSound, 1, 1)
end;

procedure playsoundeffect2;
begin
     getintvec($1c, int1csave);
     setintvec($1c, new1cint);
     startsound(@WhistleSound, 1, 1)
end;

procedure stopsound;
begin
     setintvec($1c, int1csave);
     nosound;
end;

procedure gameover;
begin
end;

procedure init;
var gd, gm : integer;
begin
     gd := EGA;
     gm := EGALo;
     initgraph(gd, gm, '.\BGI');
     gd := graphresult;
     state := 0;
     currentspeed := 200;
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
     setactivepage(3);
     setvisualpage(3);
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
          setactivepage(0);
          score := 0;
          main_x := START_X;
          main_y := START_Y + 10;
          parts_count := 3;
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
               temp_x := random(((END_X - START_X - BOX_SIZE) div BOX_SIZE) - 1 + 1) + 1;
               temp_y := random(((END_Y - START_Y - BOX_SIZE) div BOX_SIZE) - 1 + 1) + 1;
               food_x[n] := (temp_x * BOX_SIZE) + START_X;
               food_y[n] := (temp_y * BOX_SIZE) + START_Y;
          end;

          {init blank area}
          blanksize := imagesize(SCORE_X, SCORE_Y, SCORE_X + 200, SCORE_Y + 200);
          getmem(blankpointer, blanksize);
          getimage(SCORE_X, SCORE_Y, SCORE_X + 200, SCORE_Y + 200, blankpointer^);

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

          { init food }
          temp_x := food_x[current_food];
          temp_y := food_y[current_food];
          setcolor(red);
          for n := 1 to BOX_SIZE do
          begin
               temp_x := food_x[current_food];
               for n2 := 1 to BOX_SIZE do
               begin

                    if (n2 = 1) or (n = 1) or (n = BOX_SIZE) or (n2 = BOX_SIZE) then 
                    putpixel(temp_x, temp_y, yellow) 
                    else 
                    putpixel(temp_x, temp_y, brown);

                    temp_x := temp_x + 1;
               end;
               temp_y := temp_y + 1;
          end;

          foodsize := imagesize(food_x[current_food],
          food_y[current_food], food_x[current_food] + BOX_SIZE, 
          food_y[current_food] + BOX_SIZE);
          getmem(foodpointer, foodsize);
          getimage(food_x[current_food],food_y[current_food], 
          food_x[current_food] + BOX_SIZE, 
          food_y[current_food] + BOX_SIZE, foodpointer^);

          { init parts }
          temp_x := main_x + START_X;
          temp_y := main_y + START_Y;

          for n := 0 to parts_count do
          begin
               parts_x[n] := temp_x;
               parts_y[n] := temp_y;
               parts_direction[n] := current_direction;
               temp_y := temp_y + BOX_SIZE;
          end;

          gotbox := true;
     end
     else
     begin
          is_ok := false;
          {start of double buffering}
          n2 := 1;

          for n := 0 to 1 do
          begin
               setvisualpage(n);
               setactivepage(n2);

               putimage(SCORE_X, SCORE_Y, blankpointer^, 0);

               setcolor(green);
               settextstyle(1, 0, 1);
               outtextxy(262, 15, 'Larong Ahas');

               setcolor(white);
               settextstyle(0, 0, 1);
               str(score, score_string);
               outtextxy(SCORE_X, SCORE_Y, 'Score: ' + score_string);

               putimage(START_X, START_Y, boxpointer^, 0); { always draw the box }

               putimage(food_x[current_food], food_y[current_food], foodpointer^, 0);

               for n3 := 0 to parts_count - 1 do
               begin
                    putimage(parts_x[n3], parts_y[n3], bodypointer^, 0);
                    playsoundeffect1;
               end;

               n2 := n2 - 1;
          end;          
          {end of double buffering}

           case current_direction of
               0:
               begin
                    main_y := main_y + BOX_SIZE;
               end;
               1:
               begin
                    main_x := main_x - BOX_SIZE;
               end;
               2:
               begin
                    main_y := main_y - BOX_SIZE;
               end;
               3:
               begin
                    main_x := main_x + BOX_SIZE;
               end;
           end;

          for n3 := 0 to parts_count - 1 do
          begin
               temp_parts_x[n3] := parts_x[n3];
               temp_parts_y[n3] := parts_y[n3];
               temp_parts_direction[n3] := parts_direction[n3];
          end;

          parts_x[0] := main_x + START_X;
          parts_y[0] := main_y + START_Y;
          parts_direction[0] := current_direction;

          for n3 := 0 to parts_count - 1 do
          begin
               parts_x[n3+1] := temp_parts_x[n3];
               parts_y[n3+1] := temp_parts_y[n3];
               parts_direction[n3+1] := temp_parts_direction[n3];
          end;

          if ((main_y + START_Y + BOX_SIZE) > START_Y) and 
          ((main_y + START_Y) < END_Y) and 
          ((main_x + START_X) < END_X) and ((main_x + START_X + BOX_SIZE) > START_X) then
          begin
               is_ok := true;

               { check collision with parts below }
               for n := 0 to parts_count - 1 do
               begin
               if n>2 then
               begin
                    lowerx1 := parts_x[n] + BOX_SIZE - 1;
                    lowery1 := parts_y[n] + BOX_SIZE - 1;
                    lowerx2 := parts_x[0] + BOX_SIZE - 1;
                    lowery2 := parts_y[0] + BOX_SIZE - 1;

                    if not ((lowerx1 < parts_x[0]) or (parts_x[n] > lowerx2) 
                    or (lowery1 < parts_y[0]) or (parts_y[n] > lowery2)) then
                    begin
                         is_ok := false;
                    end;
               end;
               end;

               { check collision with food }
               if is_ok then
               begin
                    lowerx1 := food_x[current_food] + BOX_SIZE - 1;
                    lowery1 := food_y[current_food] + BOX_SIZE - 1;
                    lowerx2 := parts_x[0] + BOX_SIZE - 1;
                    lowery2 := parts_y[0] + BOX_SIZE - 1;

                    if not((lowerx1 < parts_x[0]) or (food_x[current_food] > lowerx2) 
                    or (lowery1 < parts_y[0]) or (food_y[current_food] > lowery2)) then
                    begin

                         if current_food<>19 then
                         begin
                         current_food := current_food + 1;
                         last_part_x := parts_x[parts_count - 1];
                         last_part_y := parts_y[parts_count - 1];
                         last_part_direction := parts_direction[parts_count - 1];

                         case last_part_direction of
                         0:
                         begin
                         last_part_y := last_part_y + BOX_SIZE;
                         end;
                         1:
                         begin
                         last_part_x := last_part_x - BOX_SIZE;
                         end;
                         2:
                         begin
                         last_part_y := last_part_y - BOX_SIZE;
                         end;
                         3:
                         begin
                         last_part_x := last_part_x + BOX_SIZE;
                         end;
                         end;

                         parts_x[parts_count] := last_part_x;
                         parts_y[parts_count] := last_part_y;
                         parts_direction[parts_count] := last_part_direction;
                         parts_count := parts_count + 1;
                         stopsound;
                         playsoundeffect2;
                         score := score + 20;
                         currentspeed := currentspeed - 10;
                         end
                         else
                         begin
                         state := 3;
                         setactivepage(4);
                         playbgsound2;
                         setcolor(green);
                         settextstyle(0, 0, 5);
                         outtextxy(170, 80, 'YOU WIN');
                         setvisualpage(4);
                         end;
                    end;
               end;
          end;


          if not is_ok then
          begin
               setactivepage(4);
               state:=2;
               playbgsound2;
               setcolor(red);
               settextstyle(0, 0, 5);
               outtextxy(145, 80, 'GAME OVER');
               setvisualpage(4);
          end;
     end;

end;

begin
     randomize;
     playbgsound1;
     init;
     {main loop}
     while true do
     begin

          if keypressed then
          begin
               ch := readkey;

               if state=1 then
               begin
                    if ch='s' then
                    begin
                         if current_direction <> 2 then current_direction := 0;
                    end;

                    if ch='a' then
                    begin
                         if current_direction <> 3 then current_direction := 1;
                    end;

                    if ch='w' then
                    begin
                         if current_direction <> 0 then current_direction := 2;
                    end;

                    if ch='d' then
                    begin
                         if current_direction <> 1 then current_direction := 3;
                    end;
               end;

               if ch=#13 then
               begin
                    if state=0 then
                    begin
                         {cleardevice;}
                         {playbgsound2;}
                         state := 1;
                         stopsound;
                    end
                    else if (state=2) or (state=3) then
                    begin
                         cleardevice;
                         stopsound;
                         setactivepage(0);
                         cleardevice;
                         setactivepage(1);
                         cleardevice;
                         setvisualpage(0);
                         state := 0;
                         playbgsound1;
                         gotbox := false;
                         setvisualpage(3);
                    end;
               end;

               if ch=#27 then break;

               while keypressed do readkey; { flush keyboard buffer }
          end;

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
          2:
          begin
          gameover;
          end;
          end;

          delay(currentspeed);
     end;
     {end of main loop}
     freemem(boxpointer, boxsize);
     freemem(bodypointer, bodysize);
     freemem(blankpointer, blanksize);
     freemem(foodpointer, foodsize);
     stopsound;
     closegraph;
end.