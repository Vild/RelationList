import std.stdio;
import std.algorithm;
import std.exception;
import std.array;

class RelationEntry(V) {
public:
	this(RelationList!V owner, ulong id, V value) {
		this.id = id;
		this.value = value;
		this.owner = owner;
	}

	RelationEntry!(V)[] GetParrents() {
		return find!("a.GotChild(b)")(owner.List, this);
	}

	@property ulong ID() { return id; }
	@property ref V Value() { return value; }

	V opCast(V_)() {
		static assert(V is V_);
		return value;
	}

	RelationEntry!(V) * AddChild(ref RelationEntry!V child) {
		children ~= &child;
		return &this;
	}

	bool GotChild(RelationEntry!V entry) {
		return !find!("a.ID == b")(children, entry.ID).empty;
	}

	override string toString() {
		import std.string:format;
		return format("ID: %d Value: %s", id, value);
	}

private:
	ulong id;
	V value;
	RelationList!(V) owner;
	RelationEntry!(V) *[] children;
}

class RelationList(V) {
public:
	this() {
		counter = 0;
	}
	this(V[] list) {
		counter = 0;
		foreach(V a; list)
			add(a);
	}
	~this() {
		destroy(list);
	}

	RelationEntry!V add(V value) {
		RelationEntry!V entry = new RelationEntry!V(this, counter++, value);
		list ~= entry;
		return entry;
	}

	RelationEntry!V add(RelationEntry!V value) {
		list ~= value;
		return value;
	}

	RelationEntry!V opOpAssign(op)(V value) if (op == "~") {
		return add(value);
	}

	RelationEntry!V opOpAssign(op)(RelationEntry!V value) if (op == "~") {
		return add(value);
	}

	@property ref RelationEntry!(V)[] List() { return list; }

private:
	RelationEntry!(V)[] list;
	ulong counter;
}

void main() {
	alias lt = RelationList!char;
	alias et = RelationEntry!char;
	lt mylist = new lt();
	et a = mylist.add('a');
	et b = mylist.add('b');
	et c = mylist.add('c');
	et d = mylist.add('d');

	a.AddChild(b);
	b.AddChild(c).AddChild(d);

	writeln(a.GetParrents());
	writeln(b.GetParrents());
	writeln(c.GetParrents());
	writeln(d.GetParrents());

	enforce(a.GetParrents() == []);
	enforce(b.GetParrents() == [a]);
	enforce(c.GetParrents() == [b]);
	enforce(d.GetParrents() == [b]);
}
