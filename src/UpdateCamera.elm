module UpdateCamera exposing (update)

-- geometry: 2d (for mouse)
import Axis2d        exposing (Axis2d)
import Direction2d   exposing (Direction2d)
import LineSegment2d exposing (LineSegment2d)
import Point2d       exposing (Point2d)
import Vector2d      exposing (Vector2d)

-- geometry: 3d
import Axis3d        exposing (Axis3d)
import Direction3d   exposing (Direction3d)
import Frame3d       exposing (Frame3d)
import LineSegment3d exposing (LineSegment3d)
import Point3d       exposing (Point3d)
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
                    -- Move camera (eyePoint) based on mouse displacement.
                    let
                        mouseDisplacement =
                            Vector2d.from lastPoint newPoint
                    in
                    { model
                        -- | modelFrame = rotate model.modelFrame mouseDisplacement
                        | eyePoint = mvEyePoint model.eyePoint mouseDisplacement
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


mvEyePoint : Point3d -> Vector2d -> Point3d
mvEyePoint eyePoint displacement =
    let
        ( dx, dy ) =
            Vector2d.components displacement

        newHorizPoint =
            Point3d.rotateAround Axis3d.y (-dx / 150) eyePoint

        newVertPoint =
            getVertPoint newHorizPoint dy

        horizDistance =
            LineSegment3d.fromEndpoints ( newVertPoint, Point3d.origin )
                |> LineSegment3d.projectInto SketchPlane3d.xz
                |> LineSegment2d.length

        horizPtDir =
            getHorizDir newHorizPoint

        vertPtDir =
            getHorizDir newVertPoint
    in
    -- if (horizPtDir == vertPtDir) && (getHorizDistance newVertPoint >= 1.0) then
    if getHorizDistance newVertPoint >= 1.0 then
        newVertPoint
    else
        newHorizPoint


getHorizDir : Point3d -> Maybe Direction2d
getHorizDir pt =
    let
        mbDir =
            Direction3d.from pt Point3d.origin
    in
    case mbDir of
        Nothing ->
            Nothing

        Just dir ->
            Direction3d.projectInto SketchPlane3d.xz dir
    
            

getVertPoint : Point3d -> Float -> Point3d
getVertPoint horizPoint dy =
    let
        mbElevRotAxis : Maybe Axis3d
        mbElevRotAxis =
            getElevationRotationAxis horizPoint
    in
    case mbElevRotAxis of
        Nothing ->
            horizPoint

        Just elevRotAxis ->
            horizPoint
                |> Point3d.rotateAround elevRotAxis (-dy / 500)
                  

getHorizDistance : Point3d -> Float
getHorizDistance pt =
    LineSegment3d.fromEndpoints ( pt, Point3d.origin )
        |> LineSegment3d.projectInto SketchPlane3d.xz
        |> LineSegment2d.length


getElevationRotationAxis : Point3d -> Maybe Axis3d
getElevationRotationAxis newHorizPoint =
    let
        currentDir =
            Direction3d.from newHorizPoint Point3d.origin
                |> Maybe.withDefault Direction3d.positiveX

        mbHorizDir : Maybe Direction2d
        mbHorizDir =
            currentDir
                |> Direction3d.projectInto SketchPlane3d.xz
    in
    case mbHorizDir of
        Nothing ->
            Nothing

        -- There's gotta be a simpler way than this...
        Just horizDir ->
            horizDir
                |> Direction2d.perpendicularTo               -- : Direction2d
                |> Axis2d.through Point2d.origin             -- : Axis2d
                |> Axis3d.on SketchPlane3d.xz
                |> Just
