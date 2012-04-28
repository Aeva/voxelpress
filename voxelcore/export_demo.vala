using Json;

namespace voxelcore {


	public string json_dump ( int w, int l, int d, int sw, int sl, int sd, string data ) {
		var gen = new Generator();
		var root = new Json.Node(NodeType.OBJECT);
		var packet = new Json.Object();
		root.set_object(packet);
		gen.set_root(root);
		var scale = new Json.Array();
		scale.add_double_element(sw);
		scale.add_double_element(sl);
		scale.add_double_element(sd);
		packet.set_array_member("s", scale);
		packet.set_int_member("w", w);
		packet.set_int_member("l", l);
		packet.set_int_member("d", d);
		packet.set_string_member("a", data);
		size_t length;
		return gen.to_data(out length);
	}
	
	
	public string encode (int[] data) {
		uchar[] raw = {};
		uchar working = 0;
		int period = 0;
		
		for (int i=0; i<data.length; i+=1) {
			if (data[i] == 1) {
				working |= 2<<period;
			}
			period += 1;
			if (period >= 7 | i+1 == data.length) {
				raw += working;
				working = 0;
				period = 0;
			}
		}
		return Base64.encode(raw);
	}
}