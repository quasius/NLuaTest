using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using NLua;
using System.IO;
using System.Timers;

namespace LuaDemo
{
	class Program
	{
		static void Main(string[] args)
		{
			//CREATE THE LUA MACHINE
			Lua lua = new Lua();

			//We can directly run lua script from code.  Here were are setting a global variable named "testNum"
			lua.DoString("testNum = 25");

			//It's our responsibility to know what kind of variable we are expecting here.
			//All Lua numeric values are doubles and must be cast as such to avoid an error.
			double dTestNum = (double)lua["testNum"];
			Console.WriteLine("dTestNum = " + dTestNum);
			Console.WriteLine("\n");




			//RUN A SIMPLE SCRIPT THAT CALCULATES AND SETS A VARIABLE NAMED nTestInt
			string luaFilePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"../../LuaScripts/SimpleScript.lua");
			bool bLuaFileOk = true;
			try
			{
				lua.DoFile(luaFilePath);
			}
			//Exceptions are usually either the file couldn't be found or there was a Lua syntax error.
			catch (Exception ex)
			{
				Console.WriteLine(ex.Message);
				bLuaFileOk = false;
			}


			//It's our responsibility to know what kind of variable we are expecting here.
			//All Lua numeric values are doubles and must be cast as such to avoid an error.
			//	If we know the lua variable is an "int" as in this case, we can cast it back.
			if (bLuaFileOk)
			{
				//Even though all Lua numeric types are doubles and must be read as such,
				//	since we know this is a whole-number, we can immediately cast it to an int.
				int nTestInt = (int)((double)lua["nTestInt"]);
				Console.WriteLine("nTestInt = " + nTestInt);
			}
			Console.WriteLine("\n");




			//REGISTER A CUSTOM FUNCTION AND RUN A SCRIPT USING IT

			//Since all Lua custom functions must be on an object instance, make an instance of the Program class we're in and get the PrintYelloString method
			Program program = new Program();
			lua.RegisterFunction("consoleOut", program, program.GetType().GetMethod("PrintYellowString"));


			luaFilePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"../../LuaScripts/RegisterFunction.lua");
			try
			{
				lua.DoFile(luaFilePath);
			}
			catch (Exception ex)
			{
				Console.WriteLine(ex.Message);
			}


			//Register a function to the C# side from Lua that simply calls consoleOut on the passed string
			LuaFunction fpPrintFromLua = lua["PrintFromLua"] as LuaFunction;
			if (fpPrintFromLua != null)
			{
				object[] returnValues = fpPrintFromLua.Call("A message from C# to Lua and back to C#");
				bool bResult = (bool)returnValues[0];
			}

			//Visual break
			Console.WriteLine("\n");




			//ACCESS AN INSTANCED CLASS WITHIN LUA

			//Create a class instance and set some values
			InstancedClass instancedClass = new InstancedClass();
			instancedClass.IntMember = 5;
			instancedClass.StringMember = "stringMember";

			instancedClass.DictionaryMember = new Dictionary<string, string>();
			instancedClass.DictionaryMember["key1"] = "value1";
			instancedClass.DictionaryMember["key2"] = "value2";


			//We now assign the class instance as a global variable in the Lua machine so scripts can access it.
			lua["InstancedClass"] = instancedClass;
			

			//We can have multiple instaces of the same class...
			InstancedClass instancedClass2 = new InstancedClass();
			lua["InstancedClass2"] = instancedClass2;

			luaFilePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"../../LuaScripts/AccessInstancedClass.lua");
			try
			{
				lua.DoFile(luaFilePath);
			}
			catch (Exception ex)
			{
				Console.WriteLine(ex.Message);
			}

			//Output the changes the Lua script made to instancedClass2
			Console.WriteLine("instancedClass.StringMember is now \"" + instancedClass.StringMember + "\"");
			Console.WriteLine("instancedClass2.StringMember is now \"" + instancedClass2.StringMember + "\"");


			//Output the entirely new instancedClass3 object the Lua script made
			InstancedClass instancedClass3 = new InstancedClass((LuaTable)lua["InstancedClass3"]);
			Console.WriteLine("instancedClass3 = ");
			instancedClass3.Print();


			instancedClass.IntMember = 6;
			lua.DoString("PrintIntMember()");


			LuaFunction fpPrintInstancedClass = lua["PrintPassedInstancedClass"] as LuaFunction;
			if (fpPrintInstancedClass != null)
			{
				InstancedClass instancedClass4 = new InstancedClass(4, 4.4, "four");
				fpPrintInstancedClass.Call(instancedClass4);
			}


			LuaFunction fpGetInstancedClassTable = lua["GetInstancedClassTable"] as LuaFunction;
			if (fpGetInstancedClassTable != null)
			{
				object[] returnValues = fpGetInstancedClassTable.Call();
				InstancedClass instancedClass4 = new InstancedClass((LuaTable)returnValues[0]);
				Console.WriteLine("instancedClass4 = ");
				instancedClass4.Print();
			}


			LuaFunction fpGetInstancedClassTables = lua["GetInstancedClassTables"] as LuaFunction;
			if (fpGetInstancedClassTables != null)
			{
				object[] returnValues = fpGetInstancedClassTables.Call();
				LuaTable instancedClassesTable = (LuaTable)returnValues[0];

				IDictionaryEnumerator instancedClassesEnumerator = instancedClassesTable.GetEnumerator();
				while (instancedClassesEnumerator.MoveNext())
				{
					LuaTable instancedClassTable = (LuaTable)instancedClassesEnumerator.Value;
					InstancedClass currentInstancedClass = new InstancedClass(instancedClassTable);
					currentInstancedClass.Print();
				}
			}

			//Visual break
			Console.WriteLine("\n");


			//USING LUA CLASSES

			//Since this last script uses custom-defined metatable "classes," we need to put some protections in place
			//These would normally happen right after the Lua object is created,
			//	but it would have broken the previous scripts where we were being less careful.
			string sPackagePath = (string)lua["package.path"];

			//Before we can use Lua scripts that require (include) other scripts, we must add out scripts path the the Lua instance
			string sLuaScriptsPath = Path.GetFullPath(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"../../LuaScripts/"));

			//Replace the escaped \ with 2 escaped \'s since when we send this string to Lua, it will re-escape back to a single \
			sLuaScriptsPath = sLuaScriptsPath.Replace("\\", "\\\\");

			//This looks a bit cryptic with all the escaped characters, but recall that the Lua concatination operator is ".."
			//	Basically, we're adding a new pattern to the end of package.path with already contains many search patters where it
			//	looks for files.  Each pattern is separated by a semicolon which we add.  Then we add the double-escaped path
			//	(which will be correctly singly-escaped after being parsed by Lua).  The final part is a ? which symbolizes
			//	whatever specified relative file path we're looking for with the .lua extension added on.
			//
			//	...Alternately, just copy + paste this magic code to add our LuaScripts folder to the search path.
			string sLuaCommand = "package.path = package.path .. \";" + sLuaScriptsPath + "?.lua\"";
			lua.DoString(sLuaCommand);

			

			//Lock the Lua global namespace in Debug mode.  (See comments at top of LockGlobalNamespace.lua for more info.)
#if DEBUG
			//Also set a global variable in Lua indicating we are in debug mode.
			//(This is not a Lua language requirement, but something for our use)
			//(Note that this must be done before locking the global namespace, since DEBUG is a global variable here.)
			lua.DoString("DEBUG = true");

			luaFilePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"../../LuaScripts/Utils/LockGlobalNamespace.lua");
			try
			{
				lua.DoFile(luaFilePath);
			}
			catch (Exception ex)
			{
				Console.WriteLine(ex.Message);
			}
#else
			lua.DoString("DEBUG = false");
#endif


			//We must now declare new Lua variables like this
			Vec2D vec2D = new Vec2D();
#if DEBUG
			lua.DoString("SuspendGlobalIndexLock()");
			lua["Vec2D_CS"] = vec2D;
			lua.DoString("RestoreGlobalIndexLock()");
#else
			lua["Vec2D_CS"] = vec2D;
#endif


			luaFilePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"..\..\LuaScripts\UseLuaClasses.lua");
			try
			{
				lua.DoFile(luaFilePath);
			}
			catch (Exception ex)
			{
				Console.WriteLine(ex.Message);
			}

			//Print the outVec the script made
			Console.WriteLine("outVec = " + new Vec2D((LuaTable)lua["outVec"]));


			Console.ReadLine();
		}

		

		//Outputs the passed string as a line to the console in yellow.
		public void PrintYellowString(string sLine)
		{
			Console.ForegroundColor = ConsoleColor.Yellow;
			Console.WriteLine(sLine);
			Console.ResetColor();
		}
	}
}
