module relationlist.relationentry;

import relationlist.relationlist;

/**
 * The container class for the entries
 */
class RelationEntry(V) {
public:
	alias Entry = RelationEntry!V;
	alias value this;
	
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
	 * Returns: This object for chain calls
	 */
	Entry AddChild(Entry child) {
		children ~= child;
		return this;
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
	
	@property ref ulong ID() { return id; }
	@property ref V Value() { return value; }
	@property ref Entry[] Children() { return children; }
	
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
	RelationList!V owner;
	Entry[] children;
}
