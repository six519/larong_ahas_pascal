program main;

uses crt, graph, bgsound, dos;

const
MAX_WIDTH: integer = 640;
MAX_HEIGHT: integer = 200;
BOX_SIZE: integer = 5;
ANIM_SPEED: integer = 1000;

var
ch: char;
state: integer;

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

     if gd <> grok then
     begin
          writeln('Unable to initialize graphic card.');
          halt;
     end;
end;

procedure title;
var 
currentx, currenty, currentx2, currenty2, n1, n2, tempx, tempy: integer;
other: boolean;
begin
     currentx := 0;
     currentx2 := 0;
     currenty := 0;
     currenty2 := 0;
     other := false;

     setcolor(lightcyan);
     for n1 := 1 to 5 do
     begin
          tempy := currenty + 40;

          if n1=5 then
          begin
               tempy := tempy - 1;
          end;

          for n2 := 1 to 16 do
          begin
               tempx := currentx + 40;

               if n2=16 then
               begin
                    tempx := tempx - 1;
               end;

               rectangle(currentx, currenty, tempx, tempy);
               currentx := tempx;
          end;
          currentx := 0;
          currenty := tempy;
     end;

end;

begin
     init;
     playbgsound1;
     {main loop}
     while true do
     begin

           cleardevice;

           case state of
               0:
               begin
               { title }
               title;
               end;
               1:
               begin
               { main game }
               end;
           end;

          if keypressed then
          begin
               ch := readkey;

               if ord(ch)=27 then break;
          end;

          delay(ANIM_SPEED);
     end;
     {end of main loop}
     stopsound;
     closegraph;
end.