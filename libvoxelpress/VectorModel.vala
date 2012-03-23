using Gee;


namespace libvoxelpress.vectors {
	public errordomain VectorModelError {
		PARSER_FAILURE,
		DISCARD_FACE
	}

	public class Vec3: GLib.Object {
		public double[] data = new double[] {0, 0, 0};
		public Vec3() {
		}
		public Vec3.with_coords (double a, double b, double c) {
			data[0] = a;
			data[1] = b;
			data[2] = c;
		}
	}
	
	public class Vec4: GLib.Object {
		public double[] data = new double[] {0, 0, 0};
		public Vec4() {
		}
		public Vec4.with_coords (double a, double b, double c, double d) {
			data[0] = a;
			data[1] = b;
			data[2] = c;
			data[3] = d;
		}
	}
	
	public class Mat3: GLib.Object {
		public double[,] data = {{1, 0, 0}, 
								 {0, 1, 0}, 
								 {0, 0, 1}};
		public Vec3 multiply(Vec3 vector) {
			var result = new Vec3.with_coords(0,0,0);
			for (int y = 0; y<3; y+=1) {
				double cache = 0;
				for (int x = 0; x<3; x+=1) {
					cache += this.data[y,x] * vector.data[x];
				}
				result.data[y] = cache;
			}
			return result;
		}
	}
	
	public class Face: GLib.Object {
		public Vec3[] vertices = new Vec3[] { new Vec3(), new Vec3(), new Vec3() };
		public Vec3[] normals = new Vec3[] { new Vec3(), new Vec3(), new Vec3() };
	}

	public double radians ( double degrees ) {
		return degrees * 0.0174532925;
	}

	private Vec3 basic_skew (Vec3 coord, Mat3 skew_matrix) {
		double x = coord.data[0];
		double y = coord.data[1];
		double z = coord.data[2];
		var flat = new Vec3.with_coords(x, y, 1);
		var next = skew_matrix.multiply(flat);
		next.data[2] = z;
		return next;
	}

	public Vec3 x_skew (Vec3 coord, double a) {
		var skew = new Mat3();
		skew.data[0,1] = Math.tan(radians(a));
		return basic_skew(coord, skew);
	}

	public Vec3 y_skew (Vec3 coord, double a) {
		var skew = new Mat3();
		skew.data[1,0] = Math.tan(radians(a));
		return basic_skew(coord, skew);
	}

	public abstract class VectorModel : GLib.Object {
		public signal void new_face (Face face);
		public abstract int face_count { get; private set; }
		public abstract void load(string path) throws IOError, VectorModelError;
	}
}