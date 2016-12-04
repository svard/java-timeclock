module Timeclock exposing (Msg, Model, initialModel, initDate, view, update)

import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import Dom
import List
import Date exposing (Date)
import Date.Extra
import Task
import Http
import Json.Decode exposing (field)
import Json.Encode
import Widgets.Calendar as Calendar


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
    , editing : Maybe EditingCell
    , update : String
    }


type EditingCell 
    = Arrive
    | Leave
    | Lunch


-- MODEL


type alias Model =
    { selectedDate : Date
    , reports : List Report
    , calendar : Calendar.Model
    , modalVisible : Bool
    }



-- MESSAGES


type Msg
    = NoOp
    | SetDate Date
    | IncrementWeek
    | DecrementWeek
    | AddRows (Result Http.Error (List Report))
    | EditTime ID (Maybe EditingCell)
    | UpdateTime ID String
    | Save ID EditingCell
    | PutReport (Result Http.Error ())
    | Focus (Result Dom.Error ())
    | Calendar Calendar.Msg
    | ToggleModal


initialModel : ( Model, Cmd Msg )
initialModel =
    let
        ( cModel, cCmd ) =
            Calendar.initialModel
    in
        { selectedDate = Date.fromTime 0
        , reports = []
        , calendar = cModel
        , modalVisible = False
        }
            ! [ Cmd.map Calendar cCmd ]



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
        , calendarModal model
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
            round_ (totalHours - workDay)

        halfDay =
            ceil (totalHours / 2)

        editable : String -> Bool -> EditingCell -> Html Msg
        editable time isEditing field =
            let 
                validInput =
                    case field of
                        Lunch ->
                            not (isValidFloat update)
                            
                        _ ->
                            not (isValidDateTime date update)
            in
                if isEditing then
                    input
                        [ Attr.id ("tc-" ++ id)
                        , classList
                            [ ( "c-field", True )
                            , ( "c-field--small", True )
                            , ( "c-field--error", validInput )
                            ]
                        , value update
                        , autofocus True
                        , onBlur (EditTime id Nothing)
                        , onInput (UpdateTime id)
                        , onEnter (Save id field)
                        ]
                        []
                else
                    text time
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
                , onDoubleClick (EditTime id (Just Arrive))
                ]
                [ editable from (editing == Just Arrive) Arrive ]
            , td
                [ class "c-table__cell"
                , onDoubleClick (EditTime id (Just Leave))
                ]
                [ editable to (editing == Just Leave) Leave ]
            , td 
                [ class "c-table__cell"
                , onDoubleClick (EditTime id (Just Lunch)) 
                ] 
                [ editable (toString lunchHours) (editing == Just Lunch) Lunch ]
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
            round_ (totalWorkHours - targetHours)
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
        [ class "u-center-block" ]
        [ div
            [ class "u-center-block__content u-center-block__content--horizontal" ]
            [ span
                [ class "c-input-group c-input-group--rounded u-letter-box--large" ]
                [ button
                    [ class "c-button c-button--rounded c-button--small"
                    , onClick DecrementWeek
                    ]
                    [ i [ class "fa fa-chevron-left tc-button-icon" ] [] ]
                , button
                    [ class "c-button c-button--rounded c-button--small"
                    , onClick ToggleModal
                    ]
                    [ i [ class "fa fa-calendar tc-button-icon" ] [] ]
                , button
                    [ class "c-button c-button--rounded c-button--small"
                    , onClick IncrementWeek
                    ]
                    [ i [ class "fa fa-chevron-right tc-button-icon" ] [] ]
                ]
            ]
        ]


