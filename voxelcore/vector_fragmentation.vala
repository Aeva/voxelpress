using libvoxelpress.plugins;
using libvoxelpress.vectors;




namespace voxelcore {
	public class Vector2Fragment : GLib.Object, VectorPlugin {
		// implied final plugin for the vector_stage
		private double resolution;
		private double thickness;

		public Vector2Fragment(double resolution, double thickness) {
			this.resolution = resolution;
			this.thickness = thickness;
		}

		public void transform (Face face) throws VectorModelError {
			//stdout.printf(".");
		}
	}
}