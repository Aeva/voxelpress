/*

  This file is part of VoxelPress.

  VoxelPress is free software: you can redistribute it and/or modify it
  under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  VoxelPress is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with VoxelPress.  If not, see <http://www.gnu.org/licenses/>.

  Have a nice day!

*/


namespace libvcm.voxel_model {

	public interface VoxelKind: Object {
	}

	public interface VoxelModelKind: Object {
		public abstract int layer_dpi { get; private set; }
		public abstract int layer_height { get; private set; }
		public abstract int build_width { get; private set; }
		public abstract int build_length { get; private set; }
		public abstract int build_height { get; private set; }
		
		public abstract VoxelKind get(int x, int y, int z);
		public abstract void set(int x, int y, int z, VoxelKind voxel);
	}
	
	public interface RasterLayerKind: Object {
		public abstract VoxelKind? get(int x, int y);
		public abstract void set(int x, int y, VoxelKind voxel);
	}

	public interface DataBlockKind: Object {
		public abstract VoxelKind? get(int x, int y);
		public abstract void set(int x, int y, VoxelKind voxel);
	}
}