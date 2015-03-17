package monkey.core.utils {
	
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import monkey.core.base.Object3D;
	import monkey.core.base.Surface3D;
	import monkey.core.entities.particles.ParticleSystem;

	public class ParticleUtils {
		
		
		/**
		 * 粒子系统运行期关键帧数据生成器 
		 * @param maxLifetime	最大生命周期时间
		 * @param speedX		x轴速度关键帧
		 * @param speedY		y轴速度关键帧
		 * @param speedZ		z轴速度关键帧
		 * @param axisX			x轴旋转关键帧
		 * @param axisY			y轴旋转关键帧
		 * @param axisZ			z轴旋转关键帧
		 * @param size			尺寸关键帧
		 * @return 
		 * 
		 */		
		public static function GeneratelifetimeBytes(maxLifetime : Number, speedX : Linears, speedY : Linears, speedZ : Linears, axisX : Linears, axisY : Linears, axisZ : Linears, angle : Linears, size : Linears) : ByteArray {
			var bytes  : ByteArray = new ByteArray();
			bytes.endian = Endian.LITTLE_ENDIAN;
			var step: Number = 1 / (ParticleSystem.MAX_KEY_NUM - 1);
			var t	: Number = maxLifetime / (ParticleSystem.MAX_KEY_NUM - 1);		
			var ret : Vector3D = new Vector3D();
			// 旋转
			for (i = 0; i < ParticleSystem.MAX_KEY_NUM; i++) {
				ret.setTo(axisX.getY(i * step), axisY.getY(i * step), axisZ.getY(i * step));
				ret.normalize();
				bytes.writeFloat(ret.x);
				bytes.writeFloat(ret.y);
				bytes.writeFloat(ret.z);
				bytes.writeFloat(deg2rad(angle.getY(i * step)));
			}
			// 缩放
			for (i = 0; i < ParticleSystem.MAX_KEY_NUM; i++) {
				bytes.writeFloat(size.getY(i * step));
				bytes.writeFloat(size.getY(i * step));
				bytes.writeFloat(size.getY(i * step));
				bytes.writeFloat(size.getY(i * step));
			}
			ret.setTo(0, 0, 0);
			// 位移
			for (var i:int = 0; i < ParticleSystem.MAX_KEY_NUM; i++) {
				var x : Number = uniformly(speedX.getY(step * i), speedX.getY(step * i + step), t);
				var y : Number = uniformly(speedY.getY(step * i), speedY.getY(step * i + step), t);
				var z : Number = uniformly(speedZ.getY(step * i), speedZ.getY(step * i + step), t);
				bytes.writeFloat(ret.x);
				bytes.writeFloat(ret.y);
				bytes.writeFloat(ret.z);
				bytes.writeFloat(maxLifetime);
				ret.x += x;
				ret.y += y;
				ret.z += z;
			}
			return bytes;
		}
		
		private static function uniformly(v0 : Number, vt : Number, t : Number) : Number {
			var a : Number = (vt - v0) / t;
			var s : Number = v0 * t + 0.5 * a * t * t;
			return s;
		}
		
		/**
		 * 获取surface 
		 * @param bytes
		 * @return 
		 * 
		 */		
		public static function readSurfaces(bytes : ByteArray) : Vector.<Surface3D> {
			bytes.position = 0;
			var types 	 : Array = [Surface3D.POSITION, Surface3D.UV0, Surface3D.CUSTOM1, Surface3D.CUSTOM2, Surface3D.CUSTOM3, Surface3D.CUSTOM4];
			var surfaces : Vector.<Surface3D> = new Vector.<Surface3D>();
			// 读取surface长度
			var count : int = bytes.readInt();
			for (var i:int = 0; i < count; i++) {
				surfaces[i] = new Surface3D();
				surfaces[i].indexVector = new Vector.<uint>();
				for (var j:int = 0; j < types.length; j++) {
					var type : int  = bytes.readInt();
					var size : int  = bytes.readInt();
					var len  : uint = bytes.readUnsignedInt();
					var data : ByteArray = new ByteArray();
					data.endian = Endian.LITTLE_ENDIAN;
					bytes.readBytes(data, 0, len);
					surfaces[i].setVertexBytes(type, data, size);
				}
				// 索引长度
				size = bytes.readInt();
				for (j = 0; j < size; j++) {
					surfaces[i].indexVector.push(bytes.readInt());
				}
			}
			return surfaces;
		}
		
		/**
		 * 解析配置文件，生成对应的粒子。生成的粒子不含贴图以及粒子数据。
		 * @param config
		 * @return 
		 * 
		 */		
		public static function readParticles(config : Object) : Object3D {
			var ret : Object3D = null;
			if (config.particle) {
				ret = createParticle(config.particle);
			} else {
				ret = new Object3D();
			}
			ret.name = config.name;
			ret.transform.local.copyRawDataFrom(Vector.<Number>(config.transform));
			for each (var child : Object in config.children) {
				ret.addChild(readParticles(child));
			}
			ret.transform.updateTransforms(true);
			return ret;
		}
		
		/**
		 * 根据配置文件生成粒子系统
		 * @param config
		 * @return 
		 * 
		 */		
		private static function createParticle(config : Object) : ParticleSystem {
			var ret : ParticleSystem	= new ParticleSystem();
			
			ret.renderer.material.depthWrite 	= config.depthWrite;
			ret.renderer.material.depthCompare 	= config.depthCompare;
			ret.renderer.material.cullFace		= config.cullFace;
			ret.renderer.material.sourceFactor  = config.sourceFactor;
			ret.renderer.material.destFactor	= config.destFactor;
			
			ret.animator.totalFrames	= config.totalFrames == -1 ? Number.MAX_VALUE : config.totalFrames;
			ret.userData.imageName 		= config.imageName;
			ret.userData.uuid 			= config.uuid;
			ret.userData.optimize   	= config.optimize;
			ret.worldspace 				= config.world;
			ret.loops 	  				= config.loops;
			ret.billboard 				= config.billboard;
			ret.frame.x  				= config.frame[0];
			ret.frame.y  				= config.frame[1];
			ret.totalLife				= config.totalLife;
			ret.startDelay		    	= config.startDelay;
			ret.colorLifetime 	   	 	= ParticleConfig.getGradientColor(config.colorLifetime);
			ret.keyFrames 		    	= ParticleConfig.getKeyFrames(config.keyFrames);
			if (config.optimize) {
				return ret;
			}
			ret.duration 				= config.duration;
			ret.rate	  		    	= config.rate;
			ret.bursts					= ParticleConfig.getBursts(config.bursts);
			ret.shape	  		  		= ParticleConfig.getShape(config.shape);
			ret.startColor		  		= ParticleConfig.getColor(config.startColor);
			ret.startLifeTime	  		= ParticleConfig.getData(config.startLifeTime);
			ret.startOffset[0]	  		= ParticleConfig.getData(config.startOffset.x);
			ret.startOffset[1]	  		= ParticleConfig.getData(config.startOffset.y);
			ret.startOffset[2]	  		= ParticleConfig.getData(config.startOffset.z);
			ret.startRotation[0]  		= ParticleConfig.getData(config.startRotation.x);
			ret.startRotation[1]  		= ParticleConfig.getData(config.startRotation.y);
			ret.startRotation[2]  		= ParticleConfig.getData(config.startRotation.z);
			ret.startSize		  		= ParticleConfig.getData(config.startSize);
			ret.startSpeed		  		= ParticleConfig.getData(config.startSpeed);
			ret.userData.lifetimeData 	= config.lifetimeData;	// lifetimeData由IDE自己去组装
			return ret;
		}
		
	}
}
