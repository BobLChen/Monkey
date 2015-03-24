#!/usr/bin/python2.7
# coding: utf-8

''' 
FBX:
    Fbx文件名、路径名以及3D场景中所有物体建议不要使用中文名称。
    
文件格式参考Samples
    
解析参数说明:
    
    -normal      解析法线，默认不解析
    -uv0         解析UV0，默认不解析
    -uv1         解析UV1，默认不解析
    -anim        解析动画，默认不解析
    -world       使用全局坐标，默认使用局部坐标
    -path        指定Fbx文件路径，默认则扫描当前目录
    -quat        使用四元数骨骼，默认则使用3列四行矩阵
    -max_quat    设置四元数最大骨骼，默认上限为56，超过则拆分模型
    -max_m34     设置矩阵最大骨骼，默认上限为36，超过则拆分模型
    
'''

from FbxCommon import *
from platform import system
from string import count
import argparse
import json
import logging
import os
import re
import struct
import sys
import zlib

# object
class LObject(object):
    """docstring for LObject"""
    def __init__(self): 
        pass # end func
    pass # end class

# 文件类型
MESH_TYPE   = ".mesh"
ANIM_TYPE   = ".anim"
CAMERA_TYPE = ".camera"
SCENE_TYPE  = ".scene"
# 翻转
AXIS_FLIP_L = FbxAMatrix(FbxVector4(0, 0, 0), FbxVector4(-180, 0, 0),  FbxVector4(1, -1, 1))
# 最大权重数量
MAX_WEIGHT_NUM = 4
# 最大顶点数
MAX_VERTEX_NUM = 65535
# 配置文件
config = LObject()

# 解析命令行参数
def parseArgument():
    
    parser = argparse.ArgumentParser()
    # 解析法线
    parser.add_argument("-normal",  help = "parse normal",              action = "store_true",      default = False)
    # 解析切线
    parser.add_argument("-tangent", help = "parse tangent",             action = "store_true",      default = False)
    # 解析UV0
    parser.add_argument("-uv0",     help = "parse uv0",                 action = "store_true",      default = False)
    # 解析UV1
    parser.add_argument("-uv1",     help = "parse uv1",                 action = "store_true",      default = False)
    # 解析动画
    parser.add_argument("-anim",    help = "parse animation",           action = "store_true",      default = False)
    # 使用geometry坐标
    parser.add_argument("-geometry", help = "geometry transform",       action = "store_true",      default = False)
    # 使用全局坐标
    parser.add_argument("-world",   help = "world Transofrm",           action = "store_true",      default = False)
    # 指定Fbx文件路径
    parser.add_argument("-path",    help = "fbx file path  ",           action = "store",           default = "")
    # 使用四元数方式
    parser.add_argument("-quat",    help = "quat with anima",           action = "store_true",      default = False)
    # 使用四元数时，最大骨骼数
    parser.add_argument("-max_quat",help = "bone num with quat",        action = "store",           default = 56)
    # 使用矩阵时，最大骨骼数
    parser.add_argument("-max_m34", help = "bone num with m34",         action = "store",           default = 36)
    # 挂节点
    parser.add_argument("-mount",  help = "mount bone, split by ','",   action = "store",  default = "Bone001")
    
    option = parser.parse_args()
    option.mount = option.mount.split(",")
    option.max_quat = int(option.max_quat)
    option.max_m34  = int(option.max_m34)
    
    logging.info(("parse arguments...", option))
    
    return option
    pass

# 扫描Fbx文件
def scanFbxFiles(args):
    # 拼接fbx文件
    fbxList = []
    if os.path.isfile(args):
        fbxList.append(args)
        pass
    else:
        logging.info("scane current directory:%s" % os.getcwd())
        for parentDir, _, fileNames in os.walk(os.getcwd()):
            for fileName in fileNames:
                if fileName.endswith('FBX') or fileName.endswith('fbx'):
                    filePath = os.path.join(parentDir, fileName)
                    fbxList.append(str(filePath))
                    pass
                pass
        pass
    # 打印
    for item in fbxList:
        logging.info("find fbx file: %s" % item)
        pass
    return fbxList
    pass # end func

# Matrix3D矩阵，通过FbxAMatrix初始化
# 使用主列矩阵，矩阵是反着的。
class Matrix3D(object):
    """docstring for Matrix3D"""
    def __init__(self, mt):
        super(Matrix3D, self).__init__()
        self.rawData = [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]
        for i in range(4):
            row = mt.GetRow(i)
            self.rawData[i * 4 + 0] = row[0]
            self.rawData[i * 4 + 1] = row[1]
            self.rawData[i * 4 + 2] = row[2]
            self.rawData[i * 4 + 3] = row[3]
            pass
        pass
    
    # 获取一列
    def getRaw(self, raw):
        vec = [0, 0, 0, 0]
        vec[0] = self.rawData[raw + 0];
        vec[1] = self.rawData[raw + 4];
        vec[2] = self.rawData[raw + 8];
        vec[3] = self.rawData[raw + 12];
        return vec
        pass
    
    # 获取一行
    def getColumn(self, column):
        vec = [0, 0, 0, 0]
        vec[0] = self.rawData[column * 4 + 0]
        vec[1] = self.rawData[column * 4 + 1]
        vec[2] = self.rawData[column * 4 + 2]
        vec[3] = self.rawData[column * 4 + 3]
        return vec
        pass # end func
    
    # deltaTransform
    def deltaTransformVector(self, vec):
        right = [self.rawData[0], self.rawData[4], self.rawData[8]]
        up    = [self.rawData[1], self.rawData[5], self.rawData[9]]
        ddir  = [self.rawData[2], self.rawData[6], self.rawData[10]]
        out   = [0, 0, 0]
        out[0] = vec[0] * right[0] + vec[1] * right[1] + vec[2] * right[2]
        out[1] = vec[0] * up[0]    + vec[1] * up[1]    + vec[2] * up[2]
        out[2] = vec[0] * ddir[0]  + vec[1] * ddir[1]  + vec[2] * ddir[2]
        return out
        pass
    
    # transform
    def transformVector(self, vec):
        right = [self.rawData[0],  self.rawData[4],  self.rawData[8]]
        up    = [self.rawData[1],  self.rawData[5],  self.rawData[9]]
        ddir  = [self.rawData[2],  self.rawData[6],  self.rawData[10]]
        out   = [self.rawData[12], self.rawData[13], self.rawData[14]]
        out[0] = out[0] + vec[0] * right[0] + vec[1] * right[1] + vec[2] * right[2]
        out[1] = out[1] + vec[0] * up[0]    + vec[1] * up[1]    + vec[2] * up[2]
        out[2] = out[2] + vec[0] * ddir[0]  + vec[1] * ddir[1]  + vec[2] * ddir[2]
        return out
        pass

# 获取GeometryTransform
def GetGeometryTransform(node):
    t = node.GetGeometricTranslation(FbxNode.eSourcePivot)
    r = node.GetGeometricRotation(FbxNode.eSourcePivot)
    s = node.GetGeometricScaling(FbxNode.eSourcePivot)
    return FbxAMatrix(t, r, s)
    pass # end func

# 生成FbxAMatrix数据
def getMatrix3DBytes(fbxAMatrix):
    matrix = Matrix3D(fbxAMatrix)
    data = b''
    # 丢弃最后一列数据
    for i in range(3):
        raw = matrix.getRaw(i)
        for j in range(len(raw)):
            data += struct.pack('<f', raw[j])
            pass
        pass
    return data
    pass # end func

