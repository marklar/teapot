module Types exposing (..)

import Http

-- webgl
import Math.Matrix4 exposing (Mat4)
import Math.Vector3 exposing (Vec3)
import WebGL exposing (Mesh)

-- geometry
import Point2d exposing (Point2d)
import Point3d exposing (Point3d)
import Frame3d exposing (Frame3d)


type Msg
    = StartRotatingAt Point2d
    | PointerMovedTo Point2d
    | StopRotating
    | WindowSize Size
    | GotModel (Result Http.Error (Mesh VertexAttributes))


type alias Flags =
    { windowInnerWidth  : Int
    , windowInnerHeight : Int
    }

type alias Model =
    { modelFrame  : Frame3d
    -- ^ Puts the mesh into 'world space'.
    , eyePoint    : Point3d
    -- ^ Where the camera is (in 'world space').
    , mbMesh      : Maybe (Mesh VertexAttributes)
    -- ^ Our triangles.
    , windowSize  : Size
    -- ^ Used to modify our camera (and thus our view matrix).
    , mbDragPoint : Maybe Point2d
    -- ^ Used to modify the camera.
    }

type alias Size =
    { width  : Int
    , height : Int
    }

type alias VertexAttributes =
    { position : Vec3
    , normal   : Vec3
    }


type alias Uniforms =
    { modelMatrix      : Mat4
    , viewMatrix       : Mat4
    , projectionMatrix : Mat4
    , lightDirection   : Vec3
    , faceColor        : Vec3
    }


type alias Varyings =
    { interpolatedNormal   : Vec3
    -- , interpolatedPosition : Vec3
    }
