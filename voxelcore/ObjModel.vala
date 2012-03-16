using Gee;




namespace voxelcore {
	public class ObjModel : GLib.Object, IVectorModel {
		private File file {get; set;}
		// Circumstantial use of two different list types to hopefully
		// speed things up a bit for sufficiently large models.
		private LinkedList<Vector?> vertex_buffer {get; set;}
		private LinkedList<Vector?> normal_buffer {get; set;}
		private ArrayList<Vector?> vertex_array {get; set;}
		private ArrayList<Vector?> normal_array {get; set;}
		public bool exists { 
			get {
				return file.query_exists();
			}
		}
		public LinkedList<Face?> faces {get; set;}

		public ObjModel(string path) throws IOError, VectorModelError {
			faces = new LinkedList<Face?>();
			vertex_buffer = new LinkedList<Vector?>();
			normal_buffer = new LinkedList<Vector?>();
			vertex_array = new ArrayList<Vector?>();
			normal_array = new ArrayList<Vector?>();
			
			file = File.new_for_path(path);
			
			if (exists) {
				load();
			}
			else {
				//throw new IOError("File does not exist.");
			}
		}

		private void clear_buffers() {
			vertex_buffer.clear();
			normal_buffer.clear();
			vertex_array.clear();
			normal_array.clear();
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
				bool arrays_dirty = false;
				while (line != null) {
					if (line.has_prefix("o ") || line.has_prefix("g ")) {
						// FIXME verify correctness
						stdout.printf("==> Begin new object / group definition.\n");
						arrays_dirty = true;
					}
					if (line.has_prefix("v ")) {
						vertex_buffer.add(parse_vector(line));
					}
					if (line.has_prefix("vn ")) {
						normal_buffer.add(parse_vector(line));
					}
					if (line.has_prefix("f ")) {
						// FIXME break down quads into triangles.
						if (arrays_dirty) {
							stdout.printf("Converting buffers from LinkedList to ArrayList.\n");
							vertex_array.add_all(vertex_buffer);
							normal_array.add_all(normal_buffer);
							var vert_count = vertex_buffer.size;
							var norm_count = normal_buffer.size;
							stdout.printf(@"vertex count: $vert_count, normal_count: $norm_count\n");
							stdout.printf("Begin polygon construction.\n");
							arrays_dirty = false;
						}
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
				throw new VectorModelError.PARSER_FAILURE("Parser quit with an error.");
			} finally {
				stdout.printf("\n");
				clear_buffers();
			}
			if (faces.size == 0) {
				throw new VectorModelError.PARSER_FAILURE("Parser yielded no faces.");
			}
		}
	}
}