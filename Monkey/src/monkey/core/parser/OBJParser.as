package monkey.core.parser {

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	import monkey.core.base.Object3D;
	import monkey.core.base.Surface3D;
	import monkey.core.entities.Mesh3D;
	import monkey.core.materials.ColorMaterial;
	import monkey.core.parser.utils.ParserUtil;
	import monkey.core.renderer.MeshRenderer;
	import monkey.core.utils.Color;

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
		
		public var pivot : Object3D;

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
			
			pivot = new Object3D();
			pivot.name = "obj";
			
			for (var objIndex : int = 0; objIndex < _objects.length; ++objIndex) {
				
				var groups : Vector.<Group> = _objects[objIndex].groups;
				var numGroups : uint = groups.length;
				var materialGroups : Vector.<MaterialGroup>;
				var numMaterialGroups : uint;
								
				var m : uint;
				var sm : uint;
				
				for (var g : uint = 0; g < numGroups; ++g) {
					materialGroups = groups[g].materialGroups;
					var group : Group = groups[g];
					numMaterialGroups = materialGroups.length;
					for (m = 0; m < numMaterialGroups; ++m) {
						var mesh : Object3D = translateMaterialGroup(materialGroups[m]);
						pivot.addChild(mesh);
					}
					if (_objects[objIndex].name) {
						mesh.name = _objects[objIndex].name;
					} else if (groups[g].name) {
						mesh.name = groups[g].name;
					} else {
						mesh.name = "";
					}
				}
			}
			
			this.dispatchEvent(new Event(Event.COMPLETE));
		}

		private function translateMaterialGroup(materialGroup : MaterialGroup) : Object3D {
			var faces : Vector.<FaceData> = materialGroup.faces;
			var face : FaceData;
			var numFaces : uint = faces.length;
			var numVerts : uint;
			
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
				var mesh : Mesh3D = new Mesh3D([]);
				var surf : Surface3D = null;
				for (i = 0; i < indices.length; i++) {
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
						vertices[indices[i] * 3 + 0],
						vertices[indices[i] * 3 + 1], 
						vertices[indices[i] * 3 + 2]
					);
					
					surf.getVertexVector(Surface3D.UV0).push(
						uvs[indices[i] * 2 + 0], 
						uvs[indices[i] * 2 + 1]
					);
					
					if (normals.length > 0) {
						surf.getVertexVector(Surface3D.NORMAL).push(
							normals[indices[i] * 3 + 0],
							normals[indices[i] * 3 + 1], 
							normals[indices[i] * 3 + 2]
						);
					} else {
						surf.getVertexVector(Surface3D.NORMAL).push(0, 0, 0);
					}
										
					if (nidx == 3 && normals.length == 0) {
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
						var idx : int = surf.getVertexVector(Surface3D.NORMAL).length / 3;
						surf.getVertexVector(Surface3D.NORMAL)[(idx-3) * 3 + 0] = normal.x;
						surf.getVertexVector(Surface3D.NORMAL)[(idx-3) * 3 + 1] = normal.y;
						surf.getVertexVector(Surface3D.NORMAL)[(idx-3) * 3 + 2] = normal.z;
						
						surf.getVertexVector(Surface3D.NORMAL)[(idx-2) * 3 + 0] = normal.x;
						surf.getVertexVector(Surface3D.NORMAL)[(idx-2) * 3 + 1] = normal.y;
						surf.getVertexVector(Surface3D.NORMAL)[(idx-2) * 3 + 2] = normal.z;
						
						surf.getVertexVector(Surface3D.NORMAL)[(idx-1) * 3 + 0] = normal.x;
						surf.getVertexVector(Surface3D.NORMAL)[(idx-1) * 3 + 1] = normal.y;
						surf.getVertexVector(Surface3D.NORMAL)[(idx-1) * 3 + 2] = normal.z;
						nidx = 0;
					}
					
				}
				
				for each (surf in mesh.surfaces) {
					var len : int = surf.getVertexVector(Surface3D.POSITION).length / 3;
					for (i = 0; i < len; i++) {
						surf.indexVector.push(i);
					}
				}
				
				var obj : Object3D = new Object3D();
				obj.addComponent(new MeshRenderer(mesh, new ColorMaterial(Color.WHITE)));
				return obj;
			}
			return new Object3D();
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
import flash.geom.Point;
import flash.geom.Vector3D;



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

