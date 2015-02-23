package ide.plugins {

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import L3D.core.base.Pivot3D;
	import L3D.core.entities.Mesh3D;
	import L3D.core.entities.primitives.Particles3D;
	import L3D.core.entities.primitives.SkyBox;
	import L3D.core.entities.primitives.Water;
	import L3D.core.scene.Scene3D;
	import L3D.navmesh.NavigationMesh;
	
	import ide.Studio;
	import L3D.utils.ExportImportUtils;
	import L3D.utils.Zip;
	
	import ide.App;
	import ui.core.container.Box;
	import ui.core.container.MenuCombox;
	import ui.core.interfaces.IPlugin;

	public class ExportPlugin implements IPlugin {

		private var _app : App;
		private var _bar : Box;

		public function ExportPlugin() {

		}

		public function init(app : App) : void {
			this._app = app;
			this._bar = this._app.ui.getPanel(Studio.SCENE_MENU) as Box;
			var menu : MenuCombox = new MenuCombox("Export");
			menu.addMenuItem("Particles", 	exportParticles);
			menu.addMenuItem("Water",   	exportWater);
			menu.addMenuItem("Skybox",  	exportSkybox);
			menu.addMenuItem("Navmesh", 	exportNavmesh);
			menu.addMenuItem("Config", 		exportConfig);
			menu.minWidth = 60;
			this._bar.addControl(menu);
			this._bar.draw();
		}
		
		private function exportConfig(e : MouseEvent) : void {
			
			var fr : FileReference = new FileReference();
			var config : String = "";
			
			if (_app.selection.main is Water) {
				
			} else if (_app.selection.main is SkyBox) {
				
			} else if (_app.selection.main is Particles3D) {
				
			} else if (_app.selection.main is Mesh3D) {
				config = ExportImportUtils.exportMeshConfig(this._app.selection.main as Mesh3D);
				fr.save(config);
			}
			
		}
		
		private function exportNavmesh(e : MouseEvent) : void {
			if (this._app.selection.main is NavigationMesh) {
				var fr : FileReference = new FileReference();
				fr.save(ExportImportUtils.exportNavmesh(this._app.selection.main as NavigationMesh));
			}
		}
		
		private function exportSkybox(e : MouseEvent) : void {
			if (this._app.selection.main == null || this._app.selection.main is Scene3D)
				return;
			if (this._app.selection.main is SkyBox) {
				var fr : FileReference = new FileReference();
				fr.save(ExportImportUtils.exportSkybox(this._app.selection.main as SkyBox));
			}
		}
		
		private function exportWater(e : MouseEvent) : void {
			if (this._app.selection.main == null || this._app.selection.main is Scene3D)
				return;
			if (this._app.selection.main is Water) {
				var fr : FileReference = new FileReference();
				fr.save(ExportImportUtils.exportWater(this._app.selection.main as Water));
			}
		}
		
		private function exportParticles(e : MouseEvent) : void {
			if (this._app.selection.main == null || this._app.selection.main is Scene3D)
				return;
			
			var dict : Dictionary = new Dictionary();
			var pivot : Pivot3D = this._app.selection.main;
			var zip : Zip = new Zip();
			// 获取配置文件
			var config : String = ExportImportUtils.exportParticleConfig(pivot);
			zip.addString("particle.config", config);
			// 获取粒子数据data以及贴图
			if (pivot is Particles3D) {
				dict[pivot.userData.id] = true; // id 为uuid不可能重复
				zip.addFile(pivot.userData.id, ExportImportUtils.exportParticlesData(pivot as Particles3D));
				// 不保存重名texture
				if (dict[pivot.userData.textureID] == undefined) {
					zip.addFile(pivot.userData.textureID, ExportImportUtils.bitmapdataToByteArray((pivot as Particles3D).texture.bitmapData));
					dict[pivot.userData.textureID] = true;
				}
				// 不保存重名blendTexture
				if (Particles3D(pivot).blendTexture != null) {
					if (dict[pivot.userData.blendTextureID] == undefined) {
						zip.addFile(pivot.userData.blendTextureID, ExportImportUtils.bitmapdataToByteArray((pivot as Particles3D).blendTexture.bitmapData));
						dict[pivot.userData.blendTextureID] = true;
					}
				}
			}
			
			pivot.forEach(function(particle : Particles3D) : void {
				dict[particle.userData.id] = true;
				zip.addFile(particle.userData.id, ExportImportUtils.exportParticlesData(particle));
				// 不保存重名texture
				if (dict[particle.userData.textureID] == undefined) {
					zip.addFile(particle.userData.textureID, ExportImportUtils.bitmapdataToByteArray(particle.texture.bitmapData));
					dict[particle.userData.textureID] = true;
				}
				if (particle.blendTexture != null) {
					if (dict[particle.userData.blendTextureID] == undefined) {
						zip.addFile(particle.userData.blendTextureID, ExportImportUtils.bitmapdataToByteArray(particle.blendTexture.bitmapData));
						dict[particle.userData.blendTextureID] = true;
					}
				}
			}, Particles3D);
			
			var data : ByteArray = new ByteArray();
			zip.serialize(data);
			var fr : FileReference = new FileReference();
			fr.save(data);
		}
		
		public function start() : void {

		}
	}
}
