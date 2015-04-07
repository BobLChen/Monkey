using UnityEngine;
using System.Collections;
using UnityEditor;
using System.IO;
using LitJson;
using System.IO.Compression;

public class LightmapPlugin : EditorWindow {

	public static bool normal  = true;
	public static bool tangent = true;

	private static string folderName;

	[MenuItem("Monkey/" + "ExportLightmap")]
	static void TestLightmapingInfo() {

		if (Selection.activeGameObject) {
			createFloder();
			writeConfig();
			writeMeshs();
			Debug.Log("ʕ•̫͡•ʕ*̫͡*ʕ complete");
		}
	}

	private static void createFloder() {
		folderName = EditorUtility.SaveFolderPanel("Select Folder", "lightmap", "lightmap");
	}

	private static void writeMeshs() {
		GameObject[] arr = Selection.gameObjects;
		foreach (GameObject obj in arr) {
			writeGameObject(obj);
		}
	}

	private static void writeGameObject(GameObject obj) {
		if (obj.renderer) {
			Mesh mesh = obj.renderer.GetComponent<MeshFilter>().sharedMesh;
			if (mesh) {
				writeMesh(mesh);
			}
		}
		for (int i = 0; i < obj.transform.childCount; i++) {
			writeGameObject(obj.transform.GetChild(i).gameObject);
		}
	}

	private static void writeMesh(Mesh m) {
		string filepath = folderName + "/" + m.name + ".mesh";
		if (File.Exists(filepath)) {
			File.Delete(filepath);
		}
		MemoryStream ms = new MemoryStream();
		BinaryWriter bw = new BinaryWriter(ms);
		Debug.Log("Write Mesh:" + m.name + " to disk:" + filepath);
		// write length
		bw.Write(m.name.Length);
		// write name
		bw.Write(m.name.ToCharArray());
		// write matrix
		float[] rawData = new float[]{
			1, 0, 0, 0, 
			0, 1, 0, 0, 
			0, 0, 1, 0
		};
		for (int i = 0; i < rawData.Length; i++) {
			bw.Write(rawData[i]);
		}
		// write sub mesh count
		bw.Write(1);
		// write vertex count
		bw.Write(m.vertices.Length);
		Debug.Log("\tVertices:" + m.vertices.Length);
		foreach (Vector3 vert in m.vertices) {
			bw.Write(vert.x);
			bw.Write(vert.y);
			bw.Write(vert.z);
		}
		// write uv0
		bw.Write(m.uv.Length);
		Debug.Log("\tUV0:" + m.uv.Length);
		foreach (Vector2 uv0 in m.uv) {
			bw.Write(uv0.x);
			bw.Write(1 - uv0.y);
		}
		// write uv1
		bw.Write(m.uv2.Length);
		Debug.Log("\tUV1:" + m.uv2.Length);
		foreach (Vector2 uv1 in m.uv2) {
			bw.Write(uv1.x);
			bw.Write(uv1.y);
		}
		Debug.Log("normals:" + m.normals.Length);
		// write normal
		if (normal) {
			bw.Write(m.normals.Length);
			foreach (Vector3 n in m.normals) {
				bw.Write(n.x);
				bw.Write(n.y);
				bw.Write(n.z);
			}
		} else {
			bw.Write(0);
		}
		Debug.Log("tangent:" + m.tangents.Length);
		// write tangent
		if (tangent) {
			bw.Write(m.tangents.Length);
			foreach (Vector3 t in m.tangents) {
				bw.Write(t.x);
				bw.Write(t.y);
				bw.Write(t.z);
			}
		} else {
			bw.Write(0);
		}
		// skeleton weights
		bw.Write(0);
		// skeleton indices
		bw.Write(0);
		// write indices
		bw.Write(m.triangles.Length);
		for (int i = 0; i < m.triangles.Length; i++) {
			bw.Write(m.triangles[i]);
		}
		// bounds
		bw.Write(m.bounds.min.x);
		bw.Write(m.bounds.min.y);
		bw.Write(m.bounds.min.z);
		bw.Write(m.bounds.max.x);
		bw.Write(m.bounds.max.y);
		bw.Write(m.bounds.max.z);
		bw.Close();
		
		int size = ms.GetBuffer().Length;
		MemoryStream compressionBytes = new MemoryStream();
		// write to disk
		DeflateStream compressionStream = new DeflateStream(compressionBytes, CompressionMode.Compress);
		compressionStream.Write(ms.GetBuffer(), 0, ms.GetBuffer().Length);
		compressionStream.Close();

		FileStream fs = new FileStream(filepath, FileMode.Create);
		BinaryWriter cbw = new BinaryWriter(fs);
		// write compression type
		cbw.Write(3);
		// write original size
		cbw.Write(size);
		// write compressed data
		cbw.Write(compressionBytes.GetBuffer());

		cbw.Close();
		fs.Close();
	}
	
