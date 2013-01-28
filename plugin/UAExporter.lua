-- UAExporter.lua - export map as mysqldump for use in www.uga-agga.de
-- Copyright (c) 2004  Marcus Lunzenauer
--
-- This program is free software; you can redistribute it and/or    
-- modify it under the terms of the Affero General Public License as
-- published by Affero, Inc.; either version 1 of                   
-- the License, or (at your option) any later version.              

function main()
  local w     = mappy.getValue(mappy.MAPWIDTH)
  local h     = mappy.getValue(mappy.MAPHEIGHT)
  local count = 0
  local blk   = mappy.getValue(mappy.CURBLOCK)

  if (w == 0) then
    mappy.msgBox ("UA Exporter", "You need to load or create a map first", mappy.MMB_OK, mappy.MMB_ICONINFO)
    return
  end
  
  local isok,filename = mappy.fileRequester (".", "Textfile (*.txt)", "*.txt", mappy.MMB_SAVE)
  if isok ~= mappy.MMB_OK then
    return
  end
  
  if (not(string.sub(string.lower(filename), -4) == ".txt")) then
    filename = filename .. ".txt"
  end
  
  out = io.open(filename, "w")
  
  local dx,dy
  isok,dx,dy = mappy.doDialogue("UA Exporter", "Enter coordinates of the upper left corner", "0,0", mappy.MMB_DIALOGUE2)
  if isok ~= mappy.MMB_OK then
    return
  end
  dx = tonumber(dx)
  dy = tonumber(dy)
  
  out:write ("#MAPPY EXPORTER\n\n");
  local i, j
  local count = 1
  local maxRegions = 0
  for j = 0, h-1 do
    for i = 0, w-1 do
      if (mappy.getBlock(i, j, 2) > maxRegions) then
        maxRegions = mappy.getBlock(i, j, 2)
      end
      out:write("INSERT INTO `Cave` (`caveID`, `xCoord`, `yCoord`, `name`, `terrain`, `starting_position`, `regionID`) VALUES ("..
                count..", ".. (dx + i) ..", ".. (dy + j) ..", '"..
                (dx + i) .."x".. (dy + j).."', ".. (mappy.getBlock(i, j, 0)-1).. ", " .. mappy.getBlock(i, j, 1) .. ", " .. mappy.getBlock(i, j, 2) ..");\n")
      count = count + 1
    end
  end

  for i = 1, maxRegions do
    out:write("INSERT INTO `Regions` (`regionID`, `name`) VALUES (" .. i .. ", 'Region " .. i .. "');\n")
  end
  out:close()
end


test, errormsg = pcall( main )
if not test then
    mappy.msgBox("Error ...", errormsg, mappy.MMB_OK, mappy.MMB_ICONEXCLAMATION)
end
