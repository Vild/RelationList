/**
 * Authors: Dan Printzell
 * License: BSD 2-clause
 */

module relationlist.relationlist;

import std.algorithm;
import std.array;


/**
 * The container class for the entries
 */
class RelationEntry(V) {
public:
	alias Entry = RelationEntry!V;
	/**
	 * Creates a new entry object.
	 * Should only be used for power users.
	 * This is automatically done in the list.
	 */
	this(RelationList!V owner, ulong id, V value) {
		this.id = id;
		this.value = value;
		this.owner = owner;
	}

	/**
	 * Adds a child to the entry
	 * Returns: The child you added.
	 */
	Entry * AddChild(ref Entry child) {
		return AddChild(&child);
	}
	
	/**
	 * Gets all the parents for the list entry
	 * Returns: The list of parents
	 */
	Entry * AddChild(Entry * child) {
		children ~= child;
		return &this;
	}

	/**
	 * Gets all the parents for the list entry.
	 * Returns: The list of parents.
	 */
	Entry[] GetParents() {
		Entry[] ret;
		foreach(Entry entry; owner)
			if (entry.GotChild(this))
				ret ~= entry;
		return ret;
	}

	/**
	 * Checks if this entry got a specific child.
	 * Returns: True if it got the child.
	 */
	bool GotChild(Entry entry) {
		foreach(child; children)
			if (child.ID == entry.ID)
				return true;
		return false;
	}

	@property ulong ID() { return id; }
	@property ref V Value() { return value; }

	override string toString() {
		import std.string : format;
		return format("[ID: '%d', Value: '%s']", id, value);
	}

	V opCast(V_)() {
		static assert(V is V_);
		return value;
	}
private:
	ulong id;
	V value;
	RelationList!(V) owner;
	Entry *[] children;
}

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
		return Add(new Entry(this, counter++, value));
	}

	/**
	 * Adds a entry to the list
	 * Returns: The entry
	 */
	ref Entry Add(Entry value) {
		values ~= value;
		return values[values.length-1];
	}

	/**
	 * Gets a entry at a location
	 * Returns: The entry
	 */
	ref Entry Get(ulong i) {
		return values[i];
	}

	/**
	 * Returns: All the entries
	 */
	@property ref Entry[] Values() { return values; }

	/**
	 * Returns: All the values of the entries
	 */
	@property V[] CoreValues() {
		V[] ret;
		foreach (val; values)
			ret ~= val.Value;
		return ret;
	}

	/**
	 * Returns: The length
	 */
	@property ulong Length() { return values.length; }

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
private:
	Entry[] values;
	ulong counter;
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
