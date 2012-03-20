using Gee;


namespace libvoxelpress.vectors {
	public errordomain VectorModelError {
		PARSER_FAILURE,
		DISCARD_FACE
	}


	public class Vector : GLib.Object {
		public double[] vector = new double[] { 0, 0, 0 };
	}


	public class Face : GLib.Object {
		public Vector[] vertices = new Vector[] { new Vector(), new Vector(), new Vector() };
		public Vector[] normals = new Vector[] { new Vector(), new Vector(), new Vector() };
	}


	public interface VectorModel : GLib.Object {
		public abstract LinkedList<Face?> faces {get; set;}
		public abstract void load(string path) throws IOError, VectorModelError;
		public void add (VectorModel model) {
			faces.insert_all(0, model.faces);
		}
	}
}