/**
 * Face value object.
 */
class Face {
	private static var _calcPoint : Point;
	
	private var _vertices : Vector.<Number>;
	private var _uvs : Vector.<Number>;
	private var _faceIndex : uint;
	private var _v0Index : uint;
	private var _v1Index : uint;
	private var _v2Index : uint;
	private var _uv0Index : uint;
	private var _uv1Index : uint;
	private var _uv2Index : uint;
	
	/**
	 * Creates a new <code>Face</code> value object.
	 *
	 * @param    vertices        [optional] 9 entries long Vector.&lt;Number&gt; representing the x, y and z of v0, v1, and v2 of a face
	 * @param    uvs            [optional] 6 entries long Vector.&lt;Number&gt; representing the u and v of uv0, uv1, and uv2 of a face
	 */
	function Face(vertices : Vector.<Number> = null, uvs : Vector.<Number> = null) {
		_vertices = vertices || Vector.<Number>([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]);
		_uvs = uvs || Vector.<Number>([0.0, 0.0, 0.0, 0.0, 0.0, 0.0]);
	}
	
	//uvs
	/**
	 * To set uv values for either uv0, uv1 or uv2.
	 * @param    index        The id of the uv (0, 1 or 2)
	 * @param    u            The horizontal coordinate of the texture value.
	 * @param    v            The vertical coordinate of the texture value.
	 */
	public function setUVat(index : uint, u : Number, v : Number) : void {
		var ind : uint = (index * 2);
		_uvs[ind] = u;
		_uvs[ind + 1] = v;
	}
	
	/**
	 * To store a temp index of a face during a loop
	 * @param    ind        The index
	 */
	public function set faceIndex(ind : uint) : void {
		_faceIndex = ind;
	}
	
	/**
	 * @return            Returns the tmp index set for this Face object
	 */
	public function get faceIndex() : uint {
		return _faceIndex;
	}
	
	//uv0
	/**
	 * the index set for uv0 in this Face value object
	 * @param    ind        The index
	 */
	public function set uv0Index(ind : uint) : void {
		_uv0Index = ind;
	}
	
	/**
	 * @return return the index set for uv0 in this Face value object
	 */
	public function get uv0Index() : uint {
		return _uv0Index;
	}
	
	/**
	 * uv0 u and v values
	 * @param    u        The u value
	 * @param    v        The v value
	 */
	public function setUv0Value(u : Number, v : Number) : void {
		_uvs[0] = u;
		_uvs[1] = v;
	}
	
	/**
	 * @return return the u value of the uv0 of this Face value object
	 */
	public function get uv0u() : Number {
		return _uvs[0];
	}
	
	/**
	 * @return return the v value of the uv0 of this Face value object
	 */
	public function get uv0v() : Number {
		return _uvs[1];
	}
	
	//uv1
	/**
	 * the index set for uv1 in this Face value object
	 * @param    ind        The index
	 */
	public function set uv1Index(ind : uint) : void {
		_uv1Index = ind;
	}
	
	/**
	 * @return Returns the index set for uv1 in this Face value object
	 */
	public function get uv1Index() : uint {
		return _uv1Index;
	}
	
	/**
	 * uv1 u and v values
	 * @param    u        The u value
	 * @param    v        The v value
	 */
	public function setUv1Value(u : Number, v : Number) : void {
		_uvs[2] = u;
		_uvs[3] = v;
	}
	
	/**
	 * @return Returns the u value of the uv1 of this Face value object
	 */
	public function get uv1u() : Number {
		return _uvs[2];
	}
	
	/**
	 * @return Returns the v value of the uv1 of this Face value object
	 */
	public function get uv1v() : Number {
		return _uvs[3];
	}
	
	//uv2
	/**
	 * the index set for uv2 in this Face value object
	 * @param    ind        The index
	 */
	public function set uv2Index(ind : uint) : void {
		_uv2Index = ind;
	}
	
	/**
	 * @return return the index set for uv2 in this Face value object
	 */
	public function get uv2Index() : uint {
		return _uv2Index;
	}
	
