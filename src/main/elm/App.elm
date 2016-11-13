module App exposing (..)

import Html exposing (Html)
import Html.App
import Navigation
import UrlParser exposing (Parser, format, oneOf, s, parse)
import String
import Timeclock
import Statistics


type Msg
    = NoOp
    | MainPage Timeclock.Msg
    | StatisticsPage Statistics.Msg


type Route
    = MainRoute
    | StatisticsRoute
    | NotFoundRoute


type alias Model =
    { route : Route
    , timeclock : Timeclock.Model
    , statistics : Statistics.Model
    }


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ format MainRoute (s "main")
        , format StatisticsRoute (s "statistics")
        ]


hashParser : Navigation.Location -> Result String Route
hashParser location =
    location.hash
        |> String.dropLeft 1
        |> parse identity matchers


parser : Navigation.Parser (Result String Route)
parser =
    Navigation.makeParser hashParser


init : Result String Route -> ( Model, Cmd Msg )
init _ =
    { route = MainRoute
    , timeclock = Timeclock.initialModel
    , statistics = Statistics.initialModel
    }
        ! [ Navigation.newUrl "#main" ]


view : Model -> Html Msg
view model =
    case model.route of
        MainRoute ->
            Html.App.map MainPage (Timeclock.view model.timeclock)

        StatisticsRoute ->
            Html.App.map StatisticsPage (Statistics.view model.statistics)

        NotFoundRoute ->
            Html.App.map MainPage (Timeclock.view model.timeclock)


routeToCmd : Route -> Cmd Msg
routeToCmd route =
    case route of
        MainRoute ->
            Cmd.map MainPage Timeclock.initDate

        StatisticsRoute ->
            Cmd.map StatisticsPage Statistics.loadStats

        NotFoundRoute ->
            Cmd.none


urlUpdate : Result String Route -> Model -> ( Model, Cmd Msg )
urlUpdate result model =
    case result of
        Err _ ->
            { model | route = NotFoundRoute } ! []

        Ok route ->
            { model | route = route } ! [ routeToCmd route ]


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        MainPage msg ->
            let
                ( tModel, cmd ) =
                    Timeclock.update msg model.timeclock
            in
                { model | timeclock = tModel } ! [ Cmd.map MainPage cmd ]

        StatisticsPage msg ->
            let
                ( sModel, cmd ) =
                    Statistics.update msg model.statistics
            in
                { model | statistics = sModel } ! [ Cmd.map StatisticsPage cmd ]

        NoOp ->
            model ! []


main : Program Never
main =
    Navigation.program parser
        { init = init
        , update = update
        , urlUpdate = urlUpdate
        , view = view
        , subscriptions = (\_ -> Sub.none)
        }
