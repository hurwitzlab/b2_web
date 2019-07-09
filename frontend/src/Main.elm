module Main exposing (Msg(..), main, update, view)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import HttpBuilder
import Json.Decode as Decode exposing (Decoder)
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
    , error : Maybe String
    , experiment : Maybe Experiment
    , experiments : List Experiment
    }


type alias Experiment =
    { sample_id : String
    , sample_type : String
    , run_name : String
    , experiment_type : String
    , level : String
    , operator : String
    , protocol_id : String
    , experiment_date_time : String
    }


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GetExperiment (Result Http.Error Experiment)
    | SearchSample String
    | GetExperiments
    | ListExperiments (Result Http.Error (List Experiment))


update msg model =
    case msg of
        GetExperiments ->
            ( model, getExperiments )

        ListExperiments result ->
            let
                _ =
                    Debug.log "EXPS = " result
            in
            case result of
                Ok exps ->
                    ( { model | experiments = exps }, Cmd.none )

                Err _ ->
                    ( { model | experiments = [] }, Cmd.none )

        GetExperiment result ->
            let
                _ =
                    Debug.log "got result" result
            in
            case result of
                Ok exp ->
                    ( { model | experiment = Just exp }, Cmd.none )

                Err err ->
                    let
                        err_msg =
                            case err of
                                Http.Timeout ->
                                    "Timeout"

                                Http.NetworkError ->
                                    "Network Error"

                                Http.BadUrl url ->
                                    "Bad URL: " ++ url

                                Http.BadStatus status ->
                                    "Bad URL: " ++ String.fromInt status

                                Http.BadBody s ->
                                    "Bad Response: " ++ s
                    in
                    ( { model
                        | experiment = Nothing
                        , error = Just err_msg
                      }
                    , Cmd.none
                    )

        SearchSample sample_id ->
            ( model, getExperiment sample_id )

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
      , error = Nothing
      , experiment = Nothing
      , experiments = []
      }
    , Cmd.none
    )



-- getExperiment : Int -> Http.Response Experiment


getExperiment sample_id =
    let
        url =
            "http://localhost:5000/experiment/" ++ sample_id

        _ =
            Debug.log "sample_id = " sample_id
    in
    HttpBuilder.get url
        |> HttpBuilder.withExpect
            (Http.expectJson GetExperiment decoderExperiment)
        |> HttpBuilder.request



-- getExperiments : Http.Request (List Experiment)


getExperiments =
    let
        url =
            "http://localhost:5000/experiments"
    in
    HttpBuilder.get url
        |> HttpBuilder.withExpect
            (Http.expectJson ListExperiments (Decode.list decoderExperiment))
        |> HttpBuilder.request


view : Model -> Browser.Document Msg
view model =
    { title = "B2"
    , body =
        [ div [] [ button [ onClick GetExperiments ] [ text "Get Exps" ] ]
        , div [] [ viewError model.error ]
        , div [] (viewExperiments model.experiments)

        -- , div [] [ input [ onInput SearchSample ] [] ]
        --, div [] [ viewExperiment model.experiment ]
        ]
    }


viewError error =
    case error of
        Just e ->
            text e

        Nothing ->
            text ""


viewExperiments exps =
    let
        numFound =
            List.length exps

        header =
            [ tr []
                [ th [] [ text "sample_id" ]
                , th [] [ text "operator" ]
                , th [] [ text "sample_type" ]
                , th [] [ text "exp_type" ]
                , th [] [ text "run_name" ]
                ]
            ]

        row exp =
            tr []
                [ td [] [ text exp.sample_id ]
                , td [] [ text exp.operator ]
                , td [] [ text exp.sample_type ]
                , td [] [ text exp.experiment_type ]
                , td [] [ text exp.run_name ]
                ]

        rows =
            List.map row exps

        tbl =
            if numFound == 0 then
                text "No results"

            else
                table [] (header ++ rows)
    in
    [ div [] [ text ("Found " ++ String.fromInt numFound) ]
    , div [] [ tbl ]
    ]


viewExperiment exp =
    case exp of
        Just e ->
            table []
                [ tr []
                    [ td []
                        [ text "Sample ID" ]
                    , td
                        []
                        [ text e.sample_id ]
                    ]
                ]

        Nothing ->
            text "Nothing to show"


viewLink : String -> Html msg
viewLink path =
    li [] [ a [ href path ] [ text path ] ]


decoderExperiment : Decoder Experiment
decoderExperiment =
    Decode.succeed Experiment
        |> optional "sample_id" Decode.string ""
        |> optional "sample_type" Decode.string ""
        |> optional "run_name" Decode.string ""
        |> optional "experiment_type" Decode.string ""
        |> optional "level" Decode.string ""
        |> optional "operator" Decode.string ""
        |> optional "protocol_id" Decode.string ""
        |> optional "experiment_date_time" Decode.string ""



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