	private static void writeConfig() {
		JsonWriter cfg = new JsonWriter();
		cfg.WriteObjectStart();
		cfg.WritePropertyName("scene");
		cfg.WriteArrayStart();
		GameObject[] arr = Selection.gameObjects;
		foreach (GameObject obj in arr) {
			writeObject(obj, ref cfg);
		}
		cfg.WriteArrayEnd();
		cfg.WriteObjectEnd();

		string filepath = folderName + "/scene.lightmap";
		if (File.Exists(filepath)) {
			File.Delete(filepath);
		}
		FileStream fs = new FileStream(filepath, FileMode.Create);
		BinaryWriter bw = new BinaryWriter(fs);
		bw.Write(cfg.ToString().ToCharArray());
		bw.Close();
		fs.Close();
		Debug.Log("Write Config:" + filepath);
	}
	
	private static void writeObject(GameObject obj, ref JsonWriter cfg) {
		cfg.WriteObjectStart();
		cfg.WritePropertyName("name");
		cfg.Write(obj.name);
		cfg.WritePropertyName("Layer");
		cfg.Write(obj.layer);
		writeMatrix(ref cfg, obj.transform);

		if (obj.renderer) {
			Mesh mesh = obj.renderer.GetComponent<MeshFilter>().sharedMesh;
			if (obj.renderer.material.mainTexture != null) {
				cfg.WritePropertyName("MainTexture");
				cfg.Write(getFileName(AssetDatabase.GetAssetPath(obj.renderer.material.mainTexture.GetInstanceID())));
			}
			if (mesh) {
				cfg.WritePropertyName("Mesh");
				cfg.Write(mesh.name);
			}
			if (obj.renderer.lightmapIndex != -1) {
				cfg.WritePropertyName("lightmap");
				cfg.Write(LightmapSettings.lightmaps[obj.renderer.lightmapIndex].lightmapFar.name);
				cfg.WritePropertyName("tilingOffset");
				cfg.WriteArrayStart();
				cfg.Write(obj.renderer.lightmapTilingOffset.x);
				cfg.Write(obj.renderer.lightmapTilingOffset.y);
				cfg.Write(obj.renderer.lightmapTilingOffset.z);
				cfg.Write(obj.renderer.lightmapTilingOffset.w);
				cfg.WriteArrayEnd();
			}
		}

		cfg.WritePropertyName("children");
		cfg.WriteArrayStart();

		for (int i = 0; i < obj.transform.childCount; i++) {
			writeObject(obj.transform.GetChild(i).gameObject, ref cfg);
		}

		cfg.WriteArrayEnd();
		cfg.WriteObjectEnd();
	}

	private static void writeMatrix(ref JsonWriter cfg, Transform mt) {
		cfg.WritePropertyName("pos");
		cfg.WriteArrayStart();
		cfg.Write(mt.localPosition.x);
		cfg.Write(mt.localPosition.y);
		cfg.Write(mt.localPosition.z);
		cfg.WriteArrayEnd();

		cfg.WritePropertyName("scale");
		cfg.WriteArrayStart();
		cfg.Write(mt.localScale.x);
		cfg.Write(mt.localScale.y);
		cfg.Write(mt.localScale.z);
		cfg.WriteArrayEnd();

		cfg.WritePropertyName("rotation");
		cfg.WriteArrayStart();
		cfg.Write(mt.localRotation.eulerAngles.x);
		cfg.Write(mt.localRotation.eulerAngles.y);
		cfg.Write(mt.localRotation.eulerAngles.z);
		cfg.WriteArrayEnd();
	}

	private static string getFileName(string filepath) {
		return System.IO.Path.GetFileName(filepath);
	}
	
}

