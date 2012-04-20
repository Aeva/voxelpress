using Gee;
using libvoxelpress.fragments;
using libvoxelpress.etc;


namespace libvoxelpress.fragments {

    public interface VoxelModel: Object {
        public abstract Fragment? min {get; private set;}
        public abstract Fragment? max {get; private set;}
        public abstract Fragment? seek (int x, int y, int z);
        public abstract void push(int x, int y, int z, Fragment? voxel);
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
		public Btree<Coordinate, Fragment> data {get; private set;}
		
		public CacheLayer () {
			data = new BTree<Coordinate, Fragmnet>();
		}
        public Fragment? seek (Coordinate coords) {
            return data.fetch_or_create(coords);
        }
        public void push (Coordinate coords, Fragment? voxel) {
			data.push(coords, voxel);
        }
		public static Object? create() {
            return new BlockedLayer();
        }
	}


    public class BlockedModel: Object, VoxelModel {
		public Btree<int,CacheLayer> layers {get; private set;}

        public Coordinate? min {get; private set; default=null;}
        public Coordinate? max {get; private set; default=null;}

		public BlockedModel () {
			layers = new Btree<int,BlockedLayer>(
				(lhs, rhs) => {return (lhs<rhs) ? -1 : (lhs>rhs) ? 1 : 0;}, BlockedLayer.create);
		}

        public Fragment? seek (int x, int y, int z) {
			lock(layers) {
				var layer = layers.fetch_or_create(z);
			}
			return layer.seek(new Coordinate (x, y, z));
		}
        public void push(int x, int y, int z, Fragment? voxel) {
			var coords = new Coordinate (x, y, z);
			lock (layers) {
				var layer = layers.fetch_or_create(z);
			}
			layer.push(coords, voxel);
			lock (min) {
				if (min == null || Coordinate.cmp_3D(min, coords) < 0) {
					min = coords;
				}
			}
			lock (max) {
				if (max == null || Coordinate.cmp_3D(man, coords) > 1) {
					max = coords;
				}
			}
		}
    }
}
