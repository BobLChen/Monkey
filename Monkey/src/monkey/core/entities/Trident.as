package monkey.core.entities {

	import monkey.core.base.Object3D;
	import monkey.core.entities.primitives.Cone;
	import monkey.core.entities.primitives.Cube;
	import monkey.core.materials.ColorMaterial;
	import monkey.core.renderer.MeshRenderer;
	import monkey.core.utils.Color;

	/**
	 *　　　　　　　　┏┓　　　┏┓+ +
	 *　　　　　　　┏┛┻━━━┛┻┓ + +
	 *　　　　　　　┃　　　　　　　┃ 　
	 *　　　　　　　┃　　　━　　　┃ ++ + + +
	 *　　　　　　 ████━████ ┃+
	 *　　　　　　　┃　　　　　　　┃ +
	 *　　　　　　　┃　　　┻　　　┃
	 *　　　　　　　┃　　　　　　　┃ + +
	 *　　　　　　　┗━┓　　　┏━┛
	 *　　　　　　　　　┃　　　┃　　　　　　　　　　　
	 *　　　　　　　　　┃　　　┃ + + + +
	 *　　　　　　　　　┃　　　┃　　　　　　　　　　　
	 *　　　　　　　　　┃　　　┃ + 　　　　　　
	 *　　　　　　　　　┃　　　┃
	 *　　　　　　　　　┃　　　┃　　+　　　　　　　　　
	 *　　　　　　　　　┃　 　　┗━━━┓ + +
	 *　　　　　　　　　┃ 　　　　　　　┣┓
	 *　　　　　　　　　┃ 　　　　　　　┏┛
	 *　　　　　　　　　┗┓┓┏━┳┓┏┛ + + + +
	 *　　　　　　　　　　┃┫┫　┃┫┫
	 *　　　　　　　　　　┗┻┛　┗┻┛+ + + +
	 * @author Neil
	 * @date   May 19, 2015
	 */
	public class Trident extends Object3D {
		
		public function Trident() {
			super();
			var xcube : Object3D = new Object3D();
			xcube.addComponent(new MeshRenderer(new Cube(100, 1, 1), new ColorMaterial(Color.RED)));
			xcube.transform.x = 50;
			var xCone : Object3D = new Object3D();
			xCone.addComponent(new MeshRenderer(new Cone(5, 0, 10, 12), new ColorMaterial(Color.RED)));
			xCone.transform.x = 100;
			xCone.transform.rotateZ(-90);
			addChild(xCone);
			addChild(xcube);
			
			var ycube : Object3D = new Object3D();
			ycube.addComponent(new MeshRenderer(new Cube(1, 100, 1, 1), new ColorMaterial(Color.GREEN)));
			ycube.transform.y = 50;
			var yCone : Object3D = new Object3D();
			yCone.addComponent(new MeshRenderer(new Cone(5, 0, 10, 12), new ColorMaterial(Color.GREEN)));
			yCone.transform.y = 100;
			addChild(ycube);
			addChild(yCone);
			
			var zcube : Object3D = new Object3D();
			zcube.addComponent(new MeshRenderer(new Cube(1, 1, 100), new ColorMaterial(Color.BLUE)));
			zcube.transform.z = 50;
			var zCone : Object3D = new Object3D();
			zCone.addComponent(new MeshRenderer(new Cone(5, 0, 10, 12), new ColorMaterial(Color.BLUE)));
			zCone.transform.z = 100;
			zCone.transform.rotateX(90);
			addChild(zcube);
			addChild(zCone);
		}
		
	}
}
