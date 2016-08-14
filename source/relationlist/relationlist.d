/**
 * Authors: Dan Printzell
 * License: BSD 2-clause
 */

module relationlist.relationlist;

public import relationlist.relationentry;

import std.algorithm;
import std.array;

/**
 * The class for the list
 */
class RelationList(V) {
public:
	alias Entry = RelationEntry!V;
	
	/**
	 * Create a new empty list
	 */
	this() {
		counter = 0;
	}
	
	/**
	 * Creates a new list based on another list
	 */
	this(V[] list) {
		counter = 0;
		foreach(V a; list)
			Add(a);
	}
	~this() {
		destroy(values);
	}
	
	/**
	 * Adds a entry to the list
	 * Returns: The entry
	 */
	ref Entry Add(V value) {
		return Add(new Entry(this, 0 /* Will be replaced in the other Add function */, value));
	}
	
	/**
	 * Adds a entry to the list
	 * Returns: The entry
	 */
	ref Entry Add(Entry value) {
		value.ID = counter++;
		values ~= value;
		return values[values.length-1];
	}
	
	/**
	 * Gets a entry at a location
	 * Returns: The entry
	 */
	ref Entry Get(size_t i) {
		return values[i];
	}
	
	/**
	 * Returns: All the entries
	 */
	@property ref Entry[] Values() { return values; }
	
	/**
	 * Returns: The length
	 */
	@property size_t Length() { return values.length; }
	
	ref Entry opOpAssign(op)(V value) if (op == "~") {
		return add(value);
	}
	
	ref Entry opOpAssign(op)(Entry value) if (op == "~") {
		return add(value);
	}
	
	Entry[] opIndex(){
		return values[];
	}
	
	ref Entry opIndex(size_t i) {
		return values[i];
	}
	
	int opDollar(size_t pos)() {
		return values.length;
	}
	
	ref Entry[] opSlice() {
		return values;
	}
	
	Entry[] opSlice(size_t i, size_t j) {
		Entry[] ret;
		for(; i < j; i++)
			ret ~= values[i];
		return ret;
	}
private:
	Entry[] values;
	size_t counter;
}

unittest {
	import std.stdio;
	import std.math;
	import std.process;
	import std.exception;
	
	RelationList!char mylist = new RelationList!char();
	auto a = mylist.Add('a');
	auto b = mylist.Add('b');
	auto c = mylist.Add('c');
	auto d = mylist.Add('d');
	auto e = mylist.Add('e');
	auto f = mylist.Add('f');
	
	a.AddChild(b);
	b.AddChild(c).AddChild(d);
	d.AddChild(e);
	
	e.AddChild(f);
	f.AddChild(e);
	
	c.AddChild(f);
	
	writeln(a.GetParents());
	writeln(b.GetParents());
	writeln(c.GetParents());
	writeln(d.GetParents());
	writeln(e.GetParents());
	writeln(f.GetParents());
	
	enforce(a.GetParents() == []);
	enforce(b.GetParents() == [a]);
	enforce(c.GetParents() == [b]);
	enforce(d.GetParents() == [b]);
	enforce(e.GetParents() == [d, f]);
	enforce(f.GetParents() == [c, e]);
	
	version(PRINT_DOT_GRAPH) {
		File fp = File("test.dot", "w");
		fp.writefln("digraph test {");
		fp.writefln("\tfontname=\"Tewi\";");
		foreach(entry; mylist) {
			fp.writefln("\tL_%s [label=\"%s\"];", entry.ID, entry.Value);
			foreach(parent; entry.GetParents())
				fp.writefln("\tL_%s -> L_%s;", parent.ID, entry.ID);
		}
		fp.writefln("}");
		fp.close();
		executeShell("dot -Tpng -o test.png test.dot; firefox test.png");
	}
}
