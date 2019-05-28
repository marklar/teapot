module Render exposing (entity)

-- camera
import Camera3d exposing (Camera3d)
import Viewpoint3d

import Geometry.Interop.LinearAlgebra.Direction3d as Direction3d
import Geometry.Interop.LinearAlgebra.Frame3d as Frame3d
import Geometry.Interop.LinearAlgebra.Point3d as Point3d

-- geometry
import Direction3d exposing (Direction3d)
import Frame3d     exposing (Frame3d)
import Point3d     exposing (Point3d)

import WebGL exposing (Mesh)

import Constants
import Types exposing (..)


entity : Mesh VertexAttributes -> Frame3d -> Size -> WebGL.Entity
entity mesh placementFrame windowSize =
    let
        camera_ =
            camera windowSize

        uniforms =
            {
            -- >> VERTEX shader <<

            -- model:
            --   Move original model into 'world space' (where camera lives).
            --   Confusingly, this gets modified over time, based on dragging.
            --   Instead, I'd expect the _camera_ to move, thus changing the viewMatrix.
              modelMatrix = Frame3d.toMat4 placementFrame

            -- view: transform world according to camera position+orientation.
            --   Currently, this changes only when the window is resized.
            , viewMatrix = Camera3d.viewMatrix camera_

            -- projection:
            --   transform from 'world space' to 'clip space'
            --   camera attributes will determine what's seen
            , projectionMatrix = Camera3d.projectionMatrix camera_


            -- >> FRAGMENT shader <<
            , lightDirection = Direction3d.toVec3 Constants.lightDirection
            , faceColor = Constants.faceColor
            }
    in
    WebGL.entity vertexShader fragmentShader mesh uniforms


-----------------

-- | Uses 'world space' frame.
-- Currently, this camera doesn't move?
--
-- focalPoint always fixed at origin.
camera : Size -> Camera3d
camera { width, height } =
    Camera3d.perspective
        { viewpoint =
            Viewpoint3d.lookAt
                { eyePoint = Point3d.fromCoordinates ( 15, 0, 0 )
                , focalPoint = Point3d.origin
                , upDirection = Direction3d.z
                }
        , verticalFieldOfView = degrees 30
        , screenWidth  = toFloat width
        , screenHeight = toFloat height
        , nearClipDistance = 0.1
        , farClipDistance = 100
        }


vertexShader : WebGL.Shader VertexAttributes Uniforms Varyings
vertexShader =
    [glsl|
        // vertex attributes
        attribute vec3 position;
        attribute vec3 normal;

        // positional matrices
        uniform mat4 modelMatrix;
        uniform mat4 viewMatrix;
        uniform mat4 projectionMatrix;

        // to be passed to fragment shader
        // varying vec3 interpolatedPosition;
        varying vec3 interpolatedNormal;

        void main () {
            vec4 newModelPos    = modelMatrix * vec4(position, 1.0);
            vec4 newModelNormal = modelMatrix * vec4(normal, 0.0);

            gl_Position = projectionMatrix * viewMatrix * newModelPos;

            // set varyings
            // interpolatedPosition = newModelPos.xyz;
            interpolatedNormal   = newModelNormal.xyz;
        }
    |]


fragmentShader : WebGL.Shader {} Uniforms Varyings
fragmentShader =
    [glsl|
        precision mediump float;

        // constants
        uniform vec3 lightDirection;
        uniform vec3 faceColor;

        // from vertex shader, computed from vertix attributes
        // varying vec3 interpolatedPosition;
        varying vec3 interpolatedNormal;

        float clampNormal (float v) {
            return clamp(v, 0.0, 1.0);
        }

        // based on facet_s normal and the lightDirection.
        float getIntensity () {
            vec3 normal = normalize(interpolatedNormal);
            float dotProduct = dot(-normal, lightDirection);
            float base = 0.4;
            float factor = 0.6;
            return base + factor * clampNormal(dotProduct);
        }

        void main () {
           float intensity = getIntensity();
           gl_FragColor = vec4(faceColor * intensity, 1.0);
        }
    |]
