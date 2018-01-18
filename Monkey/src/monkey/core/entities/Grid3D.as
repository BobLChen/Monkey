package monkey.core.entities {

	public class Grid3D extends Lines3D {
		
		private var rows 	: int = 0;
		private var colums 	: int = 0;
		private var size 	: Number = 0;
		
		public function Grid3D(rows : int = 11, colums : int = 11, size : Number = 100) {
			super();
			this.rows 	= rows;
			this.colums = colums;
			this.size 	= size;
			this.setLayer(-1);
			this.config();
		}
		
		private function config() : void {
			var rs : Number = int(colums / 2) * -size;
			var re : Number = -rs;
			var cs : Number = int(rows / 2) * -size;
			var ce : Number = -cs;
			for (var i:int = 0; i < rows; i++) {
				moveTo(rs, 0, cs + i * size);
				lineTo(re, 0, cs + i * size);
				moveTo(rs + i * size, 0, cs);
				lineTo(rs + i * size, 0, ce);
			}
		}
		
	}
}
