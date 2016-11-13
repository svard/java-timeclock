module Timeclock exposing (Msg, Model, initialModel, initDate, view, update)

import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import Dom
import List
import Date
import Date.Extra
import Task
import Http
import Json.Decode exposing ((:=))
import Json.Encode


type alias ID =
    String


type alias Timestamp =
    Int


type alias Report =
    { id : ID
    , arrival : Timestamp
    , leave : Timestamp
    , lunch : Int
    , total : Int
    , editing : ( Bool, Bool )
    , update : String
    }



-- MODEL


type alias Model =
    { selectedDate : Date.Date
    , reports : List Report
    }



-- MESSAGES


type Msg
    = NoOp
    | SetDate Date.Date
    | IncrementWeek
    | DecrementWeek
    | AddRows (List Report)
    | EditTime ID ( Bool, Bool )
    | UpdateTime ID String
    | Save ID ( Bool, Bool )


initialModel : Model
initialModel =
    { selectedDate = Date.fromTime 0
    , reports = []
    }



-- VIEW


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
            [ text <| "Week " ++ (weekYear model.selectedDate) ]
        , tableView model
        , navButtonView
        ]


tableView : Model -> Html Msg
tableView model =
    table
        [ class "c-table" ]
        [ thead
            [ class "c-table__head" ]
            [ tr
                [ class "c-table__row c-table__row--heading" ]
                [ th [ class "c-table__cell tc-color-band" ] []
                , th [ class "c-table__cell" ] [ text "Date" ]
                , th [ class "c-table__cell" ] [ text "From" ]
                , th [ class "c-table__cell" ] [ text "To" ]
                , th [ class "c-table__cell" ] [ text "Lunch" ]
                , th [ class "c-table__cell" ] [ text "Total" ]
                , th [ class "c-table__cell" ] [ text "50%" ]
                , th [ class "c-table__cell" ] [ text "Diff" ]
                ]
            ]
        , tbody
            [ class "c-table__body" ]
            (List.append (List.map rowView model.reports) [ sumRowView model ])
        ]


rowView : Report -> Html Msg
rowView { id, arrival, leave, lunch, total, editing, update } =
    let
        totalHours =
            timestampToHours total

        lunchHours =
            timestampToHours lunch

        date =
            formatDate arrival

        from =
            formatTime arrival

        to =
            formatTime leave

        diff =
            round' (totalHours - workDay)

        halfDay =
            ceil (totalHours / 2)

        ( editFrom, editTo ) =
            editing

        editable time isEditing =
            if isEditing then
                input
                    [ Attr.id ("tc-" ++ id)
                    , classList
                        [ ( "c-field", True )
                        , ( "c-field--small", True )
                        , ( "c-field--error", not <| isValidDateTime date update )
                        ]
                    , value update
                    , autofocus True
                    , onBlur (EditTime id ( False, False ))
                    , onInput (UpdateTime id)
                    , onEnter (Save id editing)
                    ]
                    []
            else
                text <| time
    in
        tr
            [ class "c-table__row" ]
            [ td
                [ classList
                    [ ( "c-table__cell", True )
                    , ( "tc-color-band", True )
                    , ( "c-badge--success", totalHours >= workDay )
                    , ( "c-badge--error", totalHours < workDay )
                    ]
                ]
                []
            , td [ class "c-table__cell" ] [ text date ]
            , td
                [ class "c-table__cell"
                , onDoubleClick (EditTime id ( True, False ))
                ]
                [ editable from editFrom ]
            , td
                [ class "c-table__cell"
                , onDoubleClick (EditTime id ( False, True ))
                ]
                [ editable to editTo ]
            , td [ class "c-table__cell" ] [ text <| toString lunchHours ]
            , td [ class "c-table__cell" ] [ text <| toString totalHours ]
            , td [ class "c-table__cell" ] [ text <| toString halfDay ]
            , td [ class "c-table__cell" ] [ text <| prefixSign diff ]
            ]


sumRowView : Model -> Html Msg
sumRowView model =
    let
        totalWorkHours =
            List.map (\x -> x.total) model.reports
                |> List.sum
                |> timestampToHours

        targetHours =
            List.length model.reports
                |> toFloat
                |> (*) workDay

        diff =
            round' (totalWorkHours - targetHours)
    in
        tr
            [ class "c-table__row tc-sum-row" ]
            [ td [ class "c-table__cell tc-color-band" ] []
            , td [ class "c-table__cell" ] [ text "" ]
            , td [ class "c-table__cell" ] [ text "" ]
            , td [ class "c-table__cell" ] [ text "" ]
            , td [ class "c-table__cell" ] [ text "" ]
            , td [ class "c-table__cell" ] [ text <| toString totalWorkHours ]
            , td [ class "c-table__cell" ] [ text "" ]
            , td [ class "c-table__cell" ] [ text <| prefixSign diff ]
            ]


navButtonView : Html Msg
navButtonView =
    div
        [ class "tc-nav-buttons" ]
        [ button
            [ class "c-button c-button--rounded c-button--ghost-primary c-button--small u-high"
            , onClick DecrementWeek
            ]
            [ i [ class "fa fa-chevron-left tc-button-icon" ] [] ]
        , button
            [ class "c-button c-button--rounded c-button--ghost-primary c-button--small u-high"
            , onClick IncrementWeek
            ]
            [ i [ class "fa fa-chevron-right tc-button-icon" ] [] ]
        ]


onEnter : Msg -> Attribute Msg
onEnter msg =
    let
        tagger code =
            if code == 13 then
                msg
            else
                NoOp
    in
        on "keydown" (Json.Decode.map tagger keyCode)


incrWeek : Date.Date -> Date.Date
incrWeek date =
    Date.Extra.add Date.Extra.Week 1 date