	/**
	 * uv2 u and v values
	 * @param    u        The u value
	 * @param    v        The v value
	 */
	public function setUv2Value(u : Number, v : Number) : void {
		_uvs[4] = u;
		_uvs[5] = v;
	}
	
	/**
	 * @return return the u value of the uv2 of this Face value object
	 */
	public function get uv2u() : Number {
		return _uvs[4];
	}
	
	/**
	 * @return return the v value of the uv2 of this Face value object
	 */
	public function get uv2v() : Number {
		return _uvs[5];
	}
	
	//vertices
	/**
	 * To set uv values for either v0, v1 or v2.
	 * @param    index        The id of the uv (0, 1 or 2)
	 * @param    x            The x value of the vertex.
	 * @param    y            The y value of the vertex.
	 * @param    z            The z value of the vertex.
	 */
	public function setVertexAt(index : uint, x : Number, y : Number, z : Number) : void {
		var ind : uint = (index * 3);
		_vertices[ind] = x;
		_vertices[ind + 1] = y;
		_vertices[ind + 2] = z;
	}
	
	//v0
	/**
	 * set the index value for v0
	 * @param    ind            The index value to store
	 */
	public function set v0Index(ind : uint) : void {
		_v0Index = ind;
	}
	
	/**
	 * @return Returns the index value of the v0 stored in the Face value object
	 */
	public function get v0Index() : uint {
		return _v0Index;
	}
	
	/**
	 * @return Returns a Vector.<Number> representing the v0 stored in the Face value object
	 */
	public function get v0() : Vector.<Number> {
		return Vector.<Number>([_vertices[0], _vertices[1], _vertices[2]]);
	}
	
	/**
	 * @return Returns the x value of the v0 stored in the Face value object
	 */
	public function get v0x() : Number {
		return _vertices[0];
	}
	
	/**
	 * @return Returns the y value of the v0 stored in the Face value object
	 */
	public function get v0y() : Number {
		return _vertices[1];
	}
	
	/**
	 * @return Returns the z value of the v0 stored in the Face value object
	 */
	public function get v0z() : Number {
		return _vertices[2];
	}
	
	//v1
	/**
	 * set the index value for v1
	 * @param    ind            The index value to store
	 */
	public function set v1Index(ind : uint) : void {
		_v1Index = ind;
	}
	
	/**
	 * @return Returns the index value of the v1 stored in the Face value object
	 */
	public function get v1Index() : uint {
		return _v1Index;
	}
	
	/**
	 * @return Returns a Vector.<Number> representing the v1 stored in the Face value object
	 */
	public function get v1() : Vector.<Number> {
		return Vector.<Number>([_vertices[3], _vertices[4], _vertices[5]]);
	}
	
	/**
	 * @return Returns the x value of the v1 stored in the Face value object
	 */
	public function get v1x() : Number {
		return _vertices[3];
	}
	
	/**
	 * @return Returns the y value of the v1 stored in the Face value object
	 */
	public function get v1y() : Number {
		return _vertices[4];
	}
	
	/**
	 * @return Returns the z value of the v1 stored in the Face value object
	 */
	public function get v1z() : Number {
		return _vertices[5];
	}
	
	//v2
	/**
	 * set the index value for v2
	 * @param    ind            The index value to store
	 */
	public function set v2Index(ind : uint) : void {
		_v2Index = ind;
	}
	
	/**
	 * @return return the index value of the v2 stored in the Face value object
	 */
	public function get v2Index() : uint {
		return _v2Index;
	}
	
	/**
	 * @return Returns a Vector.<Number> representing the v2 stored in the Face value object
	 */
	public function get v2() : Vector.<Number> {
		return Vector.<Number>([_vertices[6], _vertices[7], _vertices[8]]);
	}
	
	/**
	 * @return Returns the x value of the v2 stored in the Face value object
	 */
	public function get v2x() : Number {
		return _vertices[6];
	}
	
	/**
	 * @return Returns the y value of the v2 stored in the Face value object
	 */
	public function get v2y() : Number {
		return _vertices[7];
	}
	
