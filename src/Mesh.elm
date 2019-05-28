module Mesh exposing (meshDecoder)

import Axis3d      exposing (Axis3d)
import Frame3d     exposing (Frame3d)
import Point3d     exposing (Point3d)
import Vector3d    exposing (Vector3d)
import Direction3d exposing (Direction3d)

import Geometry.Interop.LinearAlgebra.Direction3d as Direction3d
import Geometry.Interop.LinearAlgebra.Point3d as Point3d

import Json.Decode as Decode exposing (Decoder)
import WebGL exposing (Mesh)

import Types exposing (..)


-- | The triangle data arrives in 'local space'.
-- We define our 'world space' frame of reference, then create
-- our Mesh Attributes in 'world space'.
meshDecoder : Decoder (Mesh VertexAttributes)
meshDecoder =
    Decode.map3
        (\vertexFloats normalFloats faceInts ->
            let
                -- We rotate and translate the Frame3d. Why?
                -- (Perhaps our teapot data is oriented strangely?)
                frame =
                    Frame3d.atOrigin
                        |> Frame3d.rotateAround Axis3d.x (degrees 90)
                        |> Frame3d.translateBy
                            (Vector3d.fromComponents ( 0, 0, -1 ))

                -- Gather vertices, then create corresponding ones in our new frame.
                -- The _order_ matters, as 'faces' references them by index in this list.
                vertices : List Point3d
                vertices =
                    accumulateVertices vertexFloats []
                        |> List.map (Point3d.placeIn frame)

                -- Meaning: the direction that the triangle faces???
                -- Gather normals, then create corresponding ones in our new frame.
                -- Order matters, so as to match up with 'vertices' list.
                normals : List Direction3d
                normals =
                    accumulateNormals normalFloats []
                        |> List.map (Direction3d.placeIn frame)

                -- Are these the indices of vertices?
                faces : List (Int, Int, Int)
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


-- | Grab 3 at a time.
-- Create Point3d from each triple.
accumulateVertices : List Float -> List Point3d -> List Point3d
accumulateVertices coordinates accumulated =
    case coordinates of
        x :: y :: z :: rest ->
            accumulateVertices rest
                (Point3d.fromCoordinates ( x, y, z ) :: accumulated)

        _ ->
            List.reverse accumulated


-- | Grab 3 at a time.
-- Create Direction3d from each triple.
accumulateNormals : List Float -> List Direction3d -> List Direction3d
accumulateNormals components accumulated =
    case components of
        x :: y :: z :: rest ->
            accumulateNormals rest
                (Direction3d.unsafe ( x, y, z ) :: accumulated)

        _ ->
            List.reverse accumulated


-- | Apparently, we need to discard some of these numbers.
-- Grab 8 at a time, but use only the 2nd, 3rd, and 4th.
-- Each Int is the index of one of the vertices.
-- A triple of such vertex indices defines a triangle.
accumulateFaces : List Int -> List ( Int, Int, Int ) -> List ( Int, Int, Int )
accumulateFaces indices accumulated =
    case indices of
        a :: b :: c :: d :: e :: f :: g :: h :: rest ->
            accumulateFaces rest (( b, c, d ) :: accumulated)

        _ ->
            List.reverse accumulated
