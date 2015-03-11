package monkey.core.parser {

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.Timer;
	
	import monkey.core.base.Object3D;
	import monkey.core.base.Surface3D;
	import monkey.core.entities.Mesh3D;
	import monkey.core.materials.ColorMaterial;
	import monkey.core.parser.utils.ParserUtil;
	import monkey.core.renderer.MeshRenderer;
	import monkey.core.shader.Shader3D;
	import monkey.core.utils.Color;

	public class Max3DSParser extends EventDispatcher {

		private static const ImgTypeFilter : Array = [".png", ".PNG", ".jpg", ".JPG", ".JPEG", ".jpeg"];
		
		private var _byteData : ByteArray;
		
		private var _textures : Object;
		private var _materials : Object;
		private var _unfinalized_objects : Object;

		private var _cur_obj_end : uint;
		private var _cur_obj : ObjectVO;

		private var _cur_mat_end : uint;
		private var _cur_mat : MaterialVO;
		private var _useSmoothingGroups : Boolean;

		protected var _fileName : String;
		protected var _dataFormat : String;
		protected var _data : *;
		protected var _frameLimit : Number;
		protected var _lastFrameTime : Number;

		private var _parsingPaused : Boolean;
		private var _parsingComplete : Boolean;
		private var _parsingFailure : Boolean;
		private var _timer : Timer;
		private var _materialMode : uint;
		
		public var pivot : Object3D;
		private var materialMode:int = 0;
		private var _parentDir : String;
		
		public var defaultColor : uint = 0xc8c8c8;
		
		public function Max3DSParser(data : Object, parentDir : String, useSmoothingGroups : Boolean = true) {
			_parentDir = parentDir;
			_useSmoothingGroups = useSmoothingGroups;
			_data = data;
			pivot = new Object3D();
		}

		public function get materials():Object {
			return _materials;
		}

		public function startParsing() : void {
			_byteData = ParserUtil.toByteArray(_data);
			_byteData.position = 0;
			_byteData.endian = Endian.LITTLE_ENDIAN;
			_textures = {};
			_materials = {};
			_unfinalized_objects = {};
			proceedParsing();
		}

		private function proceedParsing() : Boolean {

			while (true) {

				if (_cur_mat && _byteData.position >= _cur_mat_end)
					finalizeCurrentMaterial();
				else if (_cur_obj && _byteData.position >= _cur_obj_end) {
					_unfinalized_objects[_cur_obj.name] = _cur_obj;
					_cur_obj_end = uint.MAX_VALUE;
					_cur_obj = null;
				}

				if (_byteData.bytesAvailable) {
					var cid : uint;
					var len : uint;
					var end : uint;

					cid = _byteData.readUnsignedShort();
					len = _byteData.readUnsignedInt();
					end = _byteData.position + (len - 6);

					switch (cid) {
						case 0x4D4D: // MAIN3DS
						case 0x3D3D: // EDIT3DS
						case 0xB000: // KEYF3DS
							continue;
							break;

						case 0xAFFF: // MATERIAL
							_cur_mat_end = end;
							_cur_mat = parseMaterial();
							break;

						case 0x4000: // EDIT_OBJECT
							_cur_obj_end = end;
							_cur_obj = new ObjectVO();
							_cur_obj.name = readNulTermString();
							_cur_obj.materials = new Vector.<String>();
							_cur_obj.materialFaces = {};
							break;

						case 0x4100: // OBJ_TRIMESH 
							_cur_obj.type = "MESH";
							break;

						case 0x4110: // TRI_VERTEXL
							parseVertexList();
							break;

						case 0x4120: // TRI_FACELIST
							parseFaceList();
							break;

						case 0x4140: // TRI_MAPPINGCOORDS
							parseUVList();
							break;

						case 0x4130: // Face materials
							parseFaceMaterialList();
							break;

						case 0x4160: // Transform
							_cur_obj.transform = readTransform();
							break;

						case 0xB002: // Object animation (including pivot)
							parseObjectAnimation(end);
							break;

						case 0x4150: // Smoothing groups
							parseSmoothingGroups();
							break;

						default:
							// Skip this (unknown) chunk
							_byteData.position += (len - 6);
							break;
					}

				} else {
					break;
				}
			}
			
			var name : String;

			for (name in _unfinalized_objects) {
				var mesh : Object3D = constructObject(_unfinalized_objects[name]);
				if (mesh)
					finalizeAsset(mesh, name);
			}
			
			this.dispatchEvent(new Event(Event.COMPLETE));
			return true;
		}
		
		private function finalizeCurrentMaterial() : void {
			_materials[_cur_mat.name] = _cur_mat;
			_cur_mat = null;
		}
		
		protected function finalizeAsset(mesh : Object3D, name : String = null) : void {
			var type_event : String;
			var type_name : String;
			
			if (name != null)
				mesh.name = name;

			if (!mesh.name)
				mesh.name = type_name;
			
			pivot.addChild(mesh);
		}
		
		private function parseMaterial() : MaterialVO {
			var mat : MaterialVO;
			mat = new MaterialVO();

			while (_byteData.position < _cur_mat_end) {
				var cid : uint;
				var len : uint;
				var end : uint;

				cid = _byteData.readUnsignedShort();
				len = _byteData.readUnsignedInt();
				end = _byteData.position + (len - 6);

				switch (cid) {
					case 0xA000: // Material name
						mat.name = readNulTermString();
						break;

					case 0xA010: // Ambient color
						mat.ambientColor = readColor();
						break;

					case 0xA020: // Diffuse color
						mat.diffuseColor = readColor();
						break;

					case 0xA030: // Specular color
						mat.specularColor = readColor();
						break;

					case 0xA081: // Two-sided, existence indicates "true"
						mat.twoSided = true;
						break;

					case 0xA200: // Main (color) texture 
						mat.colorMap = parseTexture(end);
						break;

					case 0xA204: // Specular map
						mat.specularMap = parseTexture(end);
						break;

					default:
						_byteData.position = end;
						break;
				}
			}
			
			return mat;
		}

		private function parseTexture(end : uint) : TextureVO {
			var tex : TextureVO;

			tex = new TextureVO();

			while (_byteData.position < end) {
				var cid : uint;
				var len : uint;

				cid = _byteData.readUnsignedShort();
				len = _byteData.readUnsignedInt();

				switch (cid) {
					case 0xA300:
						tex.url = readNulTermString();
						break;

					default:
						// Skip this unknown texture sub-chunk
						_byteData.position += (len - 6);
						break;
				}
			}

			_textures[tex.url] = tex;

			return tex;
		}

		private function parseVertexList() : void {
			var i : uint;
			var len : uint;
			var count : uint;

			count = _byteData.readUnsignedShort();
			_cur_obj.verts = new Vector.<Number>(count * 3, true);

			i = 0;
			len = _cur_obj.verts.length;

			while (i < len) {
				var x : Number, y : Number, z : Number;

				x = _byteData.readFloat();
				y = _byteData.readFloat();
				z = _byteData.readFloat();

				_cur_obj.verts[i++] = x;
				_cur_obj.verts[i++] = z;
				_cur_obj.verts[i++] = y;

			}
		}

		private function parseFaceList() : void {
			var i : uint;
			var len : uint;
			var count : uint;

			count = _byteData.readUnsignedShort();
			_cur_obj.indices = new Vector.<uint>(count * 3, true);

			i = 0;
			len = _cur_obj.indices.length;

			while (i < len) {
				var i0 : uint, i1 : uint, i2 : uint;

				i0 = _byteData.readUnsignedShort();
				i1 = _byteData.readUnsignedShort();
				i2 = _byteData.readUnsignedShort();

				_cur_obj.indices[i++] = i0;
				_cur_obj.indices[i++] = i2;
				_cur_obj.indices[i++] = i1;

				_byteData.position += 2;
			}

			_cur_obj.smoothingGroups = new Vector.<uint>(count, true);
		}

		private function parseSmoothingGroups() : void {
			var len : uint = _cur_obj.indices.length / 3;
			var i : uint = 0;

			while (i < len) {
				_cur_obj.smoothingGroups[i] = _byteData.readUnsignedInt();
				i++;
			}
		}

		private function parseUVList() : void {
			var i : uint;
			var len : uint;
			var count : uint;

			count = _byteData.readUnsignedShort();
			_cur_obj.uvs = new Vector.<Number>(count * 2, true);

			i = 0;
			len = _cur_obj.uvs.length;

			while (i < len) {
				_cur_obj.uvs[i++] = _byteData.readFloat();
				_cur_obj.uvs[i++] = 1.0 - _byteData.readFloat();
			}
		}

		private function parseFaceMaterialList() : void {
			var mat : String;
			var count : uint;
			var i : uint;
			var faces : Vector.<uint>;

			mat = readNulTermString();
			count = _byteData.readUnsignedShort();

			faces = new Vector.<uint>(count, true);
			i = 0;

			while (i < faces.length)
				faces[i++] = _byteData.readUnsignedShort();

			_cur_obj.materials.push(mat);
			_cur_obj.materialFaces[mat] = faces;
		}

		private function parseObjectAnimation(end : Number) : void {

			var vo : ObjectVO;
			var pivot : Vector3D;
			var name : String;
			var hier : int;

			pivot = new Vector3D;

			while (_byteData.position < end) {
				var cid : uint;
				var len : uint;

				cid = _byteData.readUnsignedShort();
				len = _byteData.readUnsignedInt();

				switch (cid) {
					case 0xb010: // Name/hierarchy
						name = readNulTermString();
						_byteData.position += 4;
						hier = _byteData.readShort();
						break;

					case 0xb013: // Pivot
						pivot.x = _byteData.readFloat();
						pivot.z = _byteData.readFloat();
						pivot.y = _byteData.readFloat();
						break;

					default:
						_byteData.position += (len - 6);
						break;
				}
			}
			
			if (name != '$$$DUMMY' && _unfinalized_objects.hasOwnProperty(name)) {
				vo = _unfinalized_objects[name];
				var mesh : Object3D = constructObject(vo, pivot);

				if (mesh)
					finalizeAsset(mesh, vo.name);

				delete _unfinalized_objects[name];
			}
		}

		private function constructObject(obj : ObjectVO, pivot : Vector3D = null) : Object3D {
			if (obj.type == "MESH") {
				
				var object3d : Object3D = new Object3D();
				
				var i : uint;
				var mat : Shader3D;
				var mesh : Mesh3D;
				var mtx : Matrix3D;
				var vertices : Vector.<VertexVO>;
				var faces : Vector.<FaceVO>;
				
				mesh = new Mesh3D([]);

				if (obj.materials.length > 1)
					trace('The Away3D 3DS parser does not support multiple materials per mesh at this point.');
				
				// Ignore empty objects
				if (!obj.indices || obj.indices.length == 0)
					return null;
				
				var mname : String = obj.materials[0];
				var vo : MaterialVO = _materials[mname];
				
				var shader : Shader3D = null;
				if (vo != null && vo.colorMap != null && vo.colorMap.url != null) {
					var isError : Boolean = true;
					for each (var type : String in ImgTypeFilter) {
						if (vo.colorMap.url.indexOf(type) != -1) {
							isError = false;
						}
					}
				}
				
				vertices = new Vector.<VertexVO>(obj.verts.length / 3, false);
				faces = new Vector.<FaceVO>(obj.indices.length / 3, true);
				
				prepareData(vertices, faces, obj);

				if (_useSmoothingGroups)
					applySmoothGroups(vertices, faces);

				obj.verts = new Vector.<Number>(vertices.length * 3, true);

				for (i = 0; i < vertices.length; i++) {
					obj.verts[i * 3] = vertices[i].x;
					obj.verts[i * 3 + 1] = vertices[i].y;
					obj.verts[i * 3 + 2] = vertices[i].z;
				}
				obj.indices = new Vector.<uint>(faces.length * 3, true);

				for (i = 0; i < faces.length; i++) {
					obj.indices[i * 3 + 0] = faces[i].a;
					obj.indices[i * 3 + 1] = faces[i].b;
					obj.indices[i * 3 + 2] = faces[i].c;
				}

				if (obj.uvs) {
					obj.uvs = new Vector.<Number>(vertices.length * 2, true);

					for (i = 0; i < vertices.length; i++) {
						obj.uvs[i * 2] = vertices[i].u;
						obj.uvs[i * 2 + 1] = vertices[i].v;
					}
				}

				var len : int = obj.indices.length;
				var idx : int = 0;
				var surf : Surface3D = null;
				var nidx : int = 0;
				var nrm10 : Vector3D = new Vector3D();
				var nrm20 : Vector3D = new Vector3D();
				var p0 : Vector3D = new Vector3D();
				var p1 : Vector3D = new Vector3D();
				var p2 : Vector3D = new Vector3D();
				
				for (i = 0; i < len; i++) {
					if (surf == null || surf.getVertexVector(Surface3D.POSITION).length / 3 >= 65532) {
						surf = new Surface3D();
						surf.setVertexVector(Surface3D.POSITION, new Vector.<Number>(), 3);
						surf.setVertexVector(Surface3D.NORMAL, new Vector.<Number>(), 3);
						surf.setVertexVector(Surface3D.UV0, new Vector.<Number>(), 2);
						surf.indexVector = new Vector.<uint>();
						mesh.surfaces.push(surf);
					}
					nidx++;
					
					surf.getVertexVector(Surface3D.POSITION).push(
						obj.verts[obj.indices[i] * 3 + 0], 
						obj.verts[obj.indices[i] * 3 + 1], 
						obj.verts[obj.indices[i] * 3 + 2]
					);
					
					surf.getVertexVector(Surface3D.UV0).push(
						obj.uvs[obj.indices[i] * 2 + 0], 
						obj.uvs[obj.indices[i] * 2 + 1]
					);
					
					if (nidx == 3) {
						p0.setTo(obj.verts[obj.indices[i-2] * 3 + 0], obj.verts[obj.indices[i-2] * 3 + 1], obj.verts[obj.indices[i-2] * 3 + 2]);
						p1.setTo(obj.verts[obj.indices[i-1] * 3 + 0], obj.verts[obj.indices[i-1] * 3 + 1], obj.verts[obj.indices[i-1] * 3 + 2]);
						p2.setTo(obj.verts[obj.indices[i-0] * 3 + 0], obj.verts[obj.indices[i-0] * 3 + 1], obj.verts[obj.indices[i-0] * 3 + 2]);
						nrm10.x = p1.x - p0.x;
						nrm10.y = p1.y - p0.y;
						nrm10.z = p1.z - p0.z;
						nrm20.x = p2.x - p0.x;
						nrm20.y = p2.y - p0.y;
						nrm20.z = p2.z - p0.z;
						var normal : Vector3D = nrm10.crossProduct(nrm20);
						normal.normalize();
						
						surf.getVertexVector(Surface3D.NORMAL).push(
							normal.x, normal.y, normal.z,
							normal.y, normal.y, normal.z,
							normal.x, normal.y, normal.z
						);
						
						nidx = 0;
					}
				}
				
				if (pivot) {
					if (obj.transform) {
						var dat : Vector.<Number> = obj.transform.concat();
						dat[12] = 0;
						dat[13] = 0;
						dat[14] = 0;
						mtx = new Matrix3D(dat);
						pivot = mtx.transformVector(pivot);
					}
					pivot.scaleBy(-1);
					mtx = new Matrix3D();
					mtx.appendTranslation(pivot.x, pivot.y, pivot.z);
					
					object3d.transform.local.copyFrom(mtx);
				}
			
				if (obj.transform) {
					mtx = new Matrix3D(obj.transform);
					mtx.invert();
				}
				
				for each (surf in mesh.surfaces) {
					len = surf.getVertexVector(Surface3D.POSITION).length / 3;
					for (i = 0; i < len; i++) {
						surf.indexVector.push(i);
					}
				}
				
				object3d.addComponent(new MeshRenderer(mesh, new ColorMaterial(Color.WHITE)));
				
				return object3d;
			}
				
			return null;
		}

		private function prepareData(vertices : Vector.<VertexVO>, faces : Vector.<FaceVO>, obj : ObjectVO) : void {
			var i : int;
			var j : int;
			var k : int;
			var len : int = obj.verts.length;

			for (i = 0, j = 0, k = 0; i < len; ) {
				var v : VertexVO = new VertexVO;
				v.x = obj.verts[i++];
				v.y = obj.verts[i++];
				v.z = obj.verts[i++];

				if (obj.uvs) {
					v.u = obj.uvs[j++];
					v.v = obj.uvs[j++];
				}
				vertices[k++] = v;
			}
			len = obj.indices.length;

			for (i = 0, k = 0; i < len; ) {
				var f : FaceVO = new FaceVO();
				f.a = obj.indices[i++];
				f.b = obj.indices[i++];
				f.c = obj.indices[i++];
				f.smoothGroup = obj.smoothingGroups[k];
				faces[k++] = f;
			}
		}

		private function applySmoothGroups(vertices : Vector.<VertexVO>, faces : Vector.<FaceVO>) : void {
			var i : int;
			var j : int;
			var k : int;
			var l : int;
			var len : int;
			var numVerts : uint = vertices.length;
			var numFaces : uint = faces.length;

			var vGroups : Vector.<Vector.<uint>> = new Vector.<Vector.<uint>>(numVerts, true);

			for (i = 0; i < numVerts; i++)
				vGroups[i] = new Vector.<uint>;

			for (i = 0; i < numFaces; i++) {
				var face : FaceVO = FaceVO(faces[i]);

				for (j = 0; j < 3; j++) {
					var groups : Vector.<uint> = vGroups[(j == 0) ? face.a : ((j == 1) ? face.b : face.c)];
					var group : uint = face.smoothGroup;

					for (k = groups.length - 1; k >= 0; k--) {
						if ((group & groups[k]) > 0) {
							group |= groups[k];
							groups.splice(k, 1);
							k = groups.length - 1;
						}
					}
					groups.push(group);
				}
			}
			var vClones : Vector.<Vector.<uint>> = new Vector.<Vector.<uint>>(numVerts, true);

			for (i = 0; i < numVerts; i++) {
				if ((len = vGroups[i].length) < 1)
					continue;
				var clones : Vector.<uint> = new Vector.<uint>(len, true);
				vClones[i] = clones;
				clones[0] = i;
				var v0 : VertexVO = vertices[i];

				for (j = 1; j < len; j++) {
					var v1 : VertexVO = new VertexVO;
					v1.x = v0.x;
					v1.y = v0.y;
					v1.z = v0.z;
					v1.u = v0.u;
					v1.v = v0.v;
					clones[j] = vertices.length;
					vertices.push(v1);
				}
			}
			numVerts = vertices.length;

			for (i = 0; i < numFaces; i++) {
				face = FaceVO(faces[i]);
				group = face.smoothGroup;

				for (j = 0; j < 3; j++) {
					k = (j == 0) ? face.a : ((j == 1) ? face.b : face.c);
					groups = vGroups[k];
					len = groups.length;
					clones = vClones[k];

					for (l = 0; l < len; l++) {
						if (((group == 0) && (groups[l] == 0)) || ((group & groups[l]) > 0)) {
							var index : uint = clones[l];

							if (group == 0) {
								groups.splice(l, 1);
								clones.splice(l, 1);
							}

							if (j == 0)
								face.a = index;
							else if (j == 1)
								face.b = index;
							else
								face.c = index;
							l = len;
						}
					}
				}
			}
		}

		private function readNulTermString() : String {
			var chr : uint;
			var str : String = new String();

			while ((chr = _byteData.readUnsignedByte()) > 0)
				str += String.fromCharCode(chr);

			return str;
		}

		private function readTransform() : Vector.<Number> {
			var data : Vector.<Number>;

			data = new Vector.<Number>(16, true);

			// X axis
			data[0] = _byteData.readFloat(); // X
			data[2] = _byteData.readFloat(); // Z
			data[1] = _byteData.readFloat(); // Y
			data[3] = 0;

			// Z axis
			data[8] = _byteData.readFloat(); // X
			data[10] = _byteData.readFloat(); // Z
			data[9] = _byteData.readFloat(); // Y
			data[11] = 0;

			// Y Axis
			data[4] = _byteData.readFloat(); // X 
			data[6] = _byteData.readFloat(); // Z
			data[5] = _byteData.readFloat(); // Y
			data[7] = 0;

			// Translation
			data[12] = _byteData.readFloat(); // X
			data[14] = _byteData.readFloat(); // Z
			data[13] = _byteData.readFloat(); // Y
			data[15] = 1;

			return data;
		}

		private function readColor() : uint {
			var cid : uint;
			var len : uint;
			var r : uint, g : uint, b : uint;

			cid = _byteData.readUnsignedShort();
			len = _byteData.readUnsignedInt();

			switch (cid) {
				case 0x0010: // Floats
					r = _byteData.readFloat() * 255;
					g = _byteData.readFloat() * 255;
					b = _byteData.readFloat() * 255;
					break;
				case 0x0011: // 24-bit color
					r = _byteData.readUnsignedByte();
					g = _byteData.readUnsignedByte();
					b = _byteData.readUnsignedByte();
					break;
				default:
					_byteData.position += (len - 6);
					break;
			}

			return (r << 16) | (g << 8) | b;
		}
	}
}
import flash.geom.Vector3D;

