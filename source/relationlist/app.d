module relationlist.relationlist;

import std.algorithm;
import std.array;
import std.stdio;

class RelationEntry(V) {
public:
	alias Entry = RelationEntry!V;
	this(RelationList!V owner, ulong id, V value) {
		this.id = id;
		this.value = value;
		this.owner = owner;
	}

	Entry[] GetParrents() {
		Entry[] ret;
		foreach(Entry entry; owner)
			if (entry.GotChild(this))
				ret ~= entry;
		return ret;
	}

	@property ulong ID() { return id; }
	@property ref V Value() { return value; }

	V opCast(V_)() {
		static assert(V is V_);
		return value;
	}

	Entry * AddChild(ref Entry child) {
		return AddChild(&child);
	}

	Entry * AddChild(Entry * child) {
		children ~= child;
		return &this;
	}

	bool GotChild(Entry entry) {
		foreach(child; children)
			if (child.ID == entry.ID)
				return true;
		return false;
	}

	override string toString() {
		import std.string : format;
		return format("[ID: '%d', Value: '%s']", id, value);
	}

private:
	ulong id;
	V value;
	RelationList!(V) owner;
	Entry *[] children;
}

class RelationList(V) {
public:
	alias Entry = RelationEntry!V;

	this() {
		counter = 0;
	}
	this(V[] list) {
		counter = 0;
		foreach(V a; list)
			Add(a);
	}
	~this() {
		destroy(values);
	}

	ref Entry Add(V value) {
		return Add(new Entry(this, counter++, value));
	}

	ref Entry Add(Entry value) {
		values ~= value;
		return values[values.length-1];
	}

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

	ref Entry Get(ulong i) {
		return values[i];
	}

	@property ref Entry[] Values() { return values; }
	@property V[] CoreValues() {
		V[] ret;
		foreach (val; values)
			ret ~= val.Value;
		return ret;
	}
	@property ulong Length() { return values.length; }

private:
	Entry[] values;
	ulong counter;
}

unittest {
	import std.exception;
	import std.math;
	import std.process;
	alias lt = RelationList!int;
	alias et = lt.Entry;
	lt mylist = new lt();
	for (int i = 0; i < 128; i++)
		mylist.Add(i);

	for (int mul = 0; mul < 2; mul++) {
		for (int i = 0; i < mylist.Length; i++) {
			int x = abs((i*5+i/3-i*2+i*mul+mul));
			int y = abs((i*10+i/2-i*2*mul+mul));
			x %= mylist.Length;
			y %= mylist.Length;

			if (x == y) {
				x += 1;
				x %= mylist.Length;
			}

			mylist[x].AddChild(&mylist[y]);
		}
	}

	File f = File("test.dot", "w");
	f.writefln("digraph test {");
	f.writefln("\tfontname=\"Tewi\";");
	foreach(et entry; mylist) {
		f.writefln("\tL_%s [label=\"%s\"];", entry.ID, entry.Value);
		foreach(et parrent; entry.GetParrents())
			f.writefln("\tL_%s -> L_%s;", parrent.ID, entry.ID);
	}
	f.writefln("}");
	f.close();
	executeShell("dot -Tpng -o test.png test.dot; firefox test.png");
}
