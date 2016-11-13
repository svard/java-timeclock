module Statistics exposing (Msg, Model, initialModel, view, update, loadStats)

import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Json.Decode as Json exposing ((:=))
import Task
import Http
import Date
import Date.Extra


type Msg
    = NoOp
    | AddYears (List YearStats)


type alias Record =
    { time : Float
    , date : Float
    }


type alias YearStats =
    { year : Int
    , sum : Float
    , avg : Float
    , shortest : Record
    , longest : Record
    }


type alias Model =
    { years : List YearStats }


recordDecoder : Json.Decoder Record
recordDecoder =
    Json.object2 Record
        ("time" := Json.float)
        ("date" := Json.float)


statsDecoder : Json.Decoder (List YearStats)
statsDecoder =
    Json.list <|
        Json.object5 YearStats
            ("id" := Json.int)
            ("sum" := Json.float)
            ("avg" := Json.float)
            ("shortest" := recordDecoder)
            ("longest" := recordDecoder)


loadStats : Cmd Msg
loadStats =
    let
        url =
            "/api/statistics"

        request =
            Http.get statsDecoder url
    in
        Task.perform (\_ -> AddYears []) AddYears request


initialModel : Model
initialModel =
    { years = [] }


view : Model -> Html Msg
view model =
    div [ class "o-container o-container--xlarge" ]
        [ h1
            [ class "c-heading tc-underline" ]
            [ text "Timeclock"
            , span [ class "c-text--quiet tc-secondary-header" ] [ text "Ericsson" ]
            ]
        , h3
            [ class "c-heading tc-table-header" ]
            [ text "Statistics" ]
        , (tableView model)
        ]


tableView : Model -> Html Msg
tableView model =
    table
        [ class "c-table" ]
        [ thead
            [ class "c-table__head" ]
            [ tr
                [ class "c-table__row c-table__row--heading" ]
                [ th [ class "c-table__cell" ] [ text "Year" ]
                , th [ class "c-table__cell" ] [ text "Longest day" ]
                , th [ class "c-table__cell" ] [ text "Shortest day" ]
                , th [ class "c-table__cell" ] [ text "Avg" ]
                , th [ class "c-table__cell" ] [ text "Total" ]
                ]
            ]
        , tbody
            [ class "c-table__body" ]
            (List.map rowView model.years)
        ]


rowView : YearStats -> Html Msg
rowView { year, sum, avg, shortest, longest } =
    let
        toHours ts =
            toString <| timestampToHours ts
            
        toDate date =
            Date.Extra.toFormattedString "MMM ddd" <| Date.fromTime date
    in
        tr
            [ class "c-table__row" ]
            [ td [ class "c-table__cell" ] [ text <| toString year ]
            , td [ class "c-table__cell" ] [ text <| (toDate longest.date) ++ " " ++ (toHours longest.time) ++ "h" ]
            , td [ class "c-table__cell" ] [ text <| (toDate shortest.date) ++ " " ++ (toHours shortest.time) ++ "h" ]
            , td [ class "c-table__cell" ] [ text <| toHours avg ]
            , td [ class "c-table__cell" ] [ text <| toHours sum ]
            ]


timestampToHours : Float -> Float
timestampToHours ts =
    round' (((ts * 100) / 3600) / 100)


round' : Float -> Float
round' number =
    let
        numerator =
            (number * 100)
                |> round
                |> toFloat
    in
        numerator / 100


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        AddYears years ->
            { model | years = years } ! []