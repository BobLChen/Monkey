package monkey.core.parser {

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	import monkey.core.entities.Mesh3D;
	import monkey.core.shader.Shader3D;

	public class OBJParser extends EventDispatcher {
		
		public static const defaultColor : uint = 0xc8c8c8;

		private var _textData : String;
		private var _startedParsing : Boolean;
		private var _charIndex : uint;
		private var _oldIndex : uint;
		private var _stringLength : uint;
		private var _currentObject : ObjectGroup;
		private var _currentGroup : Group;
		private var _currentMaterialGroup : MaterialGroup;
		private var _objects : Vector.<ObjectGroup>;
		private var _materialIDs : Vector.<String>;
		private var _materialLoaded : Vector.<LoadedMaterial>;
		private var _materialSpecularData : Vector.<SpecularData>;
		private var _meshes : Vector.<Mesh3D>;
		private var _lastMtlID : String;
		private var _objectIndex : uint;
		private var _realIndices : Array;
		private var _vertexIndex : uint;
		private var _vertices : Vector.<Vertex>;
		private var _vertexNormals : Vector.<Vertex>;
		private var _uvs : Vector.<UV>;
		private var _scale : Number;
		private var _mtlLib : Boolean;
		private var _mtlLibLoaded : Boolean = true;
		private var _activeMaterialID : String = "";
		private var _data : Object;
		
		public var pivot : Pivot3D;

		public function OBJParser(scale : Number = 1) {
			_scale = scale;
		}

		public function set scale(value : Number) : void {
			_scale = value;
		}

		protected function getTextData() : String {
			return ParserUtil.toString(_data);
		}
		
		public function proceedParsing(data : String) : Boolean {
			
			this._data = data;
			
			var line : String;
			var creturn : String = String.fromCharCode(10);
			var trunk : Array;
			
			if (!_startedParsing) {
				_textData = getTextData();
				_textData = _textData.replace(/\\[\r\n]+\s*/gm, ' ');
			}
			
			if (_textData.indexOf(creturn) == -1)
				creturn = String.fromCharCode(13);

			if (!_startedParsing) {
				_startedParsing = true;
				_vertices = new Vector.<Vertex>();
				_vertexNormals = new Vector.<Vertex>();
				_materialIDs = new Vector.<String>();
				_materialLoaded = new Vector.<LoadedMaterial>();
				_meshes = new Vector.<Mesh3D>();
				_uvs = new Vector.<UV>();
				_stringLength = _textData.length;
				_charIndex = _textData.indexOf(creturn, 0);
				_oldIndex = 0;
				_objects = new Vector.<ObjectGroup>();
				_objectIndex = 0;
			}

			while (_charIndex < _stringLength) {
				_charIndex = _textData.indexOf(creturn, _oldIndex);

				if (_charIndex == -1)
					_charIndex = _stringLength;

				line = _textData.substring(_oldIndex, _charIndex);
				line = line.split('\r').join("");
				line = line.replace("  ", " ");
				trunk = line.split(" ");
				_oldIndex = _charIndex + 1;
				parseLine(trunk);
				
			}
			
			if (_charIndex >= _stringLength) {
				translate();
				return true;
			}
			return true;
		}

		private function parseLine(trunk : Array) : void {
			switch (trunk[0]) {
				case "mtllib":
					_mtlLib = true;
					_mtlLibLoaded = false;
					break;
				case "g":
					createGroup(trunk);
					break;
				case "o":
					createObject(trunk);
					break;
				case "usemtl":
					if (_mtlLib) {
						if (!trunk[1])
							trunk[1] = "def000";
						_materialIDs.push(trunk[1]);
						_activeMaterialID = trunk[1];

						if (_currentGroup)
							_currentGroup.materialID = _activeMaterialID;
					}
					break;
				case "v":
					parseVertex(trunk);
					break;
				case "vt":
					parseUV(trunk);
					break;
				case "vn":
					parseVertexNormal(trunk);
					break;
				case "f":
					parseFace(trunk);
			}
		}

		/**
		 * Converts the parsed data into an Away3D scenegraph structure
		 */
		private function translate() : void {
			
			pivot = new Pivot3D();
			
			for (var objIndex : int = 0; objIndex < _objects.length; ++objIndex) {
				
				var groups : Vector.<Group> = _objects[objIndex].groups;
				var numGroups : uint = groups.length;
				var materialGroups : Vector.<MaterialGroup>;
				var numMaterialGroups : uint;
								
				var m : uint;
				var sm : uint;
				var bmMaterial : Shader3D = new Shader3D();
				
				for (var g : uint = 0; g < numGroups; ++g) {
					materialGroups = groups[g].materialGroups;
					var group : Group = groups[g];
					numMaterialGroups = materialGroups.length;
					for (m = 0; m < numMaterialGroups; ++m) {
						var mesh : Mesh3D = translateMaterialGroup(materialGroups[m]);
						mesh.userData = {};
						mesh.userData.matID = group.materialID;
						pivot.addChild(mesh);
					}
					if (_objects[objIndex].name) {
						mesh.name = _objects[objIndex].name;
					} else if (groups[g].name) {
						mesh.name = groups[g].name;
					} else {
						mesh.name = "";
					}
					_meshes.push(mesh);
				}
			}
			
			this.dispatchEvent(new Event(Event.COMPLETE));
		}

		private function translateMaterialGroup(materialGroup : MaterialGroup) : Mesh3D {
			var faces : Vector.<FaceData> = materialGroup.faces;
			var face : FaceData;
			var numFaces : uint = faces.length;
			var numVerts : uint;
			var subs : Vector.<Geometry3D>;
			
			var vertices : Vector.<Number> = new Vector.<Number>();
			var uvs : Vector.<Number> = new Vector.<Number>();
			var normals : Vector.<Number> = new Vector.<Number>();
			var indices : Vector.<uint> = new Vector.<uint>();

			_realIndices = [];
			_vertexIndex = 0;

			var j : uint;

			for (var i : uint = 0; i < numFaces; ++i) {
				face = faces[i];
				numVerts = face.indexIds.length - 1;

				for (j = 1; j < numVerts; ++j) {
					translateVertexData(face, j, vertices, uvs, indices, normals);
					translateVertexData(face, 0, vertices, uvs, indices, normals);
					translateVertexData(face, j + 1, vertices, uvs, indices, normals);
				}
			}
			
			var size : int = 8;
			var nidx : int = 0;
			var nrm10 : Vector3D = new Vector3D();
			var nrm20 : Vector3D = new Vector3D();
			var p0 : Vector3D = new Vector3D();
			var p1 : Vector3D = new Vector3D();
			var p2 : Vector3D = new Vector3D();
			
			if (vertices.length > 0) {
				var mesh : Mesh3D = new Mesh3D();
				var surf : Geometry3D = null;
				for (i = 0; i < indices.length; i++) {
					if (surf == null || surf.vertexVector.length / surf.sizePerVertex >= 65532) {
						surf = new Geometry3D();
						surf.setVertexDataType(Geometry3D.POSITION, 3);
						surf.setVertexDataType(Geometry3D.NORMAL, 3);
						surf.setVertexDataType(Geometry3D.UV0, 2);
						surf.vertexVector = new Vector.<Number>();
						surf.shader = new Shader3D();
						mesh.geometries.push(surf);
					}
					nidx++;
					
					surf.vertexVector.push(
						vertices[indices[i] * 3 + 0],
						vertices[indices[i] * 3 + 1], 
						vertices[indices[i] * 3 + 2], 
						0, 0, 0, 
						uvs[indices[i] * 2 + 0], 
						uvs[indices[i] * 2 + 1]
					);
					
					
					if (nidx == 3) {
						p0.setTo(vertices[indices[i-2] * 3 + 0], vertices[indices[i-2] * 3 + 1], vertices[indices[i-2] * 3 + 2]);
						p1.setTo(vertices[indices[i-1] * 3 + 0], vertices[indices[i-1] * 3 + 1], vertices[indices[i-1] * 3 + 2]);
						p2.setTo(vertices[indices[i-0] * 3 + 0], vertices[indices[i-0] * 3 + 1], vertices[indices[i-0] * 3 + 2]);
						nrm10.x = p1.x - p0.x;
						nrm10.y = p1.y - p0.y;
						nrm10.z = p1.z - p0.z;
						nrm20.x = p2.x - p0.x;
						nrm20.y = p2.y - p0.y;
						nrm20.z = p2.z - p0.z;
						var normal : Vector3D = nrm10.crossProduct(nrm20);
						normal.normalize();
						var idx : int = surf.vertexVector.length / surf.sizePerVertex;
						surf.vertexVector[(idx-3) * 8 + 3] = normal.x;
						surf.vertexVector[(idx-3) * 8 + 4] = normal.y;
						surf.vertexVector[(idx-3) * 8 + 5] = normal.z;
						surf.vertexVector[(idx-2) * 8 + 3] = normal.x;
						surf.vertexVector[(idx-2) * 8 + 4] = normal.y;
						surf.vertexVector[(idx-2) * 8 + 5] = normal.z;
						surf.vertexVector[(idx-1) * 8 + 3] = normal.x;
						surf.vertexVector[(idx-1) * 8 + 4] = normal.y;
						surf.vertexVector[(idx-1) * 8 + 5] = normal.z;
						nidx = 0;
					}
					
				}
				
				return mesh;
			}
			return new Mesh3D();
		}

		private function translateVertexData(face : FaceData, vertexIndex : int, vertices : Vector.<Number>, uvs : Vector.<Number>, indices : Vector.<uint>, normals : Vector.<Number>) : void {
			var index : uint;
			var vertex : Vertex;
			var vertexNormal : Vertex;
			var uv : UV;

			if (!_realIndices[face.indexIds[vertexIndex]]) {
				index = _vertexIndex;
				_realIndices[face.indexIds[vertexIndex]] = ++_vertexIndex;
				vertex = _vertices[face.vertexIndices[vertexIndex] - 1];
				vertices.push(vertex.x * _scale, vertex.y * _scale, vertex.z * _scale);

				if (face.normalIndices.length > 0) {
					vertexNormal = _vertexNormals[face.normalIndices[vertexIndex] - 1];
					normals.push(vertexNormal.x, vertexNormal.y, vertexNormal.z);
				}

				if (face.uvIndices.length > 0) {

					try {
						uv = _uvs[face.uvIndices[vertexIndex] - 1];
						uvs.push(uv.u, uv.v);

					} catch (e : Error) {

						switch (vertexIndex) {
							case 0:
								uvs.push(0, 1);
								break;
							case 1:
								uvs.push(.5, 0);
								break;
							case 2:
								uvs.push(1, 1);
						}
					}

				}

			} else
				index = _realIndices[face.indexIds[vertexIndex]] - 1;

			indices.push(index);
		}

		private function createObject(trunk : Array) : void {
			_currentGroup = null;
			_currentMaterialGroup = null;
			_objects.push(_currentObject = new ObjectGroup());

			if (trunk)
				_currentObject.name = trunk[1];
		}

		private function createGroup(trunk : Array) : void {
			if (!_currentObject)
				createObject(null);
			_currentGroup = new Group();

			_currentGroup.materialID = _activeMaterialID;

			if (trunk)
				_currentGroup.name = trunk[1];
			_currentObject.groups.push(_currentGroup);

			createMaterialGroup(null);
		}

		private function createMaterialGroup(trunk : Array) : void {
			_currentMaterialGroup = new MaterialGroup();

			if (trunk)
				_currentMaterialGroup.url = trunk[1];
			_currentGroup.materialGroups.push(_currentMaterialGroup);
		}

		private function parseVertex(trunk : Array) : void {
			if (trunk.length > 4) {
				var nTrunk : Array = [];
				var val : Number;
				for (var i : uint = 1; i < trunk.length; ++i) {
					val = parseFloat(trunk[i]);

					if (!isNaN(val))
						nTrunk.push(val);
				}
				_vertices.push(new Vertex(nTrunk[0], nTrunk[1], -nTrunk[2]));
			} else
				_vertices.push(new Vertex(parseFloat(trunk[1]), parseFloat(trunk[2]), -parseFloat(trunk[3])));

		}

		private function parseUV(trunk : Array) : void {
			if (trunk.length > 3) {
				var nTrunk : Array = [];
				var val : Number;

				for (var i : uint = 1; i < trunk.length; ++i) {
					val = parseFloat(trunk[i]);

					if (!isNaN(val))
						nTrunk.push(val);
				}
				_uvs.push(new UV(nTrunk[0], 1 - nTrunk[1]));

			} else
				_uvs.push(new UV(parseFloat(trunk[1]), 1 - parseFloat(trunk[2])));

		}

		private function parseVertexNormal(trunk : Array) : void {
			if (trunk.length > 4) {
				var nTrunk : Array = [];
				var val : Number;

				for (var i : uint = 1; i < trunk.length; ++i) {
					val = parseFloat(trunk[i]);

					if (!isNaN(val))
						nTrunk.push(val);
				}
				_vertexNormals.push(new Vertex(nTrunk[0], nTrunk[1], -nTrunk[2]));

			} else
				_vertexNormals.push(new Vertex(parseFloat(trunk[1]), parseFloat(trunk[2]), -parseFloat(trunk[3])));
		}

		private function parseFace(trunk : Array) : void {
			var len : uint = trunk.length;
			var face : FaceData = new FaceData();

			if (!_currentGroup)
				createGroup(null);

			var indices : Array;

			for (var i : uint = 1; i < len; ++i) {
				if (trunk[i] == "")
					continue;
				indices = trunk[i].split("/");
				face.vertexIndices.push(parseIndex(parseInt(indices[0]), _vertices.length));

				if (indices[1] && String(indices[1]).length > 0)
					face.uvIndices.push(parseIndex(parseInt(indices[1]), _uvs.length));

				if (indices[2] && String(indices[2]).length > 0)
					face.normalIndices.push(parseIndex(parseInt(indices[2]), _vertexNormals.length));
				face.indexIds.push(trunk[i]);
			}

			_currentMaterialGroup.faces.push(face);
		}

		private function parseIndex(index : int, length : uint) : int {
			if (index < 0)
				return index + length + 1;
			else
				return index;
		}

		public function parseMtl(data : String) : Dictionary {
			
			var dict : Dictionary = new Dictionary();
			
			var materialDefinitions : Array = data.split('newmtl');
			var lines : Array;
			var trunk : Array;
			var j : uint;
			
			var useSpecular : Boolean;
			var useColor : Boolean;
			var diffuseColor : uint;
			var ambientColor : uint;
			var specularColor : uint;
			var specular : Number;
			var alpha : Number;
			var mapkd : String;

			for (var i : uint = 0; i < materialDefinitions.length; ++i) {

				lines = (materialDefinitions[i].split('\r') as Array).join("").split('\n');

				if (lines.length == 1)
					lines = materialDefinitions[i].split(String.fromCharCode(13));

				diffuseColor = ambientColor = specularColor = 0xFFFFFF;
				specular = 0;
				useSpecular = false;
				useColor = false;
				alpha = 1;
				mapkd = "";

				for (j = 0; j < lines.length; ++j) {
					lines[j] = lines[j].replace(/\s+$/, "");

					if (lines[j].substring(0, 1) != "#" && (j == 0 || lines[j] != "")) {
						trunk = lines[j].split(" ");

						if (String(trunk[0]).charCodeAt(0) == 9 || String(trunk[0]).charCodeAt(0) == 32)
							trunk[0] = trunk[0].substring(1, trunk[0].length);

						if (j == 0) {
							_lastMtlID = trunk.join("");
							_lastMtlID = (_lastMtlID == "") ? "def000" : _lastMtlID;
							
						} else {

							switch (trunk[0]) {

								case "Ka":
									if (trunk[1] && !isNaN(Number(trunk[1])) && trunk[2] && !isNaN(Number(trunk[2])) && trunk[3] && !isNaN(Number(trunk[3])))
										ambientColor = trunk[1] * 255 << 16 | trunk[2] * 255 << 8 | trunk[3] * 255;
									break;

								case "Ks":
									if (trunk[1] && !isNaN(Number(trunk[1])) && trunk[2] && !isNaN(Number(trunk[2])) && trunk[3] && !isNaN(Number(trunk[3]))) {
										specularColor = trunk[1] * 255 << 16 | trunk[2] * 255 << 8 | trunk[3] * 255;
										useSpecular = true;
									}
									break;

								case "Ns":
									if (trunk[1] && !isNaN(Number(trunk[1])))
										specular = Number(trunk[1]) * 0.001;
									if (specular == 0)
										useSpecular = false;
									break;

								case "Kd":
									if (trunk[1] && !isNaN(Number(trunk[1])) && trunk[2] && !isNaN(Number(trunk[2])) && trunk[3] && !isNaN(Number(trunk[3]))) {
										diffuseColor = trunk[1] * 255 << 16 | trunk[2] * 255 << 8 | trunk[3] * 255;
										useColor = true;
									}
									break;

								case "tr":
								case "d":
									if (trunk[1] && !isNaN(Number(trunk[1])))
										alpha = Number(trunk[1]);
									break;

								case "map_Kd":
									mapkd = parseMapKdString(trunk);
									mapkd = mapkd.replace(/\\/g, "/");
									var arr : Array = mapkd.split("/");
									dict[_lastMtlID] = arr[arr.length - 1];
							}
						}
					}
				}
			}
			
			_mtlLibLoaded = true;
			
			return dict;
		}

		private function parseMapKdString(trunk : Array) : String {
			var url : String = "";
			var i : int;
			var breakflag : Boolean;

			for (i = 1; i < trunk.length; ) {
				switch (trunk[i]) {
					case "-blendu":
					case "-blendv":
					case "-cc":
					case "-clamp":
					case "-texres":
						i += 2; //Skip ahead 1 attribute
						break;
					case "-mm":
						i += 3; //Skip ahead 2 attributes
						break;
					case "-o":
					case "-s":
					case "-t":
						i += 4; //Skip ahead 3 attributes
						continue;
					default:
						breakflag = true;
						break;
				}

				if (breakflag)
					break;
			}
			
			//Reconstruct URL/filename
			for (i; i < trunk.length; i++) {
				url += trunk[i];
				url += " ";
			}

			//Remove the extraneous space and/or newline from the right side
			url = url.replace(/\s+$/, "");

			return url;
		}
		
	}
}



class ObjectGroup {
	public var name : String;
	public var groups : Vector.<Group> = new Vector.<Group>();

	public function ObjectGroup() {
	}
}

class Group {
	public var name : String;
	public var materialID : String;
	public var materialGroups : Vector.<MaterialGroup> = new Vector.<MaterialGroup>();

	public function Group() {
	}
}

class MaterialGroup {
	public var url : String;
	public var faces : Vector.<FaceData> = new Vector.<FaceData>();

	public function MaterialGroup() {
	}
}

class SpecularData {
	public var materialID : String;
	public var ambientColor : uint = 0xFFFFFF;
	public var alpha : Number = 1;

	public function SpecularData() {
	}
}

class LoadedMaterial {

	public var materialID : String;
	public var ambientColor : uint = 0xFFFFFF;
	public var alpha : Number = 1;

	public function LoadedMaterial() {
	}
}

class FaceData {
	public var vertexIndices : Vector.<uint> = new Vector.<uint>();
	public var uvIndices : Vector.<uint> = new Vector.<uint>();
	public var normalIndices : Vector.<uint> = new Vector.<uint>();
	public var indexIds : Vector.<String> = new Vector.<String>(); // used for real index lookups

	public function FaceData() {
	}
}