decrWeek : Date.Date -> Date.Date
decrWeek date =
    Date.Extra.add Date.Extra.Week -1 date


weekYear : Date.Date -> String
weekYear date =
    Date.Extra.toFormattedString "w yyyy" date


formatDate : Timestamp -> String
formatDate timestamp =
    Date.Extra.toFormattedString "yyyy-MM-dd" <| Date.fromTime <| toFloat timestamp


formatTime : Timestamp -> String
formatTime timestamp =
    Date.Extra.toFormattedString "HH:mm:ss" <| Date.fromTime <| toFloat timestamp


timestampToHours : Timestamp -> Float
timestampToHours ts =
    (toFloat ((ts * 100) // 3600)) / 100


ceil : Float -> Float
ceil number =
    let
        numerator =
            (number * 100)
                |> ceiling
                |> toFloat
    in
        numerator / 100


round' : Float -> Float
round' number =
    let
        numerator =
            (number * 100)
                |> round
                |> toFloat
    in
        numerator / 100


workDay : Float
workDay =
    7.75


prefixSign : Float -> String
prefixSign value =
    if value >= 0 then
        "+" ++ (toString value)
    else
        toString value


isValidDateTime : String -> String -> Bool
isValidDateTime date time =
    case Date.fromString (date ++ " " ++ time) of
        Ok _ ->
            True

        Err _ ->
            False



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        SetDate date ->
            { model | selectedDate = date } ! [ weekReports date ]

        IncrementWeek ->
            let
                newWeek =
                    incrWeek model.selectedDate
            in
                { model | selectedDate = newWeek } ! [ weekReports newWeek ]

        DecrementWeek ->
            let
                newWeek =
                    decrWeek model.selectedDate
            in
                { model | selectedDate = newWeek } ! [ weekReports newWeek ]

        AddRows reports ->
            { model | reports = reports } ! []

        EditTime id isEditing ->
            let
                updateReport t =
                    if t.id == id then
                        case isEditing of
                            ( True, False ) ->
                                { t | editing = isEditing, update = formatTime t.arrival }

                            ( False, True ) ->
                                { t | editing = isEditing, update = formatTime t.leave }

                            _ ->
                                { t | editing = isEditing }
                    else
                        t

                focus =
                    Dom.focus <| "tc-" ++ id
            in
                { model | reports = List.map updateReport model.reports } ! [ Task.perform (\_ -> NoOp) (\_ -> NoOp) focus ]

        UpdateTime id time ->
            let
                updateReport t =
                    if t.id == id then
                        { t | update = time }
                    else
                        t
            in
                { model | reports = List.map updateReport model.reports } ! []

        Save id isEditing ->
            let
                toTimestamp date time =
                    case Date.fromString (date ++ " " ++ time) of
                        Ok timestamp ->
                            round (Date.toTime timestamp)

                        Err _ ->
                            0

                updateReport t =
                    if t.id == id then
                        case isEditing of
                            ( True, False ) ->
                                let
                                    arrival =
                                        toTimestamp (formatDate t.arrival) t.update
                                in
                                    { t | arrival = arrival, total = (t.leave - arrival - (t.lunch * 1000)) // 1000, editing = ( False, False ) }

                            ( False, True ) ->
                                let
                                    leave =
                                        toTimestamp (formatDate t.leave) t.update
                                in
                                    { t | leave = leave, total = (leave - t.arrival - (t.lunch * 1000)) // 1000, editing = ( False, False ) }

                            _ ->
                                t
                    else
                        t

                updatedReports =
                    List.map updateReport model.reports

                findReport =
                    List.filter (\r -> r.id == id) updatedReports
                        |> List.head

                command =
                    case findReport of
                        Just r ->
                            [ putReport r ]

                        Nothing ->
                            []
            in
                { model | reports = updatedReports } ! command


reportsDecoder : Json.Decode.Decoder (List Report)
reportsDecoder =
    Json.Decode.list <|
        Json.Decode.object7 Report
            ("id" := Json.Decode.string)
            ("arrival" := Json.Decode.int)
            ("leave" := Json.Decode.int)
            ("lunch" := Json.Decode.int)
            ("total" := Json.Decode.int)
            (Json.Decode.succeed ( False, False ))
            (Json.Decode.succeed "")


reportEncoder : Report -> String
reportEncoder { id, arrival, leave, lunch, total } =
    let
        toUtc timestamp =
            Date.Extra.toUtcIsoString <| Date.fromTime <| toFloat timestamp

        report =
            Json.Encode.object
                [ ( "id", Json.Encode.string id )
                , ( "arrival", Json.Encode.string <| toUtc arrival )
                , ( "leave", Json.Encode.string <| toUtc leave )
                , ( "lunch", Json.Encode.int lunch )
                , ( "total", Json.Encode.int total )
                ]
    in
        Json.Encode.encode 4 report


initDate : Cmd Msg
initDate =
    Task.perform (\_ -> SetDate (Date.fromTime 0)) SetDate Date.now


weekReports : Date.Date -> Cmd Msg
weekReports date =
    let
        week =
            toString <| Date.Extra.weekNumber date

        year =
            toString <| Date.year date

        url =
            "/api/timereport?year=" ++ year ++ "&week=" ++ week

        request =
            Http.get reportsDecoder url
    in
        Task.perform (\_ -> AddRows []) AddRows request


putReport : Report -> Cmd Msg
putReport report =
    let
        body =
            reportEncoder report

        request =
            Http.send Http.defaultSettings
                { verb = "PUT"
                , headers = [ ( "Content-Type", "application/json" ) ]
                , url = "/api/timereport/" ++ report.id
                , body = Http.string body
                }
    in
        Task.perform (\_ -> NoOp) (\_ -> NoOp) request