# 生成Quat数据
def getQuatBytesFromAMatrix(fbxAMatrix):
    data = b''
    t = fbxAMatrix.GetT()
    q = fbxAMatrix.GetQ()
    data += struct.pack('<ffff', t[0], t[1], t[2], 0)
    data += struct.pack('<ffff', q[0], q[1], q[2], q[3])
    return data
    pass # end func

# 打印矩阵
def printFBXAMatrix(sstr, transform):
    logging.info("%s TX:%f\tTY:%f\tTZ:%f" % (sstr, transform.GetT()[0], transform.GetT()[1], transform.GetT()[2]))
    logging.info("%s RX:%f\tRY:%f\tRZ:%f" % (sstr, transform.GetR()[0], transform.GetR()[1], transform.GetR()[2]))
    logging.info("%s SX:%f\tSY:%f\tSZ:%f" % (sstr, transform.GetS()[0], transform.GetS()[1], transform.GetS()[2]))
    logging.info("%s RawData:%s" % (sstr, str(Matrix3D(transform).rawData)))
    pass # end func

# 解析FBX文件目录
def parseFilepath(fbxfile):
    filepath = re.compile("[\\\/]").split(fbxfile)[0:-1]
    filepath.append("")
    if sys.platform == 'win32':
        filepath = "\\".join(filepath)
        pass
    else:
        filepath = '/'.join(filepath)
        pass
    return filepath
    pass # end func

# 相机
class Camera3D(object):
    """docstring for Camera3D"""
    def __init__(self):
        super(Camera3D, self).__init__()
        self.fbxCamera          = None  # 相机
        self.name               = None  # 相机名称
        self.scene              = None  # scene
        self.sdkManager         = None  # sdkMangaer
        self.fbxFilePath        = None  # filepath
        self.near               = 0     # near
        self.far                = 3000  # far
        self.fieldOfView        = 1     # fieldofview
        self.aspectWidth        = 0
        self.aspectHeight       = 0
        self.anim               = []    # 动画
        self.fileName           = None  # 相机文件路径
        self.bytes              = None  # 相机数据
        pass # end func
    
    # 解析相机属性
    def parseCameraProperties(self):
        self.aspectWidth = self.fbxCamera.AspectWidth.Get()
        self.aspectHeight= self.fbxCamera.AspectHeight.Get()
        self.near        = self.fbxCamera.NearPlane.Get()
        self.far         = self.fbxCamera.FarPlane.Get()
        self.fieldOfView = self.fbxCamera.FieldOfView.Get()
        
        logging.info("\tAspect Width: %f" % self.aspectWidth)
        logging.info("\tAspect Height:%f" % self.aspectHeight)
        logging.info("\tNear         :%f" % self.near)
        logging.info("\tFar          :%f" % self.far)
        logging.info("\tFieldOfView  :%f" % self.fieldOfView)
        
        pass # end func
    
    # 解析相机动画
    def parseCameraAnim(self):
        # 获取stack
        stack = self.scene.GetSrcObject(FbxAnimStack.ClassId, 0)
        if not stack:
            return
            pass
        self.scene.SetCurrentAnimationStack(stack)
        # 获取时间
        timeSpan  = stack.GetLocalTimeSpan()
        time      = timeSpan.GetStart()
        # frameTime
        frameTime = FbxTime()
        frameTime.SetTime(0, 0, 0, 1, 0, self.scene.GetGlobalSettings().GetTimeMode())
        # 解析每一帧动画
        while time <= timeSpan.GetStop():
            animMt = AXIS_FLIP_L * self.fbxCamera.GetNode().EvaluateGlobalTransform(time) * self.invAxisTransform
            matrix = Matrix3D(animMt)
            clip   = []
            # 丢弃最后一列数据
            for i in range(3):
                raw = matrix.getRaw(i)
                for j in range(len(raw)):
                    clip.append(raw[j])
                    pass
                pass # end for
            self.anim.append(clip)
            time += frameTime
            pass
        
        pass # end func
    
    # 生成相机数据
    def generateBytes(self):
        # 生成Mesh对应的文件名称
        tokens  = re.compile("[\\\/]").split(self.fbxFilePath)
        fbxName = tokens[-1]
        fbxName = fbxName.split(".")[0:-1]
        fbxName = ".".join(fbxName)
        fbxDir  = parseFilepath(self.fbxFilePath)
        self.fileName = fbxDir + fbxName + "_" + self.name + CAMERA_TYPE
        # 数据
        self.bytes = b''
        size = len(str(self.name))
        self.bytes += struct.pack('<i', size)                   # 名称长度
        self.bytes += str(self.name)                            # 名称
        self.bytes += struct.pack('<f', self.aspectWidth)       # 宽度
        self.bytes += struct.pack('<f', self.aspectHeight)      # 高度
        self.bytes += struct.pack('<f', self.near)              # near
        self.bytes += struct.pack('<f', self.far)               # far
        self.bytes += struct.pack('<f', self.fieldOfView)       # fieldOfView
        # 保存相机当前位置
        animMt = AXIS_FLIP_L * self.fbxCamera.GetNode().EvaluateGlobalTransform() * self.invAxisTransform
        matrix = Matrix3D(animMt)
        # 丢弃最后一列数据
        for i in range(3):
            raw = matrix.getRaw(i)
            for j in range(len(raw)):
                self.bytes += struct.pack('<f', raw[j])
                pass
            pass
        # 保存相机动画
        size = len(self.anim)
        self.bytes += struct.pack('<i', size)                    # 动画长度
        # 写动画数据
        for i in range(size):
            clip = self.anim[i]
            for j in range(len(clip)):
                self.bytes += struct.pack('<f', clip[j])
                pass
            pass # end func
        
        # 压缩数据
        self.bytes = zlib.compress(self.bytes, 9)
        
        pass # end func
    
    # 通过FBXCamera初始化相机
    def initWithFbxCamera(self, fbxCamera, sdkManager, scene, filepath):
        logging.info("parse camera...")
        self.fbxCamera   = fbxCamera
        self.sdkManager  = sdkManager
        self.scene       = scene
        self.fbxFilePath = filepath
        # axis
        self.axisTransform    = AXIS_FLIP_L
        self.invAxisTransform = FbxAMatrix(self.axisTransform)
        self.invAxisTransform.Inverse()
        # 相机名称
        self.name = str(fbxCamera.GetNode().GetName())
        logging.info("\t%s" % self.name)
        # 解析相机属性
        self.parseCameraProperties()
        # 解析相机动画
        if config.anim:
            self.parseCameraAnim()
            pass
        # 生成数据
        self.generateBytes()
        # 写相机文件
        open(self.fileName, 'w+b').write(self.bytes)
        
        pass # end func

    pass # end class

# 骨骼节点
class SkeletonJoint(object):
    
    def __init__(self):
        super(SkeletonJoint, self).__init__()
        self.node           = None          # 骨骼Node
        self.name           = None          # 骨骼名称
        self.index          = -1            # 骨骼索引
        self.parentIndex    = -1            # 父级骨骼索引
        self.cluster        = None          # 骨骼
        self.linkTransform  = None          # link Transform
        pass # end func
    
    # 通过cluster初始化
    def initWithCluster(self, cluster):
        self.node = cluster.GetLink()
        self.name = str(self.node.GetName())
        self.cluster = cluster
        pass # end func
    
    pass # end class

