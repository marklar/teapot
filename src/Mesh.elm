module Mesh exposing (meshDecoder)

import Point3d     exposing (Point3d)
import Direction3d exposing (Direction3d)

import Geometry.Interop.LinearAlgebra.Direction3d as Direction3d
import Geometry.Interop.LinearAlgebra.Point3d as Point3d

import Json.Decode as Decode exposing (Decoder)
import WebGL exposing (Mesh)

import Constants
import Types exposing (..)


-- | The triangle data arrives in 'local space'.
-- We define a different 'model space' for orienting it nicely,
-- then we create our Mesh Attributes in this 'model space'.
meshDecoder : Decoder (Mesh VertexAttributes)
meshDecoder =
    Decode.map3
        (\vertexFloats normalFloats faceInts ->
            let
                -- Gather vertices, then put them into our frame of reference.
                -- Order matters, as 'faces' references them by index in this list.
                vertices : List Point3d
                vertices =
                    accumulateVertices vertexFloats []
                        |> List.map (Point3d.placeIn Constants.modelFrame)

                -- Meaning: the direction that the triangle faces?
                -- Gather normals, the put them into our frame of reference.
                -- Order matters, so as to match up with 'vertices' list.
                normals : List Direction3d
                normals =
                    accumulateNormals normalFloats []
                        |> List.map (Direction3d.placeIn Constants.modelFrame)

                -- Indices of vertices, used to define triangles.
                faces : List Face
                faces =
                    accumulateFaces faceInts []

                attributes =
                    List.map2
                        (\vertex normal ->
                            { position = Point3d.toVec3 vertex
                            , normal = Direction3d.toVec3 normal
                            }
                        )
                        vertices
                        normals
            in
            -- Each 'face' is a triple of vertex indices, defining a triangle.
            WebGL.indexedTriangles attributes faces
        )
        (Decode.field "vertices" <| Decode.list Decode.float)
        (Decode.field "normals"  <| Decode.list Decode.float)
        (Decode.field "faces"    <| Decode.list Decode.int)


---------------------------

-- Each Int is the index of a vertex.
-- A triple of such vertex indices defines a triangle.
type alias Face = ( Int, Int, Int )


-- | Grab 3 at a time.
-- Create Point3d from each triple.
accumulateVertices : List Float -> List Point3d -> List Point3d
accumulateVertices coordinates acc =
    case coordinates of
        x :: y :: z :: rest ->
            accumulateVertices rest
                (Point3d.fromCoordinates ( x, y, z ) :: acc)

        _ ->
            List.reverse acc


-- | Grab 3 at a time.
-- Create Direction3d from each triple.
accumulateNormals : List Float -> List Direction3d -> List Direction3d
accumulateNormals components acc =
    case components of
        x :: y :: z :: rest ->
            accumulateNormals rest
                (Direction3d.unsafe ( x, y, z ) :: acc)

        _ ->
            List.reverse acc


-- | Apparently, we need to discard some of these numbers.
-- Grab 8 at a time, but from those use only the 2nd, 3rd, and 4th.
-- Each Int is the index of a vertex.
-- A triple of such vertex indices defines a triangle.
accumulateFaces : List Int -> List Face -> List Face
accumulateFaces indices acc =
    case indices of
        a_ :: b :: c :: d :: e_ :: f_ :: g_ :: h_ :: rest ->
            accumulateFaces rest (( b, c, d ) :: acc)

        _ ->
            List.reverse acc
