module View exposing (view)

-- html
import Html exposing (Attribute, Html)
import Html.Attributes as Attributes
import Html.Events as Events

-- geometry: 2d
import Point2d    exposing (Point2d)

-- interactivity
import Html.Events.Extra.Mouse as Mouse
import Html.Events.Extra.Touch as Touch
{-
import SingleTouch
-}

-- rendering
import Math.Matrix4 exposing (Mat4)
import Math.Vector3 exposing (Vec3, vec3)
import WebGL exposing (Mesh)

import Render
import Types exposing (..)


view : Model -> Html Msg
view model =
    case model.mbMesh of
        Just mesh ->
            let
                webGLOptions =
                    [ WebGL.clearColor 0 0 0 1
                    , WebGL.depth 1
                    , WebGL.antialias
                    ]

                entities =
                    [ Render.entity mesh model.modelFrame model.eyePoint model.windowSize ]
            in
            WebGL.toHtmlWith webGLOptions (htmlAttributes model) entities

        Nothing ->
            Html.text "Loading model..."


------------------------

htmlAttributes : Model -> List (Attribute Msg)
htmlAttributes model =
    let
        blockAttribute =
            Attributes.style "display" "block"

        widthAttribute =
            Attributes.width model.windowSize.width

        heightAttribute =
            Attributes.height model.windowSize.height
    in
    blockAttribute :: widthAttribute :: heightAttribute :: dragAttributes



dragAttributes : List (Attribute Msg)
-- dragAttributes = []
dragAttributes =
    [ Mouse.onDown (StartRotatingAt << Point2d.fromCoordinates << .offsetPos)
    -- do this only when there's a dragPt?
    , Mouse.onMove (PointerMovedTo << Point2d.fromCoordinates << .offsetPos)
    , Mouse.onUp (always StopRotating)

    -- Untested...
    , Touch.onStart (StartRotatingAt << Point2d.fromCoordinates << touchCoordinates)
    , Touch.onMove (PointerMovedTo << Point2d.fromCoordinates << touchCoordinates)
    , Touch.onEnd (always StopRotating)
    , Touch.onCancel (always StopRotating)
    ]


touchCoordinates : Touch.Event -> ( Float, Float )
touchCoordinates touchEvent =
    List.head touchEvent.changedTouches
        |> Maybe.map .clientPos
        |> Maybe.withDefault ( 0, 0 )