# 场景
class Scene3D(object):

    """docstring for Scene3D"""
    def __init__(self):
        super(Scene3D, self).__init__()
        self.cameras = [] # 相机列表
        self.meshes  = [] # 模型列表
        self.lights  = [] # 灯光列表
        pass # end func
    
    pass # end class

# 材质
# 只会解析最基础的材质
class Material(object):
    
    def __init__(self):
        super(Material, self).__init__()
        
        self.material       = None      # 材质
        self.name           = None      # 材质名称
        self.textures       = {}        # 所有的贴图
        
        pass # end func
    
    # 初始化
    def initWithFbxMaterial(self, material):
        self.material = material
        self.name     = self.material.GetName() 
        for i in range(FbxLayerElement.sTypeTextureCount()):
            prop = self.material.FindProperty(FbxLayerElement.sTextureChannelNames(i))
            count = prop.GetSrcObjectCount(FbxTexture.ClassId)
            typeName = str(prop.GetName())
            if not self.textures.get(typeName):
                self.textures[typeName] = []
                pass
            for j in range(count):
                texture = prop.GetSrcObject(FbxTexture.ClassId, j)
                texName = re.compile("[\\\/]").split(texture.GetFileName())[-1]
                texName = texName.replace(".dds", ".png")
                texName = texName.replace(".tga", ".png")
                self.textures[typeName].append(texName)
                logging.info("\t%s -> %s" % (prop.GetName(), texName))
                pass
            pass
        pass # end func
        
    pass

