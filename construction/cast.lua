function cast(segmentLen,yOffset,iterations)
--Creates a lava cast by moving up yOffset blocks, placing a wall of lava
--segmentLen blocks long, covering it in water, and then repeating this process
--iterations times. Assumes a lava bucket in slot 2 and a water bucket in slot 1.

--segmentLen = 30

--iterations = 3
--yOffset = 30

for i = 1,iterations,1 do
    turtle.select(2)
    
    --We get into position
    for j = 1, yOffset, 1 do
        turtle.up()
    end

    --We prime the wall
    turtle.place()
    os.sleep(7)
    turtle.place()
    turtle.forward()
    
    --The rest of the wall can be built more quickly
    for j = 2, segmentLen, 1 do
    
        turtle.place()
        os.sleep(2)
        turtle.place()
    
        turtle.forward()
    end    
    
    --We pour water all over the most recent segment
    turtle.up()
    turtle.up()
    turtle.select(1)
    turtle.place()
    os.sleep(2)
    turtle.place()
    turtle.down()
    turtle.down()
    
    --We turn around and prepare to make the next segment
    turtle.turnLeft()
    turtle.turnLeft()
    
end


end