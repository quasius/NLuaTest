consoleOut("Hello custom function world")

local dPi = "3.14159265"

consoleOut("For dessert, I had some " .. dPi)



--Prints the passed string to the console and returns true.  Returns false if sLine is nil
function PrintFromLua(sLine)
	if sLine == nil then
		return false
	end
		
	consoleOut(sLine)
	
	return true
end