# 模型
class Mesh(object):
    """docstring for Mesh"""
    def __init__(self):
        super(Mesh, self).__init__()
        self.fbxMesh            = None          # FbxMesh
        self.sdkManager         = None          # FbxSdk
        self.scene              = None          # FbxScene
        self.fbxFilePath        = None          # Fbx文件路径
        self.name               = None          # 模型名称
        self.skeleton           = False         # 是否为骨骼模型
        self.transform          = None          # transform
        self.geometryTransform  = None          # geometry矩阵
        self.axisTransform      = None          # 坐标系矩阵
        self.invAxisTransform   = None          # 坐标系逆矩阵
        self.vertices           = []            # 顶点
        self.uvs0               = []            # UV0
        self.uvs1               = []            # UV1,可能为烘焙贴图UV
        self.normals            = []            # 法线
        self.tangents           = []            # 切线
        self.weightsAndIndices  = []            # 权重以及索引
        self.bounds             = LObject()     # 包围盒
        self.anims              = []            # 动画|如果为骨骼模型，那么保存骨骼数据，否则就保存帧Transform数据
        self.verticesIndices    = []            # 顶点索引
        self.uvIndices          = []            # uv索引
        self.joints             = []            # 骨骼列表
        self.skeletonIndices    = {}            # 顶点索引，骨骼对应的顶点索引。
        self.skeletonWeights    = {}            # 骨骼权重，骨骼对应的顶点权重。
        self.meshBytes          = None          # Mesh数据
        self.animBytes          = None          # 动作数据
        self.meshFileName       = None          # Mesh文件名
        self.animFileName       = None          # Anim文件名
        self.bounds.min         = [0, 0, 0]     # min
        self.bounds.max         = [0, 0, 0]     # max
        self.geometries         = []            # sub geometry
        self.material           = None          # 材质
        self.mounts             = {}            # 挂接点
        
        pass #end func
    
    # 解析矩阵
    def parseTransform(self):
        logging.info("\tparse transform...")
        self.geometryTransform  = GetGeometryTransform(self.fbxMesh.GetNode())
        # 当geometry启用时，world将会失效
        if config.geometry:
            self.axisTransform = AXIS_FLIP_L * self.geometryTransform
            pass
        elif config.world:
            self.axisTransform = AXIS_FLIP_L * self.fbxMesh.GetNode().EvaluateGlobalTransform() * self.geometryTransform
            pass
        else:
            self.axisTransform = AXIS_FLIP_L * self.fbxMesh.GetNode().EvaluateLocalTransform() * self.geometryTransform
            pass
        # invert axis transform
        self.invAxisTransform = FbxAMatrix(self.axisTransform)
        self.invAxisTransform = self.invAxisTransform.Inverse()
        # 启用geometry
        if config.geometry:
            self.transform = AXIS_FLIP_L * self.fbxMesh.GetNode().EvaluateGlobalTransform() * self.geometryTransform * self.invAxisTransform
            pass
        elif config.world:
            self.transform = FbxAMatrix()
            pass
        else:
            self.transform = AXIS_FLIP_L * self.fbxMesh.GetNode().EvaluateGlobalTransform() * self.geometryTransform * self.invAxisTransform
            pass
        
        printFBXAMatrix("\tTransform Matrix:", self.transform)
        
        pass # end func
    
    # 解析索引
    def parseIndices(self):
        logging.info("\tparse indices...")
        count = self.fbxMesh.GetPolygonCount()
        logging.info("\ttriangle num:%d" % (count))
        for i in range(count):
            for j in range(3):
                # 顶点索引
                vertIdx = self.fbxMesh.GetPolygonVertex(i, j)
                self.verticesIndices.append(vertIdx)
                # uv索引
                uvIdx = self.fbxMesh.GetTextureUVIndex(i, j)
                self.uvIndices.append(uvIdx)
                pass # end for
            pass # end for
        pass # end func
    
    # 解析包围盒，骨骼动画不会解析每一帧包围盒
    def parseBounds(self):
        count = len(self.vertices)
        vert = self.vertices[0]
        self.bounds.min = [vert[0], vert[1], vert[2]]
        self.bounds.max = [vert[0], vert[1], vert[2]]
        for i in range(count):
            vert = self.vertices[i]
            if vert[0] < self.bounds.min[0]:
                self.bounds.min[0] = vert[0]
                pass
            if vert[1] < self.bounds.min[1]:
                self.bounds.min[1] = vert[1]
                pass
            if vert[2] < self.bounds.min[2]:
                self.bounds.min[2] = vert[2]
                pass
            if vert[0] > self.bounds.max[0]:
                self.bounds.max[0] = vert[0]
                pass
            if vert[1] > self.bounds.max[1]:
                self.bounds.max[1] = vert[1]
                pass
            if vert[2] > self.bounds.max[2]:
                self.bounds.max[2] = vert[2]
                pass
            pass # end func
        logging.info("\tbounds:Min[%f %f %f] Max:[%f %f %f]" % (self.bounds.min[0], self.bounds.min[1], self.bounds.min[2], self.bounds.max[0], self.bounds.max[1], self.bounds.max[2]))
        pass # end func
    
    # 解析顶点
    def parseVertices(self):
        logging.info("\tparse vertex...")
        count = self.fbxMesh.GetControlPointsCount()
        points= self.fbxMesh.GetControlPoints()
        for i in range(count):
            vert = points[i]
            self.vertices.append(vert)
            pass # end for
        # 组织顶点数据
        vertices = []
        count = len(self.verticesIndices)
        for i in range(count):
            idx = self.verticesIndices[i]
            vert= self.vertices[idx]
            vertices.append(vert)
            pass
        self.vertices = vertices
        logging.info("\tvetex num:%d" % (len(self.vertices)))
        # 对顶点坐标轴转换
        count = len(self.vertices)
        for i in range(count):
            vert = self.vertices[i]
            vert = self.axisTransform.MultT(vert)
            self.vertices[i] = [vert[0], vert[1], vert[2]]
            pass # end for
        # 重构顶点索引顺序
        count = count / 3
        for i in range(count):
            v0 = self.vertices[i * 3 + 0]
            v1 = self.vertices[i * 3 + 1]
            v2 = self.vertices[i * 3 + 2]
            self.vertices[i * 3 + 0] = v2
            self.vertices[i * 3 + 1] = v1
            self.vertices[i * 3 + 2] = v0
            pass # end for
        # 解析包围盒
        self.parseBounds()
        pass # end func
    
    # 解析UV0
    def parseUV0(self):
        layerCount = self.fbxMesh.GetLayerCount()
        # 解析UV0
        if layerCount >= 1:
            logging.info("\tparse UV0...")
            uvs   = self.fbxMesh.GetLayer(0).GetUVs()
            data  = uvs.GetDirectArray()
            polygonCount = self.fbxMesh.GetPolygonCount()
            vertIdx = 0
            for i in range(polygonCount):
                for j in range(3):
                    controlPointIndex = self.fbxMesh.GetPolygonVertex(i, j)
                    # by point
                    if uvs.GetMappingMode() == FbxLayerElement.eByControlPoint:
                        if uvs.GetReferenceMode() == FbxLayerElement.eDirect:
                            uv = data.GetAt(controlPointIndex)
                            pass
                        elif uvs.GetReferenceMode() == FbxLayerElement.eIndexToDirect:
                            idx = uvs.GetIndexArray().GetAt(controlPointIndex)
                            uv = data.GetAt(idx)
                            pass
                        pass # end if
                    elif uvs.GetMappingMode() == FbxLayerElement.eByPolygonVertex:
                        if uvs.GetReferenceMode() == FbxLayerElement.eDirect:
                            uv = data.GetAt(vertIdx)
                            pass #end
                        elif uvs.GetReferenceMode() == FbxLayerElement.eIndexToDirect:
                            idx = uvs.GetIndexArray().GetAt(vertIdx)
                            uv = data.GetAt(idx)
                            pass
                        pass # end
                    self.uvs0.append([uv[0], 1 - uv[1]])
                    vertIdx += 1
                    pass # end for polygon size
                pass # end for polygon count
            logging.info("\tUV0 num:%d" % (len(self.uvs0)))
            # 重构uv0索引顺序
            count = len(self.uvs0)
            count = count / 3
            for i in range(count):
                v0 = self.uvs0[i * 3 + 0]
                v1 = self.uvs0[i * 3 + 1]
                v2 = self.uvs0[i * 3 + 2]
                self.uvs0[i * 3 + 0] = v2
                self.uvs0[i * 3 + 1] = v1
                self.uvs0[i * 3 + 2] = v0
                pass # end for
            pass # end if
        pass # end func
    
    # 解析UV1
    def parseUV1(self):
        layerCount = self.fbxMesh.GetLayerCount()
        if layerCount >= 2:
            logging.info("\tparse UV1...")
            uvs   = self.fbxMesh.GetLayer(1).GetUVs()
            data  = uvs.GetDirectArray()
            polygonCount = self.fbxMesh.GetPolygonCount()
            vertIdx = 0
            for i in range(polygonCount):
                for j in range(3):
                    controlPointIndex = self.fbxMesh.GetPolygonVertex(i, j)
                    # by point
                    if uvs.GetMappingMode() == FbxLayerElement.eByControlPoint:
                        if uvs.GetReferenceMode() == FbxLayerElement.eDirect:
                            uv = data.GetAt(controlPointIndex)
                            pass
                        elif uvs.GetReferenceMode() == FbxLayerElement.eIndexToDirect:
                            idx = uvs.GetIndexArray().GetAt(controlPointIndex)
                            uv = data.GetAt(idx)
                            pass
                        pass # end if
                    elif uvs.GetMappingMode() == FbxLayerElement.eByPolygonVertex:
                        if uvs.GetReferenceMode() == FbxLayerElement.eDirect:
                            uv = data.GetAt(vertIdx)
                            pass #end
                        elif uvs.GetReferenceMode() == FbxLayerElement.eIndexToDirect:
                            idx = uvs.GetIndexArray().GetAt(vertIdx)
                            uv = data.GetAt(idx)
                            pass
                        pass # end
                    self.uvs1.append([uv[0], 1 - uv[1]])
                    vertIdx += 1
                    pass # end for
                pass # end for
            logging.info("\tUV1 num:%d" % (len(self.uvs1)))
            # 重构uv1索引顺序
            count = len(self.uvs1)
            count = count / 3
            for i in range(count):
                v0 = self.uvs1[i * 3 + 0]
                v1 = self.uvs1[i * 3 + 1]
                v2 = self.uvs1[i * 3 + 2]
                self.uvs1[i * 3 + 0] = v2
                self.uvs1[i * 3 + 1] = v1
                self.uvs1[i * 3 + 2] = v0
                pass # end for
            pass # end if
        pass # end func
    
    # 解析法线
    def parseNormals(self):
        logging.info("\tparse normals...")
        normals = self.fbxMesh.GetLayer(0).GetNormals()
        if not normals:
            return
            pass
        data = normals.GetDirectArray()
        polygonCount = self.fbxMesh.GetPolygonCount()
        vertIdx = 0
        for i in range(polygonCount):
            for j in range(3):
                controlPointIndex = self.fbxMesh.GetPolygonVertex(i, j)
                # by point
                if normals.GetMappingMode() == FbxLayerElement.eByControlPoint:
                    if normals.GetReferenceMode() == FbxLayerElement.eDirect:
                        nrm = data.GetAt(controlPointIndex)
                        pass
                    elif normals.GetReferenceMode() == FbxLayerElement.eIndexToDirect:
                        idx = normals.GetIndexArray().GetAt(controlPointIndex)
                        nrm = data.GetAt(idx)
                        pass
                    pass # end if
                elif normals.GetMappingMode() == FbxLayerElement.eByPolygonVertex:
                    if normals.GetReferenceMode() == FbxLayerElement.eDirect:
                        nrm = data.GetAt(vertIdx)
                        pass #end
                    elif normals.GetReferenceMode() == FbxLayerElement.eIndexToDirect:
                        idx = normals.GetIndexArray().GetAt(vertIdx)
                        nrm = data.GetAt(idx)
                        pass
                    pass # end
                self.normals.append(nrm)
                vertIdx += 1
                pass # end for
            pass # end for
        
        # 对法线进行转换
        count = len(self.normals)
        axis  = Matrix3D(self.axisTransform)
        for i in range(count):
            nrm = self.normals[i]
            nrm = axis.deltaTransformVector(nrm)
            nrm = FbxVector4(nrm[0], nrm[1], nrm[2], 1)
            nrm.Normalize()
            self.normals[i] = [nrm[0], nrm[1], nrm[2]]
            pass # end for
        # 重构法线索引顺序
        count = count / 3
        for i in range(count):
            v0 = self.normals[i * 3 + 0]
            v1 = self.normals[i * 3 + 1]
            v2 = self.normals[i * 3 + 2]
            self.normals[i * 3 + 0] = v2
            self.normals[i * 3 + 1] = v1
            self.normals[i * 3 + 2] = v0
            pass # end for
        pass # end func
    
    # 解析切线
    def parseTangent(self):  
        logging.info("\tparse tangents...")
        if not config.normal:
            self.parseNormals()
            pass
        # 计算切线
        self.fbxMesh.GenerateTangentsDataForAllUVSets()
        tangents = self.fbxMesh.GetLayer(0).GetTangents()
        count    = tangents.GetDirectArray().GetCount()
        data     = tangents.GetDirectArray()
        logging.info("\ttangent num:%d" % count)
        for i in range(count):
            self.tangents.append(data.GetAt(i))
            pass
        # 对切线进行转换
        count = len(self.tangents)
        axis  = Matrix3D(self.axisTransform)
        for i in range(count):
            tan = self.tangents[i]
            tan = axis.deltaTransformVector(tan)
            tan = FbxVector4(tan[0], tan[1], tan[2], 1)
            tan.Normalize()
            self.tangents[i] = [tan[0], tan[1], tan[2]]
            pass # end for
        # 重构切线索引顺序
        count = count / 3
        for i in range(count):
            v0 = self.tangents[i * 3 + 0]
            v1 = self.tangents[i * 3 + 1]
            v2 = self.tangents[i * 3 + 2]
            self.tangents[i * 3 + 0] = v2
            self.tangents[i * 3 + 1] = v1
            self.tangents[i * 3 + 2] = v0
            pass # end for
        pass # end func
    
    # 解析权重以及索引
    def parseIndicesAndWeights(self):
        
        count = self.fbxMesh.GetControlPointsCount()
        indicesAndWeights = []
        
        for i in range(count):
            skeJoints  = self.skeletonIndices[i]
            skeWeights = self.skeletonWeights[i]
            indices    = []
            weights    = []
            size = len(skeJoints)
            # 最多允许四个权重
            if size > MAX_WEIGHT_NUM:
                size = MAX_WEIGHT_NUM
                pass
            # 保存权重以及索引数据
            for j in range(size):
                weights.append(skeWeights[j])
                indices.append(skeJoints[j].index)
                pass
            for j in range(MAX_WEIGHT_NUM - size):
                weights.append(0)
                indices.append(0)
                pass
            indicesAndWeights.append(weights + indices)
            pass
        # 组织权重数据
        count = self.fbxMesh.GetPolygonCount()
        for i in range(count):
            for j in range(3):
                # 顶点索引
                vertIdx = self.fbxMesh.GetPolygonVertex(i, j)
                self.weightsAndIndices.append(indicesAndWeights[vertIdx])
                pass
            pass
        # 重构索引
        for i in range(count):
            v0 = self.weightsAndIndices[i * 3 + 0]
            v1 = self.weightsAndIndices[i * 3 + 1]
            v2 = self.weightsAndIndices[i * 3 + 2]
            self.weightsAndIndices[i * 3 + 0] = v2
            self.weightsAndIndices[i * 3 + 1] = v1
            self.weightsAndIndices[i * 3 + 2] = v0
            pass # end for
        
        pass # end func
    
    # 解析骨骼权重以及索引
    def parseCluster(self):   
        logging.info("\tparse skeleton...")
        skinDeformer = self.fbxMesh.GetDeformer(0, FbxDeformer.eSkin)
        clusterCount = skinDeformer.GetClusterCount()
        logging.info("\tmesh:[%s] has %d bones..." % (self.name, clusterCount))
        for clusterIdx in range(clusterCount):
            cluster = skinDeformer.GetCluster(clusterIdx)
            joint   = SkeletonJoint()
            joint.initWithCluster(cluster)
            joint.index = clusterIdx
            self.joints.append(joint)
            logging.info("\tBoneName:%s" % joint.name)
            # 解析骨骼权重以及顶点索引
            indices = cluster.GetControlPointIndices()          # 顶点的索引
            weights = cluster.GetControlPointWeights()          # 顶点的权重
            count   = len(indices)
            for i in range(count):
                verIdx = indices[i]
                weight = weights[i]
                # 顶点还未被记录到字典
                if not self.skeletonIndices.get(verIdx):
                    self.skeletonIndices[verIdx] = []
                    self.skeletonWeights[verIdx] = []
                    pass
                # 将骨骼保存到对应的顶点中去
                self.skeletonIndices[verIdx].append(joint)
                # 将权重保存到对应的顶点中去
                self.skeletonWeights[verIdx].append(weight)
                pass # end for
            pass # end for
        pass # end
    
    # 解析骨骼的帧动画
    def parseJointFrameAnim(self, joint, time):
        cluster = joint.cluster
        # 获取当前帧骨骼的global transform
        frameGlobalTransform = cluster.GetLink().EvaluateGlobalTransform(time)
        # 获取bindtransform
        bindTransform  = FbxAMatrix()
        cluster.GetTransformMatrix(bindTransform)
        bindTransform *= self.geometryTransform
        # 骨骼global初始矩阵
        clusterGlobalInitTransform = FbxAMatrix()
        cluster.GetTransformLinkMatrix(clusterGlobalInitTransform)
        # 转换 vert * axis * invAxis * bindTransform * invGlobalInit * BoneGlobal * InvMeshGlobal * AXIS_FLIP_X
        vertexTransform = AXIS_FLIP_L * frameGlobalTransform * clusterGlobalInitTransform.Inverse() * bindTransform * self.invAxisTransform
        return vertexTransform
        pass
    
    # 解析骨骼动画
    def parseSkeletonAnim(self, time):
        clip  = []
        count = len(self.joints)
        for i in range(count):
            clip.append(self.parseJointFrameAnim(self.joints[i], time))
            pass # end func
        self.anims.append(clip)
        
        boneCount = self.scene.GetSrcObjectCount(FbxSkeleton.ClassId)
        for i in range(boneCount):
            skeleton = self.scene.GetSrcObject(FbxSkeleton.ClassId, i)
            boneName = skeleton.GetNode().GetName()
            boneNode = skeleton.GetNode()
            if boneName in config.mount:
                if not self.mounts.get(boneName):
                    self.mounts[boneName] = []
                    pass # end dict
                transform   = boneNode.EvaluateGlobalTransform(time)
                invTansform = FbxAMatrix(AXIS_FLIP_L)
                invTansform = invTansform.Inverse()
                transform   = AXIS_FLIP_L * transform * invTansform
                self.mounts[boneName].append(transform)
                pass # end in mount
            pass # end for
        pass
    
    # 解析帧动画
    def parseFrameAnim(self, time):
        # 检查使用的模式。如果使用world模式，那么需要转换帧动画
        animMt = AXIS_FLIP_L * self.fbxMesh.GetNode().EvaluateGlobalTransform(time) * self.geometryTransform * self.invAxisTransform
        matrix = Matrix3D(animMt)
        clip   = []
        # 丢弃最后一列数据
        for i in range(3):
            raw = matrix.getRaw(i)
            for j in range(len(raw)):
                clip.append(raw[j])
                pass
            pass
        # 保存数据
        self.anims.append(clip)
        pass # end func
    
    # 解析动画
    def parseAnim(self):
        logging.info("\tparse animation...")
        # 检测是否为骨骼动画
        skinCount = self.fbxMesh.GetDeformerCount(FbxDeformer.eSkin)
        self.skeleton = skinCount > 0
        logging.info("\tis skeleton:%s" % str(self.skeleton))
        # 如果为骨骼动画，则需要事先解析骨骼
        if self.skeleton:
            self.parseCluster()
            self.parseIndicesAndWeights()
            pass #
        # 获取stack
        stack = self.scene.GetSrcObject(FbxAnimStack.ClassId, 0)
        if not stack:
            return
            pass
        self.scene.SetCurrentAnimationStack(stack)
        # 获取时间
        timeSpan  = stack.GetLocalTimeSpan()
        time      = timeSpan.GetStart()
        # frameTime
        frameTime = FbxTime()
        frameTime.SetTime(0, 0, 0, 1, 0, self.scene.GetGlobalSettings().GetTimeMode())
        # 解析每一帧动画
        while time <= timeSpan.GetStop():
            if self.skeleton:                           
                self.parseSkeletonAnim(time)            # 解析骨骼动画
                pass
            else:
                self.parseFrameAnim(time)               # 解析帧动画
                pass
            time += frameTime
            pass
        
        pass # end func
    
    # 生成模型数据
    def generateMeshBytes(self):
        # 生成Mesh对应的文件名称
        tokens  = re.compile("[\\\/]").split(self.fbxFilePath)
        fbxName = tokens[-1]
        fbxName = fbxName.split(".")[0:-1]
        fbxName = ".".join(fbxName)
        fbxDir  = parseFilepath(self.fbxFilePath)
        self.meshFileName = fbxDir + fbxName + "_" + self.name + MESH_TYPE
        # 组织Mesh数据
        data = b''
        # 写名称
        data += struct.pack('<i', len(self.name)) 
        data += str(self.name)
        # 写坐标
        data += getMatrix3DBytes(self.transform)
        # 写SubMesh数量
        subNum = len(self.geometries)
        data  += struct.pack("<i", subNum)
        # 写数据
        for subIdx in range(subNum):
            subMesh = self.geometries[subIdx]
            # 写顶点
            count = len(subMesh.vertices)
            data += struct.pack('<i', count)            
            for i in range(count):                     
                vert = subMesh.vertices[i]
                data += struct.pack('<fff', vert[0], vert[1], vert[2])
                pass # end for
            # 写UV0
            count = len(subMesh.uvs0)                      
            data += struct.pack('<i', count)
            for i in range(count):
                uv = subMesh.uvs0[i]
                data += struct.pack('<ff', uv[0], uv[1])
                pass # end for
            # 写UV1
            count = len(subMesh.uvs1)
            data += struct.pack('<i', count)
            for i in range(count):
                uv = subMesh.uvs1[i]
                data += struct.pack('<ff', uv[0], uv[1])
                pass # end for 
            # 写法线
            count = len(subMesh.normals)
            data += struct.pack('<i', count)
            for i in range(count):
                normal = subMesh.normals[i]
                data  += struct.pack('<fff', normal[0], normal[1], normal[2])
                pass
            count = len(subMesh.tangents)
            data += struct.pack('<i', count)
            for i in range(count):
                tan   = subMesh.tangents[i]
                data += struct.pack('<fff', tan[0], tan[1], tan[2])
                pass
            # 写权重数据
            count = len(subMesh.weightsAndIndices)
            data += struct.pack('<i', count)
            for i in range(count):
                weIdx = subMesh.weightsAndIndices[i]
                data += struct.pack('<ffff', weIdx[0], weIdx[1], weIdx[2], weIdx[3])
                pass # end
            count = len(subMesh.weightsAndIndices)
            data += struct.pack('<i', count)
            
            step = 3
            if config.quat:
                step = 2
                pass
            # 写骨骼索引数据
            for i in range(count):
                weIdx = subMesh.weightsAndIndices[i]
                data += struct.pack('<ffff', weIdx[4] * step, weIdx[5] * step, weIdx[6] * step, weIdx[7] * step)
                pass
            
            pass # end for
        
        # 写包围盒数据
        data += struct.pack('<ffffff', self.bounds.min[0], self.bounds.min[1], self.bounds.min[2], self.bounds.max[0], self.bounds.max[1], self.bounds.max[2])
        # 压缩
        data = zlib.compress(data, 9)
        
        self.meshBytes = data
        pass # end func
    
    # 生成帧动画数据
    def generateFrameAnimBytes(self):
        data = b''
        # 写入动画类型
        data += struct.pack('<i', 0)
        # 写入帧数
        count = len(self.anims)
        data += struct.pack('<i', count)
        # 写入数据
        for i in range(count):
            clip = self.anims[i]
            for j in range(len(clip)):
                data += struct.pack('<f', clip[j])
                pass
            pass
        return data
        pass # end func
    
    # 生成骨骼动画数据
    def generateSkeletonAnimBytes(self):
        data = b''
        # 类型
        t = 1
        if config.quat:
            t = 2
            pass
        data += struct.pack('<i', t)
        # 写入SubMe数量
        subNum= len(self.geometries)
        data += struct.pack('<i', subNum)
        # 写动画数据
        for subIdx in range(subNum):
            subMesh = self.geometries[subIdx]
            # 写入帧数
            count = len(subMesh.anims)
            data += struct.pack('<i', count)
            # 写入骨骼数量
            data += struct.pack('<i', len(subMesh.joints))
            # 写入数据
            for i in range(count):
                clip = subMesh.anims[i]
                for j in range(len(clip)):
                    if config.quat:
                        data += getQuatBytesFromAMatrix(clip[j])
                        pass
                    else:
                        data += getMatrix3DBytes(clip[j])
                        pass
                    pass # end for
                pass # end for
            pass
        
        # 写帧数
        frameCount = len(subMesh.anims)
        data += struct.pack('<i', frameCount)
        # 写挂接点数据
        count = len(self.mounts)
        data += struct.pack('<i', count)
        for key in self.mounts:
            ssize = len(key)
            # 写挂接点名称
            data += struct.pack('<i', ssize)
            data += str(key)
            # 写挂接点每一帧数据
            bones = self.mounts.get(key)
            for i in range(frameCount):
                data += getMatrix3DBytes(bones[i])
                pass
            pass
        return data
        pass # end func
    
    # 生成动画数据
    def generateAnimBytes(self):
        # 生成Mesh对应的文件名称
        tokens  = re.compile("[\\\/]").split(self.fbxFilePath)
        fbxName = tokens[-1]
        fbxName = fbxName.split(".")[0:-1]
        fbxName = ".".join(fbxName)
        fbxDir  = parseFilepath(self.fbxFilePath)
        self.animFileName = fbxDir + fbxName + "_" + self.name + ANIM_TYPE
        # 动画类型:0->帧动画;1->矩阵骨骼动画;2->四元数骨骼动画
        data = None
        if self.skeleton:
            data = self.generateSkeletonAnimBytes()
            pass
        else:
            data = self.generateFrameAnimBytes()
            pass
        data = zlib.compress(data, 9)
        self.animBytes = data
        pass # end func
    
    # 拆分模型
    def splitMesh(self):
        # 不需要进行拆分
        if not self.isNeedSplit():
            self.geometries.append(self)
            return
            pass
        # 拆分顶点数据
        subMeshes = self.splitVertex()
        # 对拆分出来的顶点数据进行骨骼拆分
        for subMesh in subMeshes:
            self.geometries += subMesh.splitBones()
            pass
        logging.info("splitMesh:%d" % (len(self.geometries)))
        pass # end func
    
    # 拆分顶点数据:vertex,uv0,uv1,normal,weightsAndIndices
    def splitVertex(self):
        count = len(self.vertices)
        # 未达到拆分条件
        if count < MAX_VERTEX_NUM:
            return [self]
            pass
        # 开始拆分
        idx = 0
        subMeshes = []
        while idx < count:
            subMesh = Mesh()
            # 拷贝属性
            subMesh.fbxMesh             = self.fbxMesh
            subMesh.sdkManager          = self.sdkManager
            subMesh.scene               = self.scene
            subMesh.fbxFilePath         = self.fbxFilePath
            subMesh.name                = str(self.name + str(len(subMeshes)))
            subMesh.skeleton            = self.skeleton
            subMesh.geometryTransform   = self.geometryTransform
            subMesh.axisTransform       = self.axisTransform
            subMesh.invAxisTransform    = self.invAxisTransform
            subMesh.material            = self.material
            subMesh.transform           = self.transform
            # 拆分数据
            # 顶点
            subMesh.vertices            = self.vertices[idx : idx + MAX_VERTEX_NUM]
            # UV0
            subMesh.uvs0                = self.uvs0[idx : idx + MAX_VERTEX_NUM]
            # UV1
            subMesh.uvs1                = self.uvs1[idx : idx + MAX_VERTEX_NUM]
            # Normal
            subMesh.normals             = self.normals[idx : idx + MAX_VERTEX_NUM]
            # tangent
            subMesh.tangents            = self.tangents[idx : idx + MAX_VERTEX_NUM]
            # 权重索引
            subMesh.weightsAndIndices   = self.weightsAndIndices[idx : idx + MAX_VERTEX_NUM]
            # 包围盒
            subMesh.bounds.min          = self.bounds.min[0:]
            subMesh.bounds.max          = self.bounds.max[0:]
            # 动画
            subMesh.anims               = self.anims[0:]
            # 骨骼
            subMesh.joints              = self.joints[0:]
            # 挂接点
            subMesh.mounts              = self.mounts
            # ʕ•̫͡•ʕ*̫͡*ʕ
            idx += MAX_VERTEX_NUM
            # 添加到geometries
            subMeshes.append(subMesh)
            pass
        return subMeshes
        pass # end func
    
    # 拆分骨骼数据
    def splitBones(self):
        if not self.skeleton:
            return [self]
            pass
        count = len(self.joints)
        maxNum= 0
        if config.quat:
            # 使用四元数并且骨骼数量少于最大骨骼数
            if count < config.max_quat:
                return [self]
                pass
            # 使用四元数，骨骼数量大于最大骨骼数
            maxNum = config.max_quat
            pass
        else:
            # 使用矩阵并且骨骼数量少于最大骨骼数
            if count < config.max_m34:
                return [self]
                pass
            # 使用矩阵，骨骼数量大于最大骨骼数
            maxNum = config.max_m34
            pass
        # 开始进行骨骼拆分
        count = len(self.vertices)
        count = count / 3
        # list
        subMeshes = []
        subMesh   = Mesh()
        subMesh.name = self.name + str(len(subMeshes))
        subMeshes.append(subMesh)
        # 遍历所有三角形
        for i in range(count):
            v0 = i * 3 + 0
            v1 = i * 3 + 1
            v2 = i * 3 + 2
            # 搜集三角形的所有骨骼
            idx0 = self.weightsAndIndices[v0][4:]
            idx1 = self.weightsAndIndices[v1][4:]
            idx2 = self.weightsAndIndices[v2][4:]
            idxs = idx0 + idx1 + idx2
            # 去掉重复索引
            idxs = list(set(idxs))
            # 将新索引添加subMesh中，并且检查骨骼数量是否超限
            bones = set(subMesh.joints + idxs)
            # 添加当前三角形之后，subMesh超限->创建新的subMesh
            if len(bones) > maxNum:
                subMesh = Mesh()
                subMesh.name = self.name + str(len(subMeshes))
                subMeshes.append(subMesh)
                pass
            # 保存骨骼索引
            subMesh.joints = list(set(subMesh.joints + idxs))
            # 将三角形数据添加到当前三角形
            # 顶点
            subMesh.vertices.append(self.vertices[v0])
            subMesh.vertices.append(self.vertices[v1])
            subMesh.vertices.append(self.vertices[v2])
            # uv0
            if len(self.uvs0) > 0:
                subMesh.uvs0.append(self.uvs0[v0])
                subMesh.uvs0.append(self.uvs0[v1])
                subMesh.uvs0.append(self.uvs0[v2])
                pass
            # uv1
            if len(self.uvs1) > 0:
                subMesh.uvs1.append(self.uvs1[v0])
                subMesh.uvs1.append(self.uvs1[v1])
                subMesh.uvs1.append(self.uvs1[v2])
                pass
            # normal
            if len(self.normals) > 0:
                subMesh.normals.append(self.normals[v0])
                subMesh.normals.append(self.normals[v1])
                subMesh.normals.append(self.normals[v2])
                pass
            # tangent
            if len(self.tangents) > 0:
                subMesh.tangents.append(self.tangents[v0])
                subMesh.tangents.append(self.tangents[v1])
                subMesh.tangents.append(self.tangents[v2])
                pass
            # 权重以及索引
            if len(self.weightsAndIndices) > 0:
                subMesh.weightsAndIndices.append(self.weightsAndIndices[v0])
                subMesh.weightsAndIndices.append(self.weightsAndIndices[v1])
                subMesh.weightsAndIndices.append(self.weightsAndIndices[v2])
                pass
            pass
        # 重构数据
        for subMesh in subMeshes:
            # 拷贝属性
            subMesh.fbxMesh             = self.fbxMesh
            subMesh.sdkManager          = self.sdkManager
            subMesh.scene               = self.scene
            subMesh.fbxFilePath         = self.fbxFilePath
            subMesh.skeleton            = self.skeleton
            subMesh.geometryTransform   = self.geometryTransform
            subMesh.axisTransform       = self.axisTransform
            subMesh.invAxisTransform    = self.invAxisTransform
            subMesh.material            = self.material
            subMesh.transform           = self.transform
            subMesh.mounts              = self.mounts
            # 重构骨骼索引
            joints  = []
            oldIndexMap = {}
            newIndexMap = {}
            for idx in subMesh.joints:
                # 保存新旧索引
                oldIndexMap[idx] = len(joints)
                newIndexMap[len(joints)] = idx
                # 保存骨骼 
                joints.append(self.joints[idx])
                pass
            # 设置骨骼
            subMesh.joints = joints
            # 重写权重索引数据
            count = len(subMesh.weightsAndIndices)
            for i in range(count):
                weIdx = subMesh.weightsAndIndices[i]
                subMesh.weightsAndIndices[i] = [weIdx[0], weIdx[1], weIdx[2], weIdx[3], oldIndexMap[weIdx[4]], oldIndexMap[weIdx[5]], oldIndexMap[weIdx[6]], oldIndexMap[weIdx[7]]]
                pass
            
            # 重写动画数据
            frameSize = len(self.anims)
            for i in range(frameSize):
                clip = []
                # 遍历subMesh的Joints
                size = len(subMesh.joints)
                for j in range(size):
                    # 通过新索引获取旧索引
                    idx = newIndexMap[j]
                    clip.append(self.anims[i][idx])
                    pass
                subMesh.anims.append(clip)
                pass
            
            pass
        return subMeshes
        pass # end func
    
    # 检测模型是否需要进行拆分
    def isNeedSplit(self):
        # 检测顶点是否超过65535
        isNeed = len(self.vertices) > MAX_VERTEX_NUM
        # 顶点超过65535
        if isNeed:
            return True
            pass
        # 检测是否为骨骼模型
        if not self.skeleton:
            return False
            pass
        # 检测骨骼数量
        if config.quat:     # 使用四元数
            return len(self.joints) > config.max_quat
            pass
        else:               # 使用矩阵
            return len(self.joints) > config.max_m34
            pass
        return False
        pass # end func
    
    # 解析材质，只解析第一层材质
    def parseMaterial(self):
        logging.info("\tparse materials...")
        count = self.fbxMesh.GetNode().GetMaterialCount()
        if count == 0:
            return
        self.material = Material()
        self.material.initWithFbxMaterial(self.fbxMesh.GetNode().GetMaterial(0))
        pass
    
    # 初始化mesh
    def initWithFbxMesh(self, fbxMesh, sdkManager, scene, fbxFilePath):
        
        logging.info("\tparse mesh...")
        
        self.fbxMesh    = fbxMesh
        self.sdkManager = sdkManager
        self.scene      = scene
        self.name       = str(fbxMesh.GetNode().GetName())
        self.fbxFilePath= fbxFilePath
        
        logging.info("\t%s" % (self.name))
        # 解析矩阵
        self.parseTransform()
        # 解析索引
        self.parseIndices()
        # 解析控制点
        self.parseVertices()
        # 解析UV0
        if config.uv0:
            self.parseUV0()
        # 解析UV1
        if config.uv1:
            self.parseUV1()
        # 解析法线
        if config.normal:
            self.parseNormals()
        # 解析切线
        if config.tangent:
            self.parseTangent()
        # 解析动画
        if config.anim:
            self.parseAnim()
        # 解析材质
        self.parseMaterial()
        # 拆分Mesh
        self.splitMesh() 
        # 生成模型数据
        self.generateMeshBytes()
        # 生成动画数据
        self.generateAnimBytes()
        # 写模型数据
        open(self.meshFileName, 'w+b').write(self.meshBytes)
        # 写动画数据
        if config.anim:
            open(self.animFileName, 'w+b').write(self.animBytes)
        
        pass
        
    pass # end class

