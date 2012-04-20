using libvoxelpress.plugins;
using libvoxelpress.vectors;
using libvoxelpress.fragments;


class Point : GLib.Object {
	// FIXME use the coordinate class instead
	public double x {get; set;}
	public double y {get; set;}
	public double z {get; set;}

	public Point(Vec3 vec, double resolution, double thickness) {
		this.x = vec.data[0] / resolution;
		this.y = vec.data[1] / resolution;
		this.z = vec.data[2] / thickness;
	}

	public Point.with_coords(double x, double y, double z) {
		this.x = x;
		this.y = y;
		this.z = z;
	}
}


class Edge : GLib.Object {
	public Point[] ends {get; private set;}
	private Point low_x;
	private Point low_z;
	private Point high_x;
	private Point high_z;
	public double zmin {
		get {
			return low_z.z;
		}
	}
	public double zmax {
		get {
			return high_z.z;
		}
	}
	public double xmin {
		get {
			return low_x.x;
		}
	}
	public double xmax {
		get {
			return high_x.x;
		}
	}

	public Edge(Point i, Point k) {
		ends = {i, k};
		low_x = i.x < k.x ? i : k;
		low_z = i.z < k.z ? i : k;
		high_x = low_x == i ? k : i;
		high_z = low_z == i ? k : i;
	}

	public Point? slice(double z) {
		if (low_z.z <= z && z <= high_z.z) {
			double alpha = (z-low_z.z)/(high_z.z-low_z.z);
			double x = mix(low_z.x, high_z.x, alpha);
			double y = mix(low_z.y, high_z.y, alpha);
			return new Point.with_coords(x, y, z);
		}
		else {
			return null;
		}
	}

	public double? sample(double x) {
		if (low_x.x <= x && x <= high_x.x) {
			double alpha = (x - low_x.x) / (high_x.x - low_x.x);
			return mix(low_x.y, high_x.y, alpha);
		}
		else {
			return null;
		}
	}
}


namespace voxelcore {
	public class Vector2Fragment : GLib.Object, VectorPlugin {
		// implied final plugin for the vector_stage
		private double resolution;
		private double thickness;
		private BlockedModel cache;

		public Vector2Fragment(double resolution, double thickness, BlockedModel cache) {
			// FIXME cache should be a BTREE, not an async queue
			this.resolution = resolution;
			this.thickness = thickness;
			this.cache = cache;
		}

		public void transform (Face face) throws VectorModelError {
			Point[] points = {};
			foreach (var vert in face.vertices) {
				points += new Point(vert, resolution, thickness);
			}
			Edge[] edges = {
				new Edge(points[0], points[1]),
				new Edge(points[1], points[2]),
				new Edge(points[2], points[0])
			};
			double? zmin = null;
			double? zmax = null;
			foreach (Edge edge in edges) {
				if (zmin == null || edge.zmin < zmin) {
					zmin = edge.zmin;
				}
				if (zmax == null || edge.zmax > zmax) {
					zmax = edge.zmax;
				}
			}

			for (double z = Math.floor(zmin); z <= Math.ceil(zmax); z += 1) {
				Point[] ends = {};
				foreach (Edge edge in edges) {
					var point = edge.slice(z);
					if (point != null) {
						ends += point;
					}
				}
				if (ends.length >= 2) {
					var scanline = new Edge(ends[0], ends[1]);
					for (double x = Math.floor(scanline.xmin); x <= Math.ceil(scanline.xmax); x+=1) {
						var y = scanline.sample(x);
						if (y != null) {
							// cache a fragment
							int ix = (int) Math.floor(x);
							int iy = (int) Math.floor(y);
							int iz = (int) Math.floor(z);
							cache.push(ix, iy, iz, new Fragment());
						}
					}
				}
			}
		}
	}
}