import monkey.core.shader.Shader3D;
import monkey.core.textures.Texture3D;

internal class TextureVO {
	public var url : String;
	public var texture : Texture3D;

	public function TextureVO() {
	}
}

internal class MaterialVO {

	public var name : String;
	public var ambientColor : uint;
	public var diffuseColor : uint;
	public var specularColor : uint;
	public var twoSided : Boolean;
	public var colorMap : TextureVO;
	public var specularMap : TextureVO;
	public var material : Shader3D;

	public function MaterialVO() {
	}
}

internal class ObjectVO {

	public var name : String;
	public var type : String;
	public var pivotX : Number;
	public var pivotY : Number;
	public var pivotZ : Number;
	public var transform : Vector.<Number>;
	public var verts : Vector.<Number>;
	public var indices : Vector.<uint>;
	public var uvs : Vector.<Number>;
	public var materialFaces : Object;
	public var materials : Vector.<String>;
	public var smoothingGroups : Vector.<uint>;

	public function ObjectVO() {
	}
}

internal class VertexVO {
	public var x : Number;
	public var y : Number;
	public var z : Number;
	public var u : Number;
	public var v : Number;
	public var normal : Vector3D;
	public var tangent : Vector3D;

	public function VertexVO() {
	}
}

internal class FaceVO {
	public var a : uint;
	public var b : uint;
	public var c : uint;
	public var smoothGroup : uint;

	public function FaceVO() {
	}
}
