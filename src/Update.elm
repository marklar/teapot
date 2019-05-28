module Update exposing (update)

-- geometry: 2d (for mouse)
import Direction2d exposing (Direction2d)
import Vector2d    exposing (Vector2d)

-- geometry: 3d
import Axis3d        exposing (Axis3d)
import Direction3d   exposing (Direction3d)
import Point3d       exposing (Point3d)
import Frame3d       exposing (Frame3d)
import SketchPlane3d exposing (SketchPlane3d)

import Types exposing (..)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( updateModel msg model, Cmd.none )

-------------------

updateModel : Msg -> Model -> Model
updateModel message model =
    case message of
        StartRotatingAt startPoint ->
            { model | mbDragPoint = Just startPoint }

        StopRotating ->
            { model | mbDragPoint = Nothing }

        PointerMovedTo newPoint ->
            case model.mbDragPoint of
                Just lastPoint ->
                    -- Rotate Frame3d based on distance moved.
                    let
                        mouseDisplacement =
                            Vector2d.from lastPoint newPoint
                    in
                    { model
                        | placementFrame = rotate model.placementFrame mouseDisplacement
                        , mbDragPoint = Just newPoint
                    }

                Nothing ->
                    model

        WindowSize windowSize ->
            { model | windowSize = windowSize }

        GotModel result ->
            let
                newMesh =
                    case result of
                        Ok mesh ->
                            Just mesh

                        Err _ ->
                            Nothing
            in
            { model | mbMesh = newMesh }


-- | Rotate Frame3d based on mouse-drag displacement.
-- (Reverse order of args?)
rotate : Frame3d -> Vector2d -> Frame3d
rotate frame displacement =
    let
        dragVector =
            getDragVector displacement
    in
    case Vector2d.direction dragVector of
        Just dragDir ->
            let
                rotationAngle =
                    degrees 1 * Vector2d.length dragVector
            in
            frame |> Frame3d.rotateAround (getRotationAxis dragDir) rotationAngle

        Nothing ->
            frame


getDragVector : Vector2d -> Vector2d
getDragVector displacement =
    let
        ( dx, dy ) =
            Vector2d.components displacement
    in
    -- Reverse dy direction.
    Vector2d.fromComponents ( dx, -dy )


getRotationAxis : Direction2d -> Axis3d
getRotationAxis dragDir =
    let
        axialDir =
            Direction3d.on SketchPlane3d.yz <|
                Direction2d.perpendicularTo dragDir
    in
    Axis3d.through Point3d.origin axialDir

