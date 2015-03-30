RelationList
============

TL;DR A list with parent and child relationships.

It starts of as a ordinary list.
But you can add children to each entry.
And from that get every parent for each entry.

Run this to get a png image via Graphviz, that opens in firefox, of the relationships
	dub test --config=unittest-graph


Example
-------

	RelationList!char mylist = new RelationList!char(); //Make list object
	//Add entries
	auto a = mylist.Add('a');
	auto b = mylist.Add('b');
	auto c = mylist.Add('c');
	auto d = mylist.Add('d');
	auto e = mylist.Add('e');
	auto f = mylist.Add('f');

	//Give each node a child/parent relationship
	a.AddChild(b);
	b.AddChild(c).AddChild(d); //Adds c & d to b
	d.AddChild(e);

	e.AddChild(f); //Make a loop, e <-> f
	f.AddChild(e);

	c.AddChild(f);

	//Example of parent output
	enforce(a.GetParents() == []);
	enforce(b.GetParents() == [a]);
	enforce(c.GetParents() == [b]);
	enforce(d.GetParents() == [b]);
	enforce(e.GetParents() == [d, f]);
	enforce(f.GetParents() == [c, e]);

License
-------
Mozilla Public License, version 2.0

Authors
-------
Dan Printzell
