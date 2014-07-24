--Test some simple math


--Declare a global variable.  (Any global variables will be available to the Lua machine in the external C#.)
--	The semicolon here doesn't actually do anything, but it might make you feel better.
nTestInt = 5;

--You can use semicolons to put multiple statements on one line
nTestInt = nTestInt + 1; nTestInt = nTestInt - 1

--Lua doesn't support combined assignment / arithmetic operators
--nTestInt += 3 --Syntax error

--nTestInt = 8
nTestInt = nTestInt + 3

--nTestInt = 4
--(Exactly equals 4 even though all Lua numerics are doubles.  But this is dangerous if you expect nTestInt to be an int since non-even divisors will make it a "non-whole number")
nTestInt = nTestInt / 2



--We can now get the value of nTestInt (4) from the Lua object in the external code.