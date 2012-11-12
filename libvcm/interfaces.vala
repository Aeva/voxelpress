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
		/*
		public abstract double page_width { get; set; }
		public abstract double page_length { get; set; }
		public abstract double page_height { get; set; }
		public abstract double xy_res { get; set; }
		public abstract double z_res { get; set; }
		public abstract int model_width { get; set; }
		public abstract int model_length { get; set; }
		public abstract int model_height { get; set; }
		public abstract int min_x { get; set; }
		public abstract int max_x { get; set; }
		public abstract int min_y { get; set; }
		public abstract int max_y { get; set; }
		public abstract int min_z { get; set; }
		public abstract int max_z { get; set; }
		public abstract bool empty { get; set; }
		*/
		public abstract VoxelKind? get(int x, int y, int z);
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