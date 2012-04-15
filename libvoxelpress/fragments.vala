using Gee;
using libvoxelpress.vectors;


namespace libvoxelpress.fragments {


    public class Coordinate: GLib.Object {
        public int x = 0;
        public int y = 0;
        public int z = 0;

        public Coordinate (int x, int y, int z) {
            this.x = x;
            this.y = y;
            this.z = z;
        }

        public int cmp (Coordinate other) {
            if (this.y < other.y) {
                return -1;
            }
            else if (this.y > other.y) {
                return 1;
            }
            else if (this.x < other.x) {
                return -1;
            }
            else if (this.x > other.x) {
                return 1;
            }
            else {
                return 0;
            }
        }
    }


    public class Fragment: GLib.Object {
        public Vec4 color {get; set;}
        public Vec3 normal {get; set;}
        public bool solid {get; set; default=true;}

        public Object? create() {
            var frag = new Fragment();
            frag.solid = false;
            return (Object) frag;
        }
    }
}