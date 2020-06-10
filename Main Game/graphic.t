procedure drawcircle (x,y,radius,colour:int)
   drawoval (x,y,radius,radius,colour)           
end drawcircle
    
procedure drawball (x,y,radius,colour:int)
   drawfilloval (x,y,radius,radius,colour)           
end drawball

procedure drawtriangle (x1,y1,x2,y2,x3,y3,colour:int)
   var x : array 1..3 of int
   var y : array 1..3 of int

   x(1):=x1
   x(2):=x2
   x(3):=x3

   y(1):=y1
   y(2):=y2
   y(3):=y3

   drawfillpolygon (x,y,3,colour)           
end drawtriangle

procedure drawquad (x1,y1,x2,y2,x3,y3,x4,y4,colour:int)
   var x : array 1..4 of int
   var y : array 1..4 of int

   x(1):=x1
   x(2):=x2
   x(3):=x3
   x(4):=x4

   y(1):=y1
   y(2):=y2
   y(3):=y3
   y(4):=y4

   drawfillpolygon (x,y,4,colour)           
end drawquad    

procedure background (colour:int)
   drawquad (0,0,maxx,0,maxx,maxy,0,maxy,colour)   
end background

procedure drawstring (name:string,x,y,colour:int)
   Draw.Text (name,x,y,defFontID,colour)
end drawstring

   