calendarModal : Model -> Html Msg
calendarModal model =
    let
        boolToDisplay bool =
            if bool then
                "block"
            else
                "none"
    in
        div
            [ class "o-grid"
            , style [ ( "display", boolToDisplay model.modalVisible ) ]
            ]
            [ div [ class "c-overlay" ] []
            , div
                [ class "o-grid__cell tc-calendar-modal" ]
                [ div
                    [ class "o-modal u-higher" ]
                    [ div
                        [ class "c-card" ]
                        [ header
                            [ class "c-card__header" ]
                            [ button
                                [ class "c-button c-button--close"
                                , onClick ToggleModal
                                ]
                                [ text "×" ]
                            , h2 [ class "c-heading" ] [ text "Select week" ]
                            ]
                        , div
                            [ class "c-card__body" ]
                            [ Html.map Calendar (Calendar.view model.calendar) ]
                        , footer
                            [ class "c-card__footer" ]
                            [ button
                                [ class "c-button c-button--brand modal"
                                , onClick ToggleModal
                                ]
                                [ text "Close" ]
                            ]
                        ]
                    ]
                ]
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


incrWeek : Date -> Date
incrWeek date =
    Date.Extra.add Date.Extra.Week 1 date


decrWeek : Date -> Date
decrWeek date =
    Date.Extra.add Date.Extra.Week -1 date


weekYear : Date -> String
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


round_ : Float -> Float
round_ number =
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


isValidFloat : String -> Bool
isValidFloat input =
    case String.toFloat input of
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

        AddRows (Ok reports) ->
            { model | reports = reports } ! []

        AddRows (Err _) ->
            model ! []

        EditTime id (Just field) ->
            let
                updateReport : Report -> Report
                updateReport t =
                    if t.id == id then
                        case field of
                            Arrive ->
                                { t
                                    | editing = Just field
                                    , update = formatTime t.arrival
                                }

                            Leave ->
                                { t
                                    | editing = Just field
                                    , update = formatTime t.leave
                                }

                            Lunch ->
                                { t
                                    | editing = Just field
                                    , update = t.lunch |> timestampToHours |> toString
                                }
                    else
                        t

                focus =
                    Dom.focus <| "tc-" ++ id
            in
                { model | reports = List.map updateReport model.reports } ! [ Task.attempt Focus focus ]

        EditTime id Nothing ->
            let
                focus =
                    Dom.focus <| "tc-" ++ id
            in
                { model | reports = List.map (\r -> { r | editing = Nothing } ) model.reports } ! [ Task.attempt Focus focus ]

        UpdateTime id time ->
            let
                updateReport : Report -> Report
                updateReport t =
                    if t.id == id then
                        { t | update = time }
                    else
                        t
            in
                { model | reports = List.map updateReport model.reports } ! []

        Save id isEditing ->
            let
                toTimestamp : String -> String -> Int
                toTimestamp date time =
                    case Date.fromString (date ++ " " ++ time) of
                        Ok timestamp ->
                            round (Date.toTime timestamp)

                        Err _ ->
                            0

                updateReport : Report -> Report
                updateReport t =
                    if t.id == id then
                        case isEditing of
                            Arrive ->
                                let
                                    arrival =
                                        toTimestamp (formatDate t.arrival) t.update
                                in
                                    { t
                                        | arrival = arrival
                                        , total = (t.leave - arrival - (t.lunch * 1000)) // 1000
                                        , editing = Nothing
                                    }

                            Leave ->
                                let
                                    leave =
                                        toTimestamp (formatDate t.leave) t.update
                                in
                                    { t
                                        | leave = leave
                                        , total = (leave - t.arrival - (t.lunch * 1000)) // 1000
                                        , editing = Nothing
                                    }

                            Lunch ->
                                let
                                    lunch =
                                        Result.withDefault 0 (String.toFloat t.update)
                                            |> (*) 3600
                                            |> round
                                in
                                    { t
                                        | lunch = lunch
                                        , total = (t.leave - t.arrival - (lunch * 1000)) // 1000
                                        , editing = Nothing
                                    }
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

        Calendar message ->
            let
                ( cModel, cCmd ) =
                    Calendar.update message model.calendar
            in
                case message of
                    Calendar.SelectDate date ->
                        { model
                            | calendar = cModel
                            , selectedDate = date
                            , modalVisible = not model.modalVisible
                        }
                            ! [ Cmd.map Calendar cCmd, weekReports date ]

                    _ ->
                        { model | calendar = cModel } ! [ Cmd.map Calendar cCmd ]

        ToggleModal ->
            { model | modalVisible = not model.modalVisible } ! []

        Focus _ ->
            model ! []

        PutReport _ ->
            model ! []


reportsDecoder : Json.Decode.Decoder (List Report)
reportsDecoder =
    Json.Decode.list <|
        Json.Decode.map7 Report
            (field "id" Json.Decode.string)
            (field "arrival" Json.Decode.int)
            (field "leave" Json.Decode.int)
            (field "lunch" Json.Decode.int)
            (field "total" Json.Decode.int)
            (Json.Decode.succeed Nothing)
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
    Task.perform SetDate Date.now


weekReports : Date -> Cmd Msg
weekReports date =
    let
        week =
            toString <| Date.Extra.weekNumber date

        year =
            toString <| Date.year date

        url =
            "/api/timereport?year=" ++ year ++ "&week=" ++ week

        request =
            Http.get url reportsDecoder
    in
        Http.send AddRows request


putReport : Report -> Cmd Msg
putReport { id, arrival, leave, lunch, total } =
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

        request =
            Http.request
                { method = "PUT"
                , headers = []
                , url = "/api/timereport/" ++ id
                , body = Http.jsonBody report
                , expect = Http.expectStringResponse (\_ -> Ok ())
                , timeout = Nothing
                , withCredentials = False
                }
    in
        Http.send PutReport request
