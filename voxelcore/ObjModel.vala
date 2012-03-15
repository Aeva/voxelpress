using Gee;




namespace voxelcore {
	public class ObjModel : GLib.Object, IVectorModel {
		private File file {get; set;}
		private ArrayList<Vector> vertex_buffer {get; set;}
		private ArrayList<Vector> normal_buffer {get; set;}
		public bool exists { 
			get {
				return file.query_exists();
			}
		}
		public HashSet<Face> faces {get; set;}

		public ObjModel(string path) throws IOError, VectorModelError {
			faces = new HashSet<Face>();
			file = File.new_for_path(path);
			
			if (exists) {
				clear_buffers();
				load();
			}
			else {
				//throw new IOError("File does not exist.");
			}
		}

		private void clear_buffers() {
			vertex_buffer = new ArrayList<Vector>();
			normal_buffer = new ArrayList<Vector>();
		}

		private Vector parse_vector(string line) {
			var parts = line.split(" ");
			Vector vec = Vector();
			vec.vector = { 
				double.parse(parts[1]),
				double.parse(parts[2]),
				double.parse(parts[3])
			};
			return vec;
		}

		private void load() throws IOError, VectorModelError {
			try {
				var IN = new DataInputStream(file.read());
				string line = IN.read_line(null);
				while (line != null) {
					if (line[0] == "o"[0] || line[0] == "g"[0]) {
						// FIXME verify correctness
						clear_buffers();
					}
					if (line[0] == "v"[0]) {
						vertex_buffer.add(parse_vector(line));
					}
					if (line[0:1] == "vn"[0:1]) {
						vertex_buffer.add(parse_vector(line));
					}
					if (line[0] == "f"[0]) {
						// FIXME break down quads into triangles.
						var face = Face();
						face.vertices = new Vector[3];
						face.normals = new Vector[3];
						var parts = line.split(" ");
						for (int i=0; i<3; i+=1) {
							var bits = parts[1+i].split("/");
							face.vertices[i] = vertex_buffer[int.parse(bits[0])-1];
							face.normals[i] = normal_buffer[int.parse(bits[2])-1];
						}
						faces.add(face);
					}
					line = IN.read_line(null);
				}
			} catch (Error e) {
				// FIXME handle it or something
			}
			clear_buffers();
			if (faces.size == 0) {
				throw new VectorModelError.PARSER_FAILURE("Parser yielded no faces.");
			}
		}
	}
}