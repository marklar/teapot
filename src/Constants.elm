module Constants exposing (..)

import Math.Vector3 exposing (Vec3, vec3)

import Axis3d      exposing (Axis3d)
import Direction3d exposing (Direction3d)
import Frame3d     exposing (Frame3d)
import Vector3d    exposing (Vector3d)


-- This 'placementFrame' is used to move the model into 'world space'.
-- It does _not_ project it into 'clip space'.
initialFrame : Frame3d
initialFrame =
    Frame3d.atOrigin

        -- degrees -30 means:
        --    + viewer moves to right, OR
        --    + pot is rotated 'left' (clockwise, if looking from above)
        |> Frame3d.rotateAround Axis3d.z (degrees -30)

        -- degrees 70 means:
        --    + viewer moves up to look from above
        --    + pot is rotated 'down' (top comes toward us)
        |> Frame3d.rotateAround Axis3d.y (degrees 20)


lightDirection : Direction3d
lightDirection =
    -- towards lower left, away from viewer
    Vector3d.fromComponents
        ( -0.5     -- -0.5: towards left
        , -1.0     -- -1.0: downward
        , -0.5     -- -0.5: away from viewer
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
