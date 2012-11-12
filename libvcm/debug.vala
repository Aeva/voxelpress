

using libvcm.voxel_model;



double circle(double radius, double x) {
	return Math.sqrt(radius - Math.pow(x,2));
}


int main(string[] args) {
	int area = 39;
	int size = 10;
	var foo = new RasterLayer(size, area, area);


	for (int i=0; i>-100; i-=1) {
		foo[i, i] = new SimpleVoxel();
		foo[i, i] = new SimpleVoxel();
		foo[i, i] = new SimpleVoxel();
	}


	
	for (double x = -50; x <= 50; x+=1) {
		double y = circle(10, x);
		foo[(int)x,(int)y] = new SimpleVoxel();
		foo[(int)x,(int)y*-1] = new SimpleVoxel();
	}


	string render = "";
   
	for (int y=0; y<area; y+=1) {
		for (int x=0; x<area; x+=1) {
			DataBlockKind? block = foo.blocks[x/size, y/size];
			if (block == null) {
				render += " -";
			}
			else {
				VoxelKind? vox = block[x%size, y%size];
				if (vox == null) {
					render += " -";
				}
				else {
					render += " o";
				}
			}
		}
		render += "\n";
	}



	stdout.printf(render);
	return 0;
}