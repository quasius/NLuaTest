--In Lua, all objects are "tables" (hash tables).  So the C# InstancedClass object is seen as a table in Lua.  We can access members of a Lua table with the . operator
consoleOut("Accessing InstancedClass...")
consoleOut("InstancedClass.IntMember = " .. InstancedClass.IntMember)


consoleOut("\nDictionary test:")

local e = InstancedClass.DictionaryMember:GetEnumerator()
while e:MoveNext() do
	consoleOut("[" .. e.Current.key .. ", " .. e.Current.value .. "]")
end

consoleOut("InstancedClass.DictionaryMember.key1 = " .. InstancedClass.DictionaryMember.key1)
consoleOut("InstancedClass.DictionaryMember.key2 = " .. InstancedClass.DictionaryMember.key2 .. "\n")


--Reading or writing works the same way
InstancedClass.DoubleMember = 2.7182818
consoleOut("Set InstancedClass.DoubleMember to " .. InstancedClass.DoubleMember)
InstancedClass.StringMember = "lua wuz here"

--Remember we assigned 2 different instances of InstancedClass back in the C#?
InstancedClass2.StringMember = "lua wuz here 2"


--But to call a tabled "methods," we use the : operator instead.
consoleOut("5! = " .. InstancedClass:Factorial(5))

--This works too, but is messier than the : operator.
--	(To understand exactly what's going on here requires understanding how Lua deals with tables, metatables, and function calls.
--	But that doesn't really matter unless you want to use Lua as an full object-oriented language.  For now, just use . to access object properties and : to call object methods.)
consoleOut("7! = " .. InstancedClass.Factorial(InstancedClass, 7))



--Since the C# object are just Lua tables, there's nothing stopping us from making our own...
--	(The more rigorous way to do this would be to actually have a Lua "class" (metatable) defined that guaranteed the expected members.
--	But again, that gets a bit past simple Lua scripting and more into OOP Lua.  If something like this is needed, Curtis can construct the metatable.)
InstancedClass3 = {}
InstancedClass3.IntMember = 1
InstancedClass3.DoubleMember = 2.0
InstancedClass3.StringMember = "three"

--We should now be able to access InstancedClass3 externally in C#




--Prints InstancedClass.IntMember
function PrintIntMember()
	consoleOut("PrintIntMember InstancedClass.IntMember = " .. InstancedClass.IntMember)
end


--Prints out the passed InstancedClass
function PrintPassedInstancedClass(pInstancedClass)
	consoleOut("IntMember = " .. pInstancedClass.IntMember .. ", DoubleMember = " .. pInstancedClass.DoubleMember .. ", StringMember = " .. pInstancedClass.StringMember)
end


--Returns a Lua table representing an InstancedClass object
function GetInstancedClassTable()
	local InstancedClass4 = {}
	InstancedClass4.IntMember = 10
	InstancedClass4.DoubleMember = 20.0
	InstancedClass4.StringMember = "thirty"
	
	InstancedClass4.DictionaryMember = {}
	InstancedClass4.DictionaryMember.keyFoo = "valueFoo"
	InstancedClass4.DictionaryMember.keyBar = "valueBar"

	
	return InstancedClass4
end




--Returns a Lua table representing an InstancedClass object
function GetInstancedClassTables()
	local InstancedClasses = {}
	
	InstancedClasses[1] = {}
	InstancedClasses[1].IntMember = 2
	InstancedClasses[1].DoubleMember = 2.2
	InstancedClasses[1].StringMember = "two"

	InstancedClasses[2] = {}
	InstancedClasses[2].IntMember = 4
	InstancedClasses[2].DoubleMember = 4.4
	InstancedClasses[2].StringMember = "four"

	InstancedClasses[3] = {}
	InstancedClasses[3].IntMember = 8
	InstancedClasses[3].DoubleMember = 8.8
	InstancedClasses[3].StringMember = "eight"

	
	return InstancedClasses
end