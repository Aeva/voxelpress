using Gee;
using libvoxelpress.fragments;
using libvoxelpress.etc;


namespace libvoxelpress.fragments {

    public interface VoxelModel: Object {
        public abstract Fragment? min {get; private set;}
        public abstract Fragment? max {get; private set;}
        public abstract Fragment? seek (int x, int y, int z);
        public abstract void push(Fragment? voxel);
    }


	public class BlockedLayer: Object {
        public Fragment? min {get; private set; default=null;}
        public Fragment? max {get; private set; default=null;}
        public Fragment? seek (int x, int y) {
            return null;
        }
        public void push (Fragment? voxel) {
        }
		public static Object? create() {
            return new BlockedLayer();
        }
    }


	public class CacheLayer: Object {
		/* pdq layer type, replace with BlockedLayer once it is written */
        public Fragment? min {get; private set; default=null;}
        public Fragment? max {get; private set; default=null;}
        public Fragment? seek (int x, int y) {
            return null;
        }
        public void push (Fragment? voxel) {
        }
		public static Object? create() {
            return new BlockedLayer();
        }
	}


    public class BlockedModel: Object, VoxelModel {
		public Btree<int,CacheLayer> layers {get; private set;}

        public Fragment? min {get; private set; default=null;}
        public Fragment? max {get; private set; default=null;}

		public BlockedModel () {
			layers = new Btree<int,BlockedLayer>(
				(lhs, rhs) => {return (lhs<rhs) ? -1 : (lhs>rhs) ? 1 : 0;}, BlockedLayer.create);
		}

        public Fragment? seek (int x, int y, int z) {
			var layer = new CacheLayer(); // FIXME implement BlockedModel


			return null;
		}
        public void push(Fragment? voxel) {
		}
    }
}
    
/*
    public class FragmentLayer: GLib.Object {
        private BTree<Fragment> grid;
        public BTree.cmp_func cmp {get; private set;}
        public BTree.creation_func on_create {get; private set;}
        


        private BTreeComparisonFunction cmp = (x, y) => {
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
        }*/