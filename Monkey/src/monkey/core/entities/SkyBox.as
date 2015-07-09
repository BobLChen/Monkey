package monkey.core.entities {

	import flash.display.BitmapData;
	
	import monkey.core.base.Object3D;
	import monkey.core.base.Surface3D;
	import monkey.core.interfaces.IComponent;
	import monkey.core.materials.SkyboxMaterial;
	import monkey.core.renderer.SkyboxRenderer;
	import monkey.core.scene.Scene3D;
	import monkey.core.textures.Bitmap2DTexture;
	import monkey.core.textures.Texture3D;
	import monkey.core.utils.Device3D;
	import monkey.core.utils.Texture3DUtils;
	import monkey.core.utils.Vector3DUtils;
	
	/**
	 * 天空盒 
	 * @author Neil
	 * 
	 */	
	public class SkyBox extends Object3D {
		
		private var _size 		: int;
		private var _scaleRatio	: Number;
		private var _bitmapData : BitmapData;
		private var _dirty		: Boolean;
		private var _material	: SkyboxMaterial;
		
		/**
		 *  
		 * @param bitmapData	贴图
		 * @param size			尺寸
		 * @param scaleRatio	缩放比率
		 * 
		 */		
		public function SkyBox(bitmapData : BitmapData, size : Number = 3000, scaleRatio : Number = 0.8) {
			super();
			this._material 	= new SkyboxMaterial([]);
			this._layer 	= -10;
			this.name 		= "SkyBox";
			this.size 		= size;
			this.scaleRatio = scaleRatio;
			this.bitmapData = bitmapData;
			this.addComponent(new SkyboxRenderer(null, this._material));
			this.initSkybox();
		}
		
		/**
		 * 销毁 
		 * @param force
		 * 
		 */		
		override public function dispose(force : Boolean = false):void {
			super.dispose(force);
			if (this.bitmapData) {
				this.bitmapData.dispose();
			}
		}
		
		/**
		 *  初始化天空盒
		 */		
		private function initSkybox() : void {
			this._dirty = false;
			if (this.renderer.mesh) {
				this.renderer.mesh.dispose(true);
			}
			var surfaces : Array = [];
			var uvs  : Vector.<Number> = Vector.<Number>([0, 0, 1, 0, 0, 1, 1, 1]);
			// front
			var surf : Surface3D = new Surface3D();
			surf.setVertexVector(Surface3D.POSITION, Vector.<Number>([
				-size,	size,	size,
				size,	size,	size,
				-size,	-size,	size,
				size,	-size,	size
			]), 3);
			surfaces.push(surf);
			// right
			surf = new Surface3D();
			surf.setVertexVector(Surface3D.POSITION, Vector.<Number>([
				size,	size,	size,
				size,	size,	-size,
				size,	-size,	size,
				size,	-size,	-size
			]), 3);
			surfaces.push(surf);
			// back
			surf = new Surface3D();
			surf.setVertexVector(Surface3D.POSITION, Vector.<Number>([
				size,	size,	-size,
				-size,	size,	-size,
				size,	-size,	-size,
				-size,	-size,	-size
			]), 3);
			surfaces.push(surf);
			// left
			surf = new Surface3D();
			surf.setVertexVector(Surface3D.POSITION, Vector.<Number>([
				-size,	size,	-size,
				-size,	size,	size,
				-size,	-size,	-size,
				-size,	-size,	size
			]), 3);
			surfaces.push(surf);
			// top
			surf = new Surface3D();
			surf.setVertexVector(Surface3D.POSITION, Vector.<Number>([
				-size,	size,	-size,
				size,	size,	-size,
				-size,	size,	size,
				size,	size,	size
			]), 3);
			surfaces.push(surf);
			// bottom
			surf = new Surface3D();
			surf.setVertexVector(Surface3D.POSITION, Vector.<Number>([
				-size,	-size,	size,
				size,	-size,	size,
				-size,	-size,	-size,
				size,	-size,	-size
			]), 3);
			surfaces.push(surf);
			
			for each (surf in surfaces) {
				surf.setVertexVector(Surface3D.UV0, uvs, 2);
				surf.indexVector = Vector.<uint>([0, 1, 2, 1, 3, 2]);
			}
			this.renderer.mesh = new Mesh3D(surfaces);
		}
		
		/**
		 * 天空盒位图 
		 * @return 
		 * 
		 */		
		public function get bitmapData():BitmapData {
			return _bitmapData;
		}
		
		public function set bitmapData(value:BitmapData):void {
			if (this._bitmapData) {
				this._bitmapData.dispose();
			}
			for each (var texture : Texture3D in this._material.textures) {
				texture.dispose(true);
			}
			this._bitmapData = value;
			var bmps : Array = Texture3DUtils.extractCubeMap2(value);
			var texs : Vector.<Texture3D> = new Vector.<Texture3D>();
			for (var i:int = 0; i < 6; i++) {
				var tex : Texture3D = new Bitmap2DTexture(bmps[i]);
				tex.mipMode  = Texture3D.MIP_NONE;
				tex.wrapMode = Texture3D.WRAP_CLAMP;
				texs.push(tex);
			}
			this._material.textures = texs;
		}
		
		/**
		 * 缩放比例 
		 * @return 
		 * 
		 */		
		public function get scaleRatio():Number {
			return _scaleRatio;
		}

		public function set scaleRatio(value:Number):void {
			this._scaleRatio = value;
		}
		
		/**
		 * 尺寸 
		 * @return 
		 * 
		 */		
		public function get size():int {
			return _size;
		}

		public function set size(value:int):void {
			this._size = value;
			this._dirty = true;
		}
		
		/**
		 * 绘制天空盒 
		 * @param scene
		 * @param includeChildren
		 * 
		 */		
		override public function draw(scene:Scene3D, includeChildren:Boolean=true):void {
			if (this._dirty) {
				this.initSkybox();
			}
			if (!visible) {
				return;
			}
			// 设置mvp
			Device3D.camera.transform.getPosition(false, Vector3DUtils.vec0);
			this.transform.setPosition(Vector3DUtils.vec0.x, Vector3DUtils.vec0.y, Vector3DUtils.vec0.z);
			Device3D.world.copyFrom(transform.world);
			Device3D.mvp.copyFrom(Device3D.world);
			Device3D.mvp.append(Device3D.viewProjection);
			Device3D.mvp.appendScale(scaleRatio, scaleRatio, 1);
			Device3D.drawOBJNum++;
			// 渲染事件
			if (this.hasEventListener(ENTER_DRAW_EVENT)) {
				this.dispatchEvent(enterDrawEvent);
			}
			// 绘制
			for each (var icom : IComponent in components) {
				if (icom.enable) {
					icom.onDraw(scene);
				}
			}
			// 绘制子节点
			if (includeChildren) {
				for each (var child : Object3D in children) {
					child.draw(scene, includeChildren);
				}
			}
			// 退出渲染
			if (this.hasEventListener(EXIT_DRAW_EVENT)) {
				this.dispatchEvent(exitDrawEvent);
			}
		}
		
	}
}