	/**
	 * @return Returns the z value of the v2 stored in the Face value object
	 */
	public function get v2z() : Number {
		return _vertices[8];
	}
	
	/**
	 * returns a new Face value Object
	 */
	public function clone() : Face {
		var nVertices : Vector.<Number> = Vector.<Number>([_vertices[0], _vertices[1], _vertices[2], _vertices[3], _vertices[4], _vertices[5], _vertices[6], _vertices[7], _vertices[8]]);
		
		var nUvs : Vector.<Number> = Vector.<Number>([_uvs[0], _uvs[1], _uvs[2], _uvs[3], _uvs[4], _uvs[5]]);
		
		return new Face(nVertices, nUvs);
	}
	
	/**
	 * Returns the first two barycentric coordinates for a point on (or outside) the triangle. The third coordinate is 1 - x - y
	 * @param point The point for which to calculate the new target
	 * @param target An optional Point object to store the calculation in order to prevent creation of a new object
	 */
	public function getBarycentricCoords(point : Vector3D, target : Point = null) : Point {
		var v0x : Number = _vertices[0];
		var v0y : Number = _vertices[1];
		var v0z : Number = _vertices[2];
		var dx0 : Number = point.x - v0x;
		var dy0 : Number = point.y - v0y;
		var dz0 : Number = point.z - v0z;
		var dx1 : Number = _vertices[3] - v0x;
		var dy1 : Number = _vertices[4] - v0y;
		var dz1 : Number = _vertices[5] - v0z;
		var dx2 : Number = _vertices[6] - v0x;
		var dy2 : Number = _vertices[7] - v0y;
		var dz2 : Number = _vertices[8] - v0z;
		
		var dot01 : Number = dx1 * dx0 + dy1 * dy0 + dz1 * dz0;
		var dot02 : Number = dx2 * dx0 + dy2 * dy0 + dz2 * dz0;
		var dot11 : Number = dx1 * dx1 + dy1 * dy1 + dz1 * dz1;
		var dot22 : Number = dx2 * dx2 + dy2 * dy2 + dz2 * dz2;
		var dot12 : Number = dx2 * dx1 + dy2 * dy1 + dz2 * dz1;
		
		var invDenom : Number = 1 / (dot22 * dot11 - dot12 * dot12);
		target ||= new Point();
		target.x = (dot22 * dot01 - dot12 * dot02) * invDenom;
		target.y = (dot11 * dot02 - dot12 * dot01) * invDenom;
		return target;
	}
	
	/**
	 * Tests whether a given point is inside the triangle
	 * @param point The point to test against
	 * @param maxDistanceToPlane The minimum distance to the plane for the point to be considered on the triangle. This is usually used to allow for rounding error, but can also be used to perform a volumetric test.
	 */
	public function containsPoint(point : Vector3D, maxDistanceToPlane : Number = .007) : Boolean {
		if (!planeContains(point, maxDistanceToPlane))
			return false;
		
		getBarycentricCoords(point, _calcPoint ||= new Point());
		var s : Number = _calcPoint.x;
		var t : Number = _calcPoint.y;
		return s >= 0.0 && t >= 0.0 && (s + t) <= 1.0;
	}
	
	private function planeContains(point : Vector3D, epsilon : Number = .007) : Boolean {
		var v0x : Number = _vertices[0];
		var v0y : Number = _vertices[1];
		var v0z : Number = _vertices[2];
		var d1x : Number = _vertices[3] - v0x;
		var d1y : Number = _vertices[4] - v0y;
		var d1z : Number = _vertices[5] - v0z;
		var d2x : Number = _vertices[6] - v0x;
		var d2y : Number = _vertices[7] - v0y;
		var d2z : Number = _vertices[8] - v0z;
		var a : Number = d1y * d2z - d1z * d2y;
		var b : Number = d1z * d2x - d1x * d2z;
		var c : Number = d1x * d2y - d1y * d2x;
		var len : Number = 1 / Math.sqrt(a * a + b * b + c * c);
		a *= len;
		b *= len;
		c *= len;
		var dist : Number = a * (point.x - v0x) + b * (point.y - v0y) + c * (point.z - v0z);
		trace(dist);
		return dist > -epsilon && dist < epsilon;
	}
	
