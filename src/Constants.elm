module Constants exposing (..)

import Math.Vector3 exposing (Vec3, vec3)

import Axis3d      exposing (Axis3d)
import Direction3d exposing (Direction3d)
import Frame3d     exposing (Frame3d)
import Vector3d    exposing (Vector3d)


-- We rotate and translate the Frame3d, because
-- the teapot data comes to us oriented very strangely.
--
--   x: to right
--   y: up
--   z: at us
--
-- Spaces:     Object   ->   World   ->   Eye   ->   Clip
-- Matrices:          model         view     projection
--
modelFrame : Frame3d
modelFrame =
    Frame3d.atOrigin
        -- Move it down a bit.
        |> Frame3d.translateBy
            (Vector3d.fromComponents ( 0, -1, 0 ))
        -- Turn spout to left.
        -- |> Frame3d.rotateAround Axis3d.y (degrees -45)


-- Used in the fragment shader.
lightDirection : Direction3d
lightDirection =
    -- Towards lower left, away from viewer
    --
    -- The light has a fixed position in the world.
    -- If the object moves, the light hits different parts of it.
    -- If the camera moves (as opposed to the object), then the light
    -- hits the same part of the object while the camera moves
    -- relative to it.
    Vector3d.fromComponents
        ( -1.0     -- -0.5: leftwards
        , -1.0     -- -1.0: downwards
        , -0.5     -- -0.5: away from screen
        )
        |> Vector3d.direction
        |> Maybe.withDefault Direction3d.negativeZ


faceColor : Vec3
faceColor =
    let
        red   = 0.0
        green = 0.6
        blue  = 1.0
    in
    vec3 red green blue
