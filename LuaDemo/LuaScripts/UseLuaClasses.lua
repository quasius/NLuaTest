--We use "require" to include other Lua files (like classes we want to use).
--Some guides might tell you to use "include," but "require" is always better since it only runs the script if it hasn't already been required somewhere else
--Note that we don't include the .lua in the file (causes an error) and use the . for directory changes.  You can use slashes, but the . is more cross-platform.
require "Math.Vec2D"


--This would be an error since we've now locked the global namespace!  (We ran LockGlobalNamespace.lua from the C# code.)
--vec1 = Vec2D.New(3.0, 5.0)

--All variables we don't intend to pass back to C# should now be local.
local vec1 = Vec2D.New(3.0, 5.0)
local vec2 = Vec2D.New(-2.5, 1.0)

--Lua supports overloading of a small set of operators (+, -, *, /, negation, ==, toString, and concatination)  They have all been overloaded in the Vec2D class.
local vec3 = vec1 + vec2


--Calling an external function with a LuaTable argument.
local vec4 = Vec2D.New(-1.0, 1.0)
Vec2D_CS:Print_Lua(vec4)



--Let's pass the result back to C#
--In DEBUG, the global namespace is locked, so we must explicetly call DeclareGlobal.  In release, we can just set the global.
--Yes, this is a bit more typing sometimes, but local / global name collision bugs can be very nasty and this practice stops them cold.
if DEBUG then
	DeclareGlobal("outVec", vec3)
else
	outVec = vec3
end


