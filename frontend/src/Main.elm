module Main exposing (Msg(..), main, update, view)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import HttpBuilder
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline exposing (custom, optional, required)
import Json.Encode as Encode exposing (Value)
import Url


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    }


type alias Experiment =
    { sample_id : String
    , sample_type : String
    , run_name : String
    , experiment_type : String
    , level : String
    , experiment_date_time : String
    , operator : String
    , protocol_id : String
    }


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url


update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | url = url }
            , Cmd.none
            )


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( { key = key
      , url = url
      }
    , Cmd.none
    )



--getExperiments : Http.Request (List Experiment)


getExperiments =
    let
        url =
            "http://localhost:5000/experiments"
    in
    HttpBuilder.get url
        |> HttpBuilder.withExpect (Http.expectJson (Decode.list decoderExperiment))
        |> HttpBuilder.request


view : Model -> Browser.Document Msg
view model =
    { title = "B2"
    , body =
        [ text "The current URL is: "
        , b [] [ text (Url.toString model.url) ]
        , ul []
            [ viewLink "/home"
            , viewLink "/profile"
            , viewLink "/reviews/the-century-of-the-self"
            , viewLink "/reviews/public-opinion"
            , viewLink "/reviews/shah-of-shahs"
            ]
        ]
    }


viewLink : String -> Html msg
viewLink path =
    li [] [ a [ href path ] [ text path ] ]


decoderExperiment =
    Decode.succeed Experiment
        |> required "sample_id" Decode.string
        |> required "sample_type" Decode.string
        |> required "run_name" Decode.string
        |> required "experiment_type" Decode.string
        |> required "level" Decode.string
        |> required "experiment_date_time" Decode.string
        |> required "operator" Decode.string
        |> required "protocol_id" Decode.string



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
