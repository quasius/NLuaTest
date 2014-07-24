using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using NLua;

namespace LuaDemo
{
	class InstancedClass
	{
		public int IntMember { get; set; }

		public double DoubleMember { get; set; }

		public string StringMember { get; set; }

		public Dictionary<string, string> DictionaryMember { get; set; }


		//Default constructor
		public InstancedClass()
		{
			IntMember = 0;
			DoubleMember = 0.0;
			StringMember = "";
			DictionaryMember = null;
		}

		//Fully-specified constructor
		public InstancedClass(int nIntMember, double dDoubleMember, string sStringMember)
		{
			IntMember = nIntMember;
			DoubleMember = dDoubleMember;
			StringMember = sStringMember;
		}

		//Construct from LuaTable.  (This is how we will re-construct a C# InstacedClass from the equivilent Lua table)
		public InstancedClass(LuaTable luaTable)
		{
			//Since Lua tables are hashes, the LuaTable C# object is just a bunch of key-value pairs which we must read as strings and parse.
			IntMember = int.Parse(luaTable["IntMember"].ToString());
			DoubleMember = double.Parse(luaTable["DoubleMember"].ToString());
			StringMember = luaTable["StringMember"].ToString();

			LuaTable dictionaryMemberTable = (LuaTable)luaTable["DictionaryMember"];
			if (dictionaryMemberTable != null)
			{
				DictionaryMember = new Dictionary<string, string>();
				IDictionaryEnumerator iter = dictionaryMemberTable.GetEnumerator();
				while (iter.MoveNext())
				{
					DictionaryMember[(string)iter.Entry.Key] = (string)iter.Entry.Value;
				}
			}
		}


		//A simple, non-rigorous factorial method
		public int Factorial(int n)
		{
			if (n <= 1)
				return 1;

			return n * Factorial(n - 1);
		}

		//Outputs this InstancedClass to the console
		public void Print()
		{
			Console.WriteLine("IntMember = " + IntMember);
			Console.WriteLine("DoubleMember = " + DoubleMember);
			Console.WriteLine("StringMember = " + StringMember);

			if (DictionaryMember != null)
			{
				Console.WriteLine("DictionaryMember = ... ");
				foreach (KeyValuePair<string, string> entry in DictionaryMember)
				{
					Console.WriteLine("[" + entry.Key + ", " + entry.Value + "]");
				}
			}
		}
	}
}
