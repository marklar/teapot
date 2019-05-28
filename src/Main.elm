module Main exposing (main)

-- general
import Browser
import Browser.Events
import Html
import Http

-- geometry: 2d
import Point2d    exposing (Point2d)

-- geometry: 3d
import Direction3d   exposing (Direction3d)
import Frame3d       exposing (Frame3d)
import Point3d       exposing (Point3d)
import SketchPlane3d exposing (SketchPlane3d)

import Vector3d as Vector3d exposing (Vector3d)

import Geometry.Interop.LinearAlgebra.Direction3d as Direction3d
import Geometry.Interop.LinearAlgebra.Frame3d as Frame3d
import Geometry.Interop.LinearAlgebra.Point3d as Point3d

-- interactivity
import Html.Events.Extra.Mouse as Mouse

import Constants
import Mesh
import Render
import Types exposing (..)
import Update
import View


main : Program Flags Model Msg
main =
    Browser.element
        { init          = init
        , subscriptions = subscriptions
        , update        = Update.update
        , view          = View.view
        }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        model =
            { placementFrame = Constants.initialFrame
            , mbMesh = Nothing
            , mbDragPoint = Nothing
            , windowSize =
                  { width = flags.windowInnerWidth
                  , height = flags.windowInnerHeight
                  }
            }

        cmd =
            Http.get
                { url = "/static/teapot.json"
                , expect = Http.expectJson GotModel Mesh.meshDecoder
                }
    in
    ( model, cmd )


subscriptions : Model -> Sub Msg
subscriptions model =
    Browser.Events.onResize
        ( \w h -> WindowSize { width =  w, height = h } )