	/**
	 * Returns the target coordinates for a point on a triangle
	 * @param v0 The triangle's first vertex
	 * @param v1 The triangle's second vertex
	 * @param v2 The triangle's third vertex
	 * @param uv0 The UV coord associated with the triangle's first vertex
	 * @param uv1 The UV coord associated with the triangle's second vertex
	 * @param uv2 The UV coord associated with the triangle's third vertex
	 * @param point The point for which to calculate the new target
	 * @param target An optional UV object to store the calculation in order to prevent creation of a new object
	 */
	public function getUVAtPoint(point : Vector3D, target : UV = null) : UV {
		getBarycentricCoords(point, _calcPoint ||= new Point());
		
		var s : Number = _calcPoint.x;
		var t : Number = _calcPoint.y;
		
		if (s >= 0.0 && t >= 0.0 && (s + t) <= 1.0) {
			var u0 : Number = _uvs[0];
			var v0 : Number = _uvs[1];
			target ||= new UV();
			target.u = u0 + t * (_uvs[4] - u0) + s * (_uvs[2] - u0);
			target.v = v0 + t * (_uvs[5] - v0) + s * (_uvs[3] - v0);
			return target;
		} else
			return null;
	}
}

class UV {
	private var _u : Number;
	private var _v : Number;
	
	/**
	 * Creates a new <code>UV</code> object.
	 *
	 * @param    u        [optional]    The horizontal coordinate of the texture value. Defaults to 0.
	 * @param    v        [optional]    The vertical coordinate of the texture value. Defaults to 0.
	 */
	public function UV(u : Number = 0, v : Number = 0) {
		_u = u;
		_v = v;
	}
	
	/**
	 * Defines the vertical coordinate of the texture value.
	 */
	public function get v() : Number {
		return _v;
	}
	
	public function set v(value : Number) : void {
		_v = value;
	}
	
	/**
	 * Defines the horizontal coordinate of the texture value.
	 */
	public function get u() : Number {
		return _u;
	}
	
	public function set u(value : Number) : void {
		_u = value;
	}
	
	/**
	 * returns a new UV value Object
	 */
	public function clone() : UV {
		return new UV(_u, _v);
	}
	
	/**
	 * returns the value object as a string for trace/debug purpose
	 */
	public function toString() : String {
		return _u + "," + _v;
	}
	
}

class Vertex {
	private var _x : Number;
	private var _y : Number;
	private var _z : Number;
	private var _index : uint;
	
	/**
	 * Creates a new <code>Vertex</code> value object.
	 *
	 * @param    x            [optional]    The x value. Defaults to 0.
	 * @param    y            [optional]    The y value. Defaults to 0.
	 * @param    z            [optional]    The z value. Defaults to 0.
	 * @param    index        [optional]    The index value. Defaults is NaN.
	 */
	public function Vertex(x : Number = 0, y : Number = 0, z : Number = 0, index : uint = 0) {
		_x = x;
		_y = y;
		_z = z;
		_index = index;
	}
	
	/**
	 * To define/store the index of value object
	 * @param    ind        The index
	 */
	public function set index(ind : uint) : void {
		_index = ind;
	}
	
	public function get index() : uint {
		return _index;
	}
	
	/**
	 * To define/store the x value of the value object
	 * @param    value        The x value
	 */
	public function get x() : Number {
		return _x;
	}
	
	public function set x(value : Number) : void {
		_x = value;
	}
	
	/**
	 * To define/store the y value of the value object
	 * @param    value        The y value
	 */
	public function get y() : Number {
		return _y;
	}
	
	public function set y(value : Number) : void {
		_y = value;
	}
	
	/**
	 * To define/store the z value of the value object
	 * @param    value        The z value
	 */
	public function get z() : Number {
		return _z;
	}
	
	public function set z(value : Number) : void {
		_z = value;
	}
	
	/**
	 * returns a new Vertex value Object
	 */
	public function clone() : Vertex {
		return new Vertex(_x, _y, _z);
	}
	
	/**
	 * returns the value object as a string for trace/debug purpose
	 */
	public function toString() : String {
		return _x + "," + _y + "," + _z;
	}
	
}
