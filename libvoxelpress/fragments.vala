using Gee;
using libvoxelpress.vectors;
using libvoxelpress.etc;


namespace libvoxelpress.fragments {
	/*
	  In voxelpress, fragments function as an intermediary between
	  unsorted polygons and structured voxel models.

	  Fragments are used to express some information about a coordinate, 
	  such as color or surface normal.

	  The FragmentCache class is thread safe, and is intended to be used
	  in place of an AsyncQueue.
	 */


	public class Fragment: GLib.Object {		
		public int x = 0;
		public int y = 0;
		public int z = 0;
		public Vec3 normal {get; set;}
		public Vec4 color {get; set;}

		public Fragment(int x, int y, int z) {
			this.x = x;
			this.y = y;
			this.z = z;
		}
	}


	public class FragmentLayer: GLib.Object {
		private BTree<Fragment> grid;
		private BTreeComparisonFunction cmp = (x, y) => {
			var a = (Fragment) x;
			var b = (Fragment) y;
			if (a.y < b.y) {
				return -1;
			}
			else if (a.y > b.y) {
				return 1;
			}
			else if (a.x < b.x) {
				return -1;
			}
			else if (a.x > b.x) {
				return 1;
			}
			else {
				return 0;
			}
		};
		public int z {get; private set;}
		public Fragment? min {get; private set; default = null;}
		public Fragment? max {get; private set; default = null;}
		
		public FragmentLayer(int z) {
			grid = new BTree<Fragment>(cmp);
			this.z = z;
		}

		public void push(Fragment frag) {
			lock (grid) {
				grid.push(frag);
				if (min == null || cmp(frag, min) < 0) {
					min = frag;
				}
				if (max == null || cmp(frag, max) > 0) {
					max = frag;
				}
			}
		}

		public Fragment? fetch(int x, int y) {
			Fragment? result = null;
			lock (grid) {
				result = grid.fetch(new Fragment(x, y, z));
			}
			return result;
		}
	}


	public class FragmentCache: GLib.Object {
		private BTree<FragmentLayer> layers;
		public int? min {get; private set; default = null;}
		public int? max {get; private set; default = null;}
		private BTreeComparisonFunction cmp = (a, b) => {
			return ((FragmentLayer)a).z - ((FragmentLayer)b).z;
		};
		
		public FragmentCache() {
			layers = new BTree<FragmentLayer>(cmp);
		}

		public void push(Fragment frag) {
			FragmentLayer? layer;
			lock (layers) {
				layer = layers.fetch(new FragmentLayer(frag.z));
				if (layer == null) {
					layer = new FragmentLayer(frag.z);
					layers.push(layer);
					if (min == null || frag.z < min) {
						min = frag.z;
					}
					if (max == null || frag.z > max) {
						max = frag.z;
					}
				}
			}
			layer.push(frag);
		}

		public Fragment? fetch(int x, int y, int z) {
			FragmentLayer? layer;
			lock (layers) {
				layer = layers.fetch(new FragmentLayer(z));
			}
			return layer.fetch(x, y);
		}
	}
}