# 解析相机
def parseCameras(sdkManager, scene, filepath):
    logging.info("parse cameras...")
    count = scene.GetSrcObjectCount(FbxCamera.ClassId)
    logging.info("\tcamera num:%d" % (count))
    cameras = []
    for i in range(count):
        fbxCamera = scene.GetSrcObject(FbxCamera.ClassId, i)
        camera = Camera3D()
        camera.initWithFbxCamera(fbxCamera, sdkManager, scene, filepath)
        cameras.append(camera)
        pass # end for
    return cameras
    pass # end func

# 解析所有的模型
def parseMeshes(sdkManager, scene, filepath):
    logging.info("\tparse meshes...")
    count = scene.GetSrcObjectCount(FbxMesh.ClassId)
    logging.info("\tmesh num:%d" % (count))
    meshes = []
    for i in range(count):
        fbxMesh = scene.GetSrcObject(FbxMesh.ClassId, i)
        mesh = Mesh()
        mesh.initWithFbxMesh(fbxMesh, sdkManager, scene, filepath)
        meshes.append(mesh)
        pass # end for
    return meshes
    pass # end func

# 获取模型配置
def getMeshConfig(mesh):
    meshName = re.compile("[\\\/]").split(mesh.meshFileName)[-1] 
    animName = re.compile("[\\\/]").split(mesh.animFileName)[-1]
    obj = {}
    # 模型名称
    obj["name"]         = meshName
    # 是否为骨骼模型
    obj["skeleton"]     = mesh.skeleton
    # 坐标点
    obj["transform"]    = Matrix3D(mesh.transform).rawData
    # 材质名称
    obj["textures"]     = {}
    if mesh.material:
        for texName in mesh.material.textures:
            obj["textures"][texName] = mesh.material.textures[texName]
            pass
        pass
    # 动画
    if config.anim:
        anim = {}
        obj["anim"] = anim
        anim["name"]        = animName
        anim["totalFrames"] = len(mesh.anims)
        pass

    return obj
    pass # end func

