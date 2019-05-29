module Main exposing (main)

import Browser
import Browser.Events
import Http

import Axis3d  exposing (Axis3d)
import Frame3d exposing (Frame3d)
import Point3d exposing (Point3d)

import Constants
import Mesh
import Types exposing (..)
import UpdateCamera as Update
-- import UpdateWorld as Update
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
            { modelFrame = Frame3d.atOrigin
            , eyePoint   =
                Point3d.fromCoordinates ( 0, 0, 15 )
            -- |> Point3d.rotateAround Axis3d.y (degrees 30)
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
