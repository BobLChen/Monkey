package monkey.core.components {

	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import monkey.core.base.Object3D;
	import monkey.core.base.Surface3D;
	import monkey.core.entities.Mesh3D;
	import monkey.core.interfaces.IComponent;
	import monkey.core.materials.DiffuseMaterial;
	import monkey.core.materials.Material3D;
	import monkey.core.textures.Texture3D;
	import monkey.core.utils.Device3D;
	import monkey.core.utils.MathUtils;
	import monkey.core.utils.Time3D;
	import monkey.core.utils.Vector3DUtils;

	/**
	 * 条带、刀光等，不允许克隆。
	 * @author Neil
	 * 
	 */	
	public class Trail3D extends Component3D implements IComponent {
		
		/** 持续时间 */
		public var time 		: Number  = 0.2;
		/** 高度 */
		public var height		: Number  = 100.0;
		/** 是否一直朝上 */
		public var awaysUp		: Boolean = false;
		/** 最小距离 */
		public var minDist		: Number  = 0;
		/** 速率 */
		public var speed		: Number  = 1.0;
		/** 动画时间 */
		public var tweenTime	: Number  = 0.2;
		
		/** 条带模型 */
		private var surf 		: Surface3D;
		/** 条带节点 */
		private var sections	: Vector.<TrailSection>;
		
		private var _mesh		: Mesh3D;					// 模型
		private var _material 	: DiffuseMaterial;			// 材质
		private var _texture  	: Texture3D;				// 贴图
		
		public function Trail3D(texture : Texture3D) {
			super();
			this.surf 	   = new Surface3D();
			this.sections  = new Vector.<TrailSection>();
			this._material = new DiffuseMaterial(texture);
			this._mesh	   = new Mesh3D([surf]);
			this._material.twoSided  = true;
			this._material.blendMode = Material3D.BLEND_ADDITIVE;
		}
		
		override public function dispose(force:Boolean=false):void {
			super.dispose(force);
			this.mesh.dispose(force);
			this.material.dispose(force);
		}
		
		/**
		 * 条带材质 
		 * @return 
		 * 
		 */		
		public function get material():DiffuseMaterial {
			return _material;
		}
		
		/**
		 * 条带渲染器 
		 * @return 
		 * 
		 */		
		public function get mesh():Mesh3D {
			return _mesh;
		}
		
		/**
		 * 条带贴图 
		 * @return 
		 * 
		 */		
		public function get texture():Texture3D {
			return _texture;
		}
		
		/**
		 * 条带贴图 
		 * @param value
		 * 
		 */		
		public function set texture(value:Texture3D):void {
			this._texture = value;
			this._material.texture = value;
		}

		/**
		 * 设置Trail动画 
		 * @param trailTime		动画时间
		 * @param tweenTo		最小动画时间
		 * @param speed			速度
		 * 
		 */		
		public function setTime(trailTime : Number, tweenTo : Number, speed : Number) : void {
			this.time = trailTime;
			this.speed = speed;
			this.tweenTime = tweenTo;
			if (this.time <= 0) {
				this.clearTrail();				
			}
		}
		
		override public function onAdd(master:Object3D):void {
			super.onAdd(master);
			this.object3D.addEventListener(Object3D.EXIT_DRAW_EVENT, onExitDraw);
		}
		
		override public function onRemove(master:Object3D):void {
			super.onRemove(master);
			master.removeEventListener(Object3D.EXIT_DRAW_EVENT, onExitDraw);
		}
		
		/**
		 * 绘制 
		 * @param scene
		 * 
		 */		
		public function onExitDraw(scene:Event):void {
			// 弹出已经消失的顶点
			while (this.sections.length > 0 && Time3D.totalTime > sections[sections.length - 1].time + time) {
				this.sections.pop();				
			}
			// 必须要求至少两个点
			if (this.sections.length < 2) {
				return;
			}
			// 清空数据
			this.clearTrail();
			// 组建数据
			var vertices : Vector.<Number> = new Vector.<Number>(sections.length * 2 * 3);
			var uvs	: Vector.<Number> = new Vector.<Number>(sections.length * 2 * 2);
			// 
			for (var i:int = 0; i < sections.length; i++) {
				var section : TrailSection = sections[i];
				var u : Number = 0;
				if (i != 0) {
					u = (Time3D.totalTime - section.time) / time;
					u = MathUtils.clamp(0, 0.99, u);
				}
				var upDir : Vector3D = section.upDir;
				var step  : int = i * 2 * 3;
				// 顶点
				vertices[step + 0] = section.point.x;
				vertices[step + 1] = section.point.y;
				vertices[step + 2] = section.point.z;
				vertices[step + 3] = section.point.x + upDir.x * height;
				vertices[step + 4] = section.point.y + upDir.y * height;
				vertices[step + 5] = section.point.z + upDir.z * height;
				// uv
				step = i * 2 * 2;
				uvs[step + 0] = u;
				uvs[step + 1] = 0;
				uvs[step + 2] = u;
				uvs[step + 3] = 1;
			}
			var indices : Vector.<uint> = new Vector.<uint>((sections.length - 1) * 2 * 3);
			for (i = 0; i < indices.length / 6; i++) {
				step = i * 6;
				indices[step + 0] = i * 2 + 0;
				indices[step + 1] = i * 2 + 1;
				indices[step + 2] = i * 2 + 2;
				
				indices[step + 3] = i * 2 + 2;
				indices[step + 4] = i * 2 + 1;
				indices[step + 5] = i * 2 + 3;
			}
			this.surf.indexVector = indices;
			this.surf.setVertexVector(Surface3D.POSITION, vertices, 3);
			this.surf.setVertexVector(Surface3D.UV0, uvs, 2);
			// 绘制
			Device3D.world.identity();
			Device3D.mvp.copyFrom(Device3D.world);
			Device3D.mvp.append(Device3D.viewProjection);
			material.updateMaterial(object3D.scene);
			for (i = 0; i < mesh.surfaces.length; i++) {
				material.draw(object3D.scene, mesh.surfaces[i]);
			}
			// tween to
			if (this.time > this.tweenTime) {
				this.time -= Time3D.deltaTime * speed;
				this.time = Math.max(this.time, this.tweenTime);
			} else if (this.time < this.tweenTime) {
				this.time += Time3D.deltaTime * speed;
				this.time = Math.min(this.time, this.tweenTime);
			}
		}
		
		override public function onUpdate():void {
			super.onUpdate();
			this.updateSection();
		}
		
		/**
		 * 更新条带节点
		 */		
		private function updateSection() : void {
			this.object3D.transform.getPosition(false, Vector3DUtils.vec0);
			if (this.sections.length == 0 ||
				Vector3DUtils.length(sections[0].point, Vector3DUtils.vec0) > minDist) {
				var section : TrailSection = new TrailSection(Vector3DUtils.vec0, Time3D.totalTime);
				if (this.awaysUp) {
					section.upDir.copyFrom(Vector3D.Y_AXIS);
				} else {
					this.object3D.transform.getUp(false, Vector3DUtils.vec0);
					section.upDir.copyFrom(Vector3DUtils.vec0);
				}
				this.sections.splice(0, 0, section);
			}
		}
		
		/**
		 * 淡出 
		 * @param fadeTime
		 * 
		 */		
		public function fadeOut(fadeTime : Number) : void {
			this.tweenTime = 0;
			if (time > 0) {
				this.speed = time / fadeTime;
			}
		}
		
		/**
		 * 清空trail数据 
		 * 
		 */		
		private function clearTrail() : void {
			this.surf.download(true);
			this.surf.freeMemory(true);
		}
				
	}
}
import flash.geom.Vector3D;

class TrailSection {
	
	/** 位置 */
	public var point : Vector3D;
	/** 方向 */
	public var upDir : Vector3D;
	/** 出现时间 */
	public var time	 : Number;
	
	/**
	 *  
	 * @param point	出现位置
	 * @param time	出现时间
	 * 
	 */	
	public function TrailSection(point : Vector3D, time : Number) : void {
		this.point = new Vector3D();
		this.upDir = new Vector3D();
		this.time  = time;
		this.point.copyFrom(point);
	}
}
