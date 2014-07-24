//A very simple class representing a 2D vector of doubles

using System;

using NLua;

namespace LuaDemo
{
	class Vec2D
	{
		public double x { get; set; }
		public double y { get; set; }


		//Default constructor
		public Vec2D()
		{
			x = 0.0;
			y = 0.0;
		}

		//Fully-specified constructor
		public Vec2D(double x, double y)
		{
			this.x = x;
			this.y = y;
		}

		//Construct from LuaTable.  (This is how we will re-construct a C# InstacedClass from the equivilent Lua table)
		public Vec2D(LuaTable luaTable)
		{
			//Since Lua tables are hashes, the LuaTable C# object is just a bunch of key-value pairs which we must read as strings and parse.
			x = double.Parse(luaTable["x"].ToString());
			y = double.Parse(luaTable["y"].ToString());
		}


		//ToString method
		public override string ToString()
		{
			return string.Format("({0}, {1})", x, y);
		}


		//Prints the passed Vec2D as a LuaTable to the console
		public void Print_Lua(LuaTable vec2D_Lua)
		{
			Console.WriteLine(new Vec2D(vec2D_Lua));
		}



		//Implicit conversion from luaTable to Vec2D.
		//	(This is necessary to call the Print method below from Lua)
		//UPDATE- This doesn't actually work due to the way NLua checks arguments.  Use hacky Print_Lua instead
		public static implicit operator Vec2D(LuaTable luaTable)  // implicit digit to byte conversion operator
		{
			double x = double.Parse(luaTable["x"].ToString());
			double y = double.Parse(luaTable["y"].ToString());
			return new Vec2D(x, y);
		}

		//Prints this Vec2D to the console
		public void Print(Vec2D ved2D)
		{
			Console.WriteLine("PRINT (" + ved2D.x + ", " + ved2D.y + ")");
		}
	}
}