# 写场景配置
def writeSceneConfig(scene):
    obj = {}
    # 写相机
    obj["cameras"] = []
    obj["meshes"]  = []
    for i in range(len(scene.cameras)):
        fileName = scene.cameras[i].fileName
        fileName = re.compile("[\\\/]").split(fileName)[-1]
        obj["cameras"].append(fileName)
        pass
    # 写模型
    for i in range(len(scene.meshes)):
        obj["meshes"].append(getMeshConfig(scene.meshes[i]))
        pass
    data = json.dumps(obj, sort_keys=True, indent=4)
    data = str(data)
    
    tokens  = re.compile("[\\\/]").split(scene.fbxfile)
    fbxName = tokens[-1]
    fbxName = fbxName.split(".")[0:-1]
    fbxName = ".".join(fbxName)
    fbxDir  = parseFilepath(scene.fbxfile)
    fileName = fbxDir + fbxName + SCENE_TYPE
    
    open(fileName, 'w').write(data)
    
    pass

# 解析FBX文件
def parseFBX(fbxfile, config):
    logging.info("parse fbx file:%s" % (fbxfile))
    # 初始化SDKManager以及Scene
    sdkManager, scene = InitializeSdkObjects()
    # 加载FBX
    content = LoadScene(sdkManager, scene, fbxfile)
    # fbx文件装载失败
    if content == False:
        logging.info("Fbx load failed:%s" % fbxfile)
        sdkManager.Destroy()
        return
        pass
    # 对场景三角化
    converter = FbxGeometryConverter(sdkManager)
    converter.Triangulate(scene, True)
    axisSystem = FbxAxisSystem.OpenGL
    axisSystem.ConvertScene(scene)
    
    # 开始解析fbx
    scene3d = Scene3D()
    scene3d.fbxfile = fbxfile
    # 解析相机
    scene3d.cameras = parseCameras(sdkManager, scene, fbxfile)
    # 解析模型
    scene3d.meshes  = parseMeshes(sdkManager, scene, fbxfile)
    # 写场景配置
    writeSceneConfig(scene3d)
    
    pass # end func

if __name__ == "__main__":
    
    reload(sys)
    sys.setdefaultencoding('utf8')
    
    # log
    logging.basicConfig(
                        level    = logging.DEBUG,
                        format   = '%(asctime)s %(filename)s %(levelname)s %(message)s',
                        datefmt  = '%a, %d %b %Y %H:%M:%S',
                        filename = 'log.log',
                        filemode = 'w')
    console = logging.StreamHandler(sys.stdout)
    console.setLevel(logging.INFO)
    formatter = logging.Formatter('%(name)-12s: %(levelname)-8s %(message)s')
    console.setFormatter(formatter)
    logging.getLogger('').addHandler(console)
    # end
    
    # 解析参数
    config = parseArgument()
    fbxList = scanFbxFiles(config.path)
    
    for item in fbxList:
        parseFBX(item, config)
        pass
    
    logging.info("ʕ•̫͡•ʕ*̫͡*ʕ")

    pass
