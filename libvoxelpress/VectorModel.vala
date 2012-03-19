using Gee;


namespace libvoxelpress.vectors {
	public errordomain VectorModelError {
		PARSER_FAILURE,
		DISCARD_FACE
	}


	public struct Vector {
		public double[] vector;
	}


	public struct Face {
		public Vector[] vertices;
		public Vector[] normals;
	}


	public interface VectorModel : GLib.Object {
		public abstract LinkedList<Face?> faces {get; set;}
		public abstract void load(string path) throws IOError, VectorModelError;
		public void add (VectorModel model) {
			faces.insert_all(0, model.faces);
		}
	}
}