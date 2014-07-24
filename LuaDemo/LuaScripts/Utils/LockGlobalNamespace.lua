--This script locks down the global namespace so that new globals can only explicetly be declared by calling DeclareGlobal(name, value)
--All other variables must be local
--This prevents insideous bugs where local and global names collide and get confused and/or overwrite each other.
--Also, global variables are slower to access than local variables.
--In general, the only time you need a global is when writing an object you want to be visible from the C# side of if you're declaring a new Lua class / metatable
--However, locking the global namespace like this incurs a performance penalty everytime a variable is declared, so this script should only be run in debug mode.
--Finally, if needed global locking can be suspended / restored with SuspendGlobalIndexLock / RestoreGlobalIndexLock, which is needed when requiring (including) 3rd party Lua libraries




--Lock down the global namespace so new global vars (generally should only be classes) can only be declared explicetly via DeclareGlobal
--This prevents accidental global name-collision bugs
local declaredGlobalNames = {}

function DeclareGlobal(name, value)
	rawset(_G, name, value)
	declaredGlobalNames[name] = true
end

function GlobalNewIndex(environment, name, value)
	if not declaredGlobalNames[name] and name ~= "tableDict" then
		error("attempt to write to undeclared global var " ..name, 2)
	else
		rawset(environment, name, value)   -- do the actual set
	end
end

function GlobalIndex(_, name)
	if not declaredGlobalNames[name] and name ~= "tableDict" then
		error("attempt to read undeclared globar var " ..name, 2)
	else
		return nil
	end
end


--Temporarilly suspends the global namespace index lock.  (Needed when requiring external files that raw-declare globals.)
function SuspendGlobalIndexLock()
	setmetatable(_G, {__newindex = nil, __index = nil})
end

--Restores the normal global namespace index lock.  Call after SuspendGlobalIndexLock is no longer needed
function RestoreGlobalIndexLock()
	setmetatable(_G, {__newindex = GlobalNewIndex, __index = GlobalIndex})
end


--Direct global indexing to the "locking" functions
setmetatable(_G, {__newindex = GlobalNewIndex, __index = GlobalIndex})
