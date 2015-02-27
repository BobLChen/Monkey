package L3D.loaders.parser.md5 {
	import flash.events.EventDispatcher;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import L3D.core.animator.pose.Skeleton;
	import L3D.core.animator.pose.SkeletonJoint;
	import L3D.core.base.Geometry3D;
	import L3D.core.base.Quaternion;
	import L3D.core.entities.Mesh3D;
	import L3D.utils.Cast;

	/**
	 * md5模型解析器
	 * @author Neil
	 */
	public class MD5MeshParser extends EventDispatcher {
		/** md5mesh 模型内容 */
		private var _textData : String;
		/** 是否开始解析 */
		private var _startedParsing : Boolean;
		/** MD5Version 版本好必须为10 */
		private static const VERSION_TOKEN : String = "MD5Version";
		/** commandline */
		private static const COMMAND_LINE_TOKEN : String = "commandline";
		/** numJoints */
		private static const NUM_JOINTS_TOKEN : String = "numJoints";
		/** numMeshes */
		private static const NUM_MESHES_TOKEN : String = "numMeshes";
		/** // 注释 */
		private static const COMMENT_TOKEN : String = "//";
		/** joints */
		private static const JOINTS_TOKEN : String = "joints";
		/** mesh */
		private static const MESH_TOKEN : String = "mesh";
		/** shader */
		private static const MESH_SHADER_TOKEN : String = "shader";
		/** numverts */
		private static const MESH_NUM_VERTS_TOKEN : String = "numverts";
		/** vert */
		private static const MESH_VERT_TOKEN : String = "vert";
		/** numtris */
		private static const MESH_NUM_TRIS_TOKEN : String = "numtris";
		/** tri */
		private static const MESH_TRI_TOKEN : String = "tri";
		/** numweights */
		private static const MESH_NUM_WEIGHTS_TOKEN : String = "numweights";
		/** weight */
		private static const MESH_WEIGHT_TOKEN : String = "weight";
		/** 解析进度 */
		private var _parseIndex : int;
		/** 是否解析完成 */
		private var _reachedEOF : Boolean;
		private var _line : int;
		private var _charLineIndex : int;
		/** 版本号 */
		private var _version : int;
		/** 骨头数量 */
		private var _numJoints : int;
		/** mesh 数量 */
		private var _numMeshes : int;
		/** 贴图地址 */
		private var _shaders : Vector.<String>;
		/** meshdata */
		private var _meshData : Vector.<MeshData>;
		/** 骨骼 */
		private var _skeleton : Skeleton;
		/** 四元数，用于转化到右手坐标系 */
		private var _rotationQuat : Quaternion;
		/** 允许的顶点的最大权重数为4个 */
		private static const MAX_JOINT_COUNT : int = 4;

		public var meshs : Vector.<Mesh3D>;

		public function get skeleton() : Skeleton {
			return this._skeleton;
		}

		public function MD5MeshParser(additionalRotationAxis : Vector3D = null, additionalRotationRadians : Number = 0) {
			_rotationQuat = new Quaternion();
			_rotationQuat.fromAxisAngle(Vector3D.X_AXIS, -Math.PI * .5);
			if (additionalRotationAxis) {
				var quat : Quaternion = new Quaternion();
				quat.fromAxisAngle(additionalRotationAxis, additionalRotationRadians);
				_rotationQuat.multiply(_rotationQuat, quat);
			}
		}

		/**
		 * load md5mesh模型，二进制或者文本
		 * @param data
		 */
		public function parse(data : *) : Boolean {
			return proceedParsing(Cast.toString(data));
		}

		/**
		 * 解析md5mesh模型
		 * @param txt
		 * @return 			是否解析成功
		 */
		private function proceedParsing(txt : String) : Boolean {
			var token : String;

			if (_startedParsing)
				return false;

			_textData = txt;
			_startedParsing = true;

			while (true) {
				token = getNextToken();
				switch (token) {
					case COMMENT_TOKEN:
						ignoreLine();
						break;
					case VERSION_TOKEN:
						_version = getNextInt();
						if (_version != 10)
							throw new Error("Unknown version number encountered!");
						break;
					case COMMAND_LINE_TOKEN:
						parseCMD();
						break;
					case NUM_JOINTS_TOKEN:
						_numJoints = getNextInt();
						_skeleton = new Skeleton(_numJoints);
						break;
					case NUM_MESHES_TOKEN:
						_numMeshes = getNextInt();
						break;
					case JOINTS_TOKEN:
						parseJoints();
						break;
					case MESH_TOKEN:
						parseMesh();
						break;
					default:
						if (!_reachedEOF)
							sendUnknownKeywordError();
				}

				if (_reachedEOF) {
					_skeleton.maxJointCount = MAX_JOINT_COUNT;
					meshs = new Vector.<Mesh3D>();
					for (var i : int = 0; i < _meshData.length; ++i) {
						var mesh : Mesh3D = translateGeom(_meshData[i].vertexData, _meshData[i].weightData, _meshData[i].indices);
						mesh.name = 'md5Mesh' + i;
						meshs.push(mesh);
					}
					
					for (i = 0; i < _skeleton.joints.length; i++) {
						var joint : SkeletonJoint = _skeleton.joints[i];
						var transform : Matrix3D = joint.tranform;
						var vec3 : Vector.<Vector3D> = transform.decompose("quaternion");
						
						trace(joint.name, vec3[0], vec3[1], vec3[1].w);
					}
					
					return true;
				}
			}
			return false;
		}
		
		/**
		 * 计算顶点权重为0的数量
		 * @param vertex
		 * @param weights
		 * @return
		 */
		private function countZeroWeightJoints(vertex : VertexData, weights : Vector.<JointData>) : int {
			var start : int = vertex.startWeight;
			var end : int = vertex.startWeight + vertex.countWeight;
			var count : int = 0;
			var weight : Number;
			for (var i : int = start; i < end; ++i) {
				weight = weights[i].bias;
				if (weight == 0)
					++count;
			}
			return count;
		}

		/**
		 *  开始解析骨骼
		 */
		private function parseJoints() : void {
			var ch : String;
			var joint : SkeletonJoint;
			var pos : Vector3D;
			var quat : Quaternion;
			var i : int = 0;
			var token : String = getNextToken();

			if (token != "{")
				sendUnknownKeywordError();

			do {
				if (_reachedEOF)
					sendEOFError();

				joint = new SkeletonJoint();
				joint.name = parseLiteralString();
				joint.parentIndex = getNextInt();
				joint.index = i;

				pos = parseVector3D();
				pos = _rotationQuat.rotatePoint(pos);

				quat = parseQuaternion();
				
				var tranform : Matrix3D = quat.toMatrix3D();
				tranform.appendTranslation(pos.x, pos.y, pos.z);

				var inv : Matrix3D = tranform.clone();
				inv.invert();

				joint.tranform = tranform;
				joint.inverTranform = inv;
				
				_skeleton.joints[i++] = joint;
				
				ch = getNextChar();

				if (ch == "/") {
					putBack();
					ch = getNextToken();
					if (ch == COMMENT_TOKEN)
						ignoreLine();
					ch = getNextChar();

				}
				if (ch != "}")
					putBack();
			} while (ch != "}");
		}

		/**
		 * Puts back the last read character into the data stream.
		 */
		private function putBack() : void {
			_parseIndex--;
			_charLineIndex--;
			_reachedEOF = _parseIndex >= _textData.length;
		}

		/**
		 * Parses the mesh geometry.
		 */
		private function parseMesh() : void {
			var token : String = getNextToken();
			var ch : String;
			var vertexData : Vector.<VertexData>;
			var weights : Vector.<JointData>;
			var indices : Vector.<uint>;

			if (token != "{")
				sendUnknownKeywordError();

			_shaders ||= new Vector.<String>();

			while (ch != "}") {
				ch = getNextToken();
				switch (ch) {
					case COMMENT_TOKEN:
						ignoreLine();
						break;
					case MESH_SHADER_TOKEN:
						_shaders.push(parseLiteralString());
						break;
					case MESH_NUM_VERTS_TOKEN:
						vertexData = new Vector.<VertexData>(getNextInt(), true);
						break;
					case MESH_NUM_TRIS_TOKEN:
						indices = new Vector.<uint>(getNextInt() * 3, true);
						break;
					case MESH_NUM_WEIGHTS_TOKEN:
						weights = new Vector.<JointData>(getNextInt(), true);
						break;
					case MESH_VERT_TOKEN:
						parseVertex(vertexData);
						break;
					case MESH_TRI_TOKEN:
						parseTri(indices);
						break;
					case MESH_WEIGHT_TOKEN:
						parseJoint(weights);
						break;
				}
			}

			_meshData ||= new Vector.<MeshData>();

			var i : uint = _meshData.length;
			_meshData[i] = new MeshData();
			_meshData[i].vertexData = vertexData;
			_meshData[i].weightData = weights;
			_meshData[i].indices = indices;
		}

		/**
		 * Converts the mesh data to a SkinnedSub instance.
		 * @param vertexData The mesh's vertices.
		 * @param weights The joint weights per vertex.
		 * @param indices The indices for the faces.
		 * @return A SkinnedSubGeometry instance containing all geometrical data for the current mesh.
		 */
		private function translateGeom(vertexData : Vector.<VertexData>, weights : Vector.<JointData>, indices : Vector.<uint>) : Mesh3D {
			
			var len : int = vertexData.length;
			var v1 : int, v2 : int, v3 : int;
			var vertex : VertexData;
			var weight : JointData;
			var bindPose : Matrix3D;
			var pos : Vector3D;
			
			var uvs : Vector.<Number> = new Vector.<Number>(len * 2, true);
			var vertices : Vector.<Number> = new Vector.<Number>(len * 3, true);
			
			var jointIndices : Vector.<Number> = new Vector.<Number>(len * MAX_JOINT_COUNT, true);
			var jointWeights : Vector.<Number> = new Vector.<Number>(len * MAX_JOINT_COUNT, true);
			
			var l : int;
			var nonZeroWeights : int;
			var i : int = 0;

			for (i = 0; i < len; ++i) {
				
				vertex = vertexData[i];
				v1 = vertex.index * 3;
				v2 = v1 + 1;
				v3 = v1 + 2;
				vertices[v1] = vertices[v2] = vertices[v3] = 0;
				nonZeroWeights = 0;

				// 如果权重数量>=4，强制权重数量为4个，否则使用countWeight
				var numCountWeight : int = vertex.countWeight >= 4 ? MAX_JOINT_COUNT : vertex.countWeight;
				
				for (var j : int = 0; j < numCountWeight; ++j) {
					weight = weights[vertex.startWeight + j];

					if (weight.bias > 0) {
						
						bindPose = _skeleton.joints[weight.joint].tranform;
						pos = bindPose.transformVector(weight.pos);
						
						vertices[v1] += pos.x * weight.bias;
						vertices[v2] += pos.y * weight.bias;
						vertices[v3] += pos.z * weight.bias;
						
						jointIndices[l] = weight.joint * 2;
						jointWeights[l++] = weight.bias;
						
						++nonZeroWeights;
					}
				}

				for (j = nonZeroWeights; j < MAX_JOINT_COUNT; ++j) {
					jointIndices[l] = 0;
					jointWeights[l++] = 0;
				}

				v1 = vertex.index << 1;
				uvs[v1++] = vertex.s;
				uvs[v1] = vertex.t;
			}
			
			/** 权重以及索引信息,权重索引权重索引。。。格式存放 */
			var jointIndicesAndWeights : Vector.<Number> = new Vector.<Number>(len * 8, true);
			
			for(i = 0; i < len; i++) {
				
				jointIndicesAndWeights[i * 8 + 0] = jointWeights[i * 4 + 0];
				jointIndicesAndWeights[i * 8 + 1] = jointWeights[i * 4 + 1];
				jointIndicesAndWeights[i * 8 + 2] = jointWeights[i * 4 + 2];
				jointIndicesAndWeights[i * 8 + 3] = jointWeights[i * 4 + 3];
				
				jointIndicesAndWeights[i * 8 + 4] = jointIndices[i * 4 + 0];
				jointIndicesAndWeights[i * 8 + 5] = jointIndices[i * 4 + 1];
				jointIndicesAndWeights[i * 8 + 6] = jointIndices[i * 4 + 2];
				jointIndicesAndWeights[i * 8 + 7] = jointIndices[i * 4 + 3];
			}
			var resultVertex : Vector.<Number> = new Vector.<Number>();
			// 将顶点法线uv拼接到一起，顺序存放
			for (i = 0; i < len; i++) {
				resultVertex.push(
					vertices[i * 3], vertices[i * 3 + 1], vertices[i * 3 + 2], 
					uvs[i * 2], uvs[i * 2 + 1]
				);
			}
			
			var geometry : Geometry3D = new Geometry3D();
			geometry.setVertexDataType(Geometry3D.POSITION);
			geometry.setVertexDataType(Geometry3D.UV0);
			geometry.vertexVector = resultVertex;
			geometry.firstIndex = 0;
			geometry.numTriangles = indices.length / 3;
			geometry.indexVector = indices;
			
			var skinGeometry : Geometry3D = new Geometry3D();
			skinGeometry.setVertexDataType(Geometry3D.SKIN_WEIGHTS);
			skinGeometry.setVertexDataType(Geometry3D.SKIN_INDICES);
			skinGeometry.vertexVector = jointIndicesAndWeights;
			skinGeometry.bonesNum = skeleton.joints.length;
			geometry.sources[Geometry3D.SKIN_INDICES] = skinGeometry;
			geometry.sources[Geometry3D.SKIN_WEIGHTS] = skinGeometry;

			var mesh : Mesh3D = new Mesh3D();
			mesh.geometries.push(geometry);

			return mesh;
		}

		/**
		 * Retrieve the next triplet of vertex indices that form a face.
		 * @param indices The index list in which to store the read data.
		 */
		private function parseTri(indices : Vector.<uint>) : void {
			var index : int = getNextInt() * 3;
			indices[index] = getNextInt();
			indices[index + 1] = getNextInt();
			indices[index + 2] = getNextInt();
		}

		/**
		 * Reads a new joint data set for a single joint.
		 * @param weights the target list to contain the weight data.
		 */
		private function parseJoint(weights : Vector.<JointData>) : void {
			var weight : JointData = new JointData();
			weight.index = getNextInt();
			weight.joint = getNextInt();
			weight.bias = getNextNumber();
			weight.pos = parseVector3D();
			weights[weight.index] = weight;
		}

		/**
		 * Reads the data for a single vertex.
		 * @param vertexData The list to contain the vertex data.
		 */
		private function parseVertex(vertexData : Vector.<VertexData>) : void {
			var vertex : VertexData = new VertexData();
			vertex.index = getNextInt();
			parseUV(vertex);
			vertex.startWeight = getNextInt();
			vertex.countWeight = getNextInt();
			vertexData[vertex.index] = vertex;
		}

		/**
		 * Reads the next uv coordinate.
		 * @param vertexData The vertexData to contain the UV coordinates.
		 */
		private function parseUV(vertexData : VertexData) : void {
			var ch : String = getNextToken();
			if (ch != "(")
				sendParseError("(");
			vertexData.s = getNextNumber();
			vertexData.t = getNextNumber();

			if (getNextToken() != ")")
				sendParseError(")");
		}

		/**
		 * Gets the next token in the data stream.
		 */
		private function getNextToken() : String {
			var ch : String;
			var token : String = "";

			while (!_reachedEOF) {
				ch = getNextChar();
				if (ch == " " || ch == "\r" || ch == "\n" || ch == "\t") {
					if (token != COMMENT_TOKEN)
						skipWhiteSpace();
					if (token != "")
						return token;
				} else
					token += ch;

				if (token == COMMENT_TOKEN)
					return token;
			}

			return token;
		}

		/**
		 * Skips all whitespace in the data stream.
		 */
		private function skipWhiteSpace() : void {
			var ch : String;

			do {
				ch = getNextChar();
			} while (ch == "\n" || ch == " " || ch == "\r" || ch == "\t");

			putBack();
		}

		/**
		 * Skips to the next line.
		 */
		private function ignoreLine() : void {
			var ch : String;
			while (!_reachedEOF && ch != "\n")
				ch = getNextChar();
		}

		/**
		 * Retrieves the next single character in the data stream.
		 */
		private function getNextChar() : String {
			var ch : String = _textData.charAt(_parseIndex++);

			if (ch == "\n") {
				++_line;
				_charLineIndex = 0;
			} else if (ch != "\r")
				++_charLineIndex;

			if (_parseIndex >= _textData.length)
				_reachedEOF = true;

			return ch;
		}


		/**
		 * Retrieves the next integer in the data stream.
		 */
		private function getNextInt() : int {
			var i : Number = parseInt(getNextToken());
			if (isNaN(i))
				sendParseError("int type");
			return i;
		}

		/**
		 * Retrieves the next floating point number in the data stream.
		 */
		private function getNextNumber() : Number {
			var f : Number = parseFloat(getNextToken());
			if (isNaN(f))
				sendParseError("float type");
			return f;
		}

		/**
		 * Retrieves the next 3d vector in the data stream.
		 */
		private function parseVector3D() : Vector3D {
			var vec : Vector3D = new Vector3D();
			var ch : String = getNextToken();

			if (ch != "(")
				sendParseError("(");

			// ex:
			vec.x = -getNextNumber();
			vec.y = getNextNumber();
			vec.z = getNextNumber();

			if (getNextToken() != ")")
				sendParseError(")");

			return vec;
		}

		/**
		 * Retrieves the next quaternion in the data stream.
		 */
		private function parseQuaternion() : Quaternion {
			var quat : Quaternion = new Quaternion();
			var ch : String = getNextToken();

			if (ch != "(")
				sendParseError("(");

			// ex:
			quat.x = getNextNumber();
			quat.y = -getNextNumber();
			quat.z = -getNextNumber();
			
			// quat supposed to be unit length
			var t : Number = 1 - quat.x * quat.x - quat.y * quat.y - quat.z * quat.z;
			quat.w = t < 0 ? 0 : -Math.sqrt(t);

			if (getNextToken() != ")")
				sendParseError(")");

			var rotQuat : Quaternion = new Quaternion();
			rotQuat.multiply(_rotationQuat, quat);
			return rotQuat;
		}

		/**
		 * Parses the command line data.
		 */
		private function parseCMD() : void {
			// just ignore the command line property
			parseLiteralString();
		}

		/**
		 * Retrieves the next literal string in the data stream. A literal string is a sequence of characters bounded
		 * by double quotes.
		 */
		private function parseLiteralString() : String {
			skipWhiteSpace();

			var ch : String = getNextChar();
			var str : String = "";

			if (ch != "\"")
				sendParseError("\"");

			do {
				if (_reachedEOF)
					sendEOFError();
				ch = getNextChar();
				if (ch != "\"")
					str += ch;
			} while (ch != "\"");

			return str;
		}

		/**
		 * Throws an end-of-file error when a premature end of file was encountered.
		 */
		private function sendEOFError() : void {
			throw new Error("Unexpected end of file");
		}

		/**
		 * Throws an error when an unexpected token was encountered.
		 * @param expected The token type that was actually expected.
		 */
		private function sendParseError(expected : String) : void {
			throw new Error("Unexpected token at line " + (_line + 1) + ", character " + _charLineIndex + ". " + expected + " expected, but " + _textData.charAt(_parseIndex - 1) + " encountered");
		}

		/**
		 * Throws an error when an unknown keyword was encountered.
		 */
		private function sendUnknownKeywordError() : void {
			throw new Error("Unknown keyword at line " + (_line + 1) + ", character " + _charLineIndex + ". ");
		}
	}
}

import flash.geom.Vector3D;

class VertexData {
	public var index : int;
	public var s : Number;
	public var t : Number;
	public var startWeight : int;
	public var countWeight : int;
}

class JointData {
	public var index : int;
	public var joint : int;
	public var bias : Number;
	public var pos : Vector3D;
}

class MeshData {
	public var vertexData : Vector.<VertexData>;
	public var weightData : Vector.<JointData>;
	public var indices : Vector.<uint>;
}

