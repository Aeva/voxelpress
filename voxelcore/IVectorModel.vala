
using Gee;




namespace voxelcore {


	public errordomain VectorModelError {
		PARSER_FAILURE
	}


	public struct Vector {
		public double[] vector;
	}


	public struct Face {
		public Vector[] vertices;
		public Vector[] normals;
	}


	public interface IVectorModel : GLib.Object {
		public abstract HashSet<Face> faces {get; set;}
		public abstract bool exists {get;}
		public void add (IVectorModel model) {
			foreach (Face f in model.faces) {
				faces.add(f);
			}
		}
	}
}
