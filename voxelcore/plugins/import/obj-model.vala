using Gee;
using libvoxelpress.vectors;
using libvoxelpress.plugins;


public class ObjModel : GLib.Object, VectorModel, ImportPlugin {
	// Circumstantial use of two different list types to hopefully
	// speed things up a bit for sufficiently large models.
	private Vector[] vertex_array = {};
	private Vector[] normal_array = {};
	public LinkedList<Face?> faces {get; set;}

	construct {
		faces = new LinkedList<Face?>();
	}
	
	public void load(string path) throws IOError, VectorModelError {
		var file = File.new_for_path(path);
		
		if (file.query_exists()) {
			parse(file);
		}
		else {
			//throw new IOError("File does not exist.");
		}
	}
	
	private Vector parse_vector(string line) {
		var parts = line.split(" ");
		Vector vec = new Vector();
		vec.vector = { 
			double.parse(parts[1]),
			double.parse(parts[2]),
			double.parse(parts[3])
		};
		return vec;
	}
	
	private void parse(File file) throws IOError, VectorModelError {
		try {
			var IN = new DataInputStream(file.read());
			string line = IN.read_line(null);
			while (line != null) {
				if (line.has_prefix("o ") || line.has_prefix("g ")) {
					// FIXME verify correctness
				}
				if (line.has_prefix("v ")) {
					vertex_array += parse_vector(line);
				}
				if (line.has_prefix("vn ")) {
					normal_array += parse_vector(line);
				}
				if (line.has_prefix("f ")) {
					// FIXME break down quads into triangles.
					var face = new Face();
					var parts = line.split(" ");
					for (int i=0; i<3; i+=1) {
						var bits = parts[1+i].split("/");
						face.vertices[i] = vertex_array[int.parse(bits[0])-1];
						face.normals[i] = normal_array[int.parse(bits[2])-1];
					}
					faces.add(face);
				}
				
				line = IN.read_line(null);
			}
			
		} catch (Error e) {
			throw new VectorModelError.PARSER_FAILURE("Parser quit with an error.");
		}
		if (faces.size == 0) {
			throw new VectorModelError.PARSER_FAILURE("Parser yielded no faces.");
		}
	}
}


public ImportMetaData register_plugin (Module module) {
	var info = new ImportMetaData();
	info.object_type = typeof (ObjModel);
	info.name = "obj import";
	info.extensions = {".obj"};

	return info;
}