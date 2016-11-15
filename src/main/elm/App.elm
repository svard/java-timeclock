module App exposing (..)

import Html
import Navigation
import UrlParser exposing (Parser, map, oneOf, s, parseHash)
import Timeclock
import Statistics


type Msg
    = NoOp
    | MainPage Timeclock.Msg
    | StatisticsPage Statistics.Msg
    | ChangeRoute Navigation.Location


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
        [ map MainRoute (s "main")
        , map StatisticsRoute (s "statistics")
        ]


parser : Navigation.Location -> Route
parser location =
    case parseHash matchers location of
        Just route ->
            route

        Nothing ->
            NotFoundRoute


init : Navigation.Location -> ( Model, Cmd Msg )
init _ =
    let 
        ( mModel, mCmd ) = Timeclock.initialModel
    in
        { route = MainRoute
        , timeclock = mModel
        , statistics = Statistics.initialModel
        }
            ! [ Navigation.newUrl "#main", Cmd.map MainPage mCmd ]


view : Model -> Html.Html Msg
view model =
    case model.route of
        MainRoute ->
            Html.map MainPage (Timeclock.view model.timeclock)

        StatisticsRoute ->
            Html.map StatisticsPage (Statistics.view model.statistics)

        NotFoundRoute ->
            Html.map MainPage (Timeclock.view model.timeclock)


routeToCmd : Route -> Cmd Msg
routeToCmd route =
    case route of
        MainRoute ->
            Cmd.map MainPage Timeclock.initDate

        StatisticsRoute ->
            Cmd.map StatisticsPage Statistics.loadStats

        NotFoundRoute ->
            Cmd.none


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

        ChangeRoute location ->
            let
                route =
                    parser location
            in
                { model | route = route } ! [ routeToCmd route ]


main : Program Never Model Msg
main =
    Navigation.program ChangeRoute
        { init = init
        , update = update
        , view = view
        , subscriptions = (\_ -> Sub.none)
        }
