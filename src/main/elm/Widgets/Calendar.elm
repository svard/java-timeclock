module Widgets.Calendar exposing ( Msg(SelectDate), Model, update, view, initialModel )

import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import Date exposing (Date)
import Date.Extra
import Date.Extra.Facts exposing (daysInMonth)
import Task
import List


type Msg
    = IncrementYear
    | DecrementYear
    | IncrementMonth
    | DecrementMonth
    | SetInitialDate Date
    | SelectDate Date
    | SetMonth Date


type alias Model =
    { activeMonth : Date
    , selectedDate : Date
    , today : Date
    }


type alias CalendarDate =
    { date : Date
    , inMonth : Bool
    , today: Bool
    , selected : Bool
    }


initialModel : ( Model, Cmd Msg )
initialModel =
    { activeMonth = Date.fromTime 0
    , selectedDate = Date.fromTime 0
    , today = Date.fromTime 0
    } ! [ setInitialMonth, setInitialDate ]


setInitialMonth : Cmd Msg
setInitialMonth =
    Task.perform SetMonth Date.now


setInitialDate : Cmd Msg
setInitialDate =
    Task.perform SetInitialDate Date.now


addTime : Date.Extra.Interval -> Date -> Date
addTime unit date =
    Date.Extra.add unit 1 date


subtractTime : Date.Extra.Interval -> Date -> Date
subtractTime unit date =
    Date.Extra.add unit -1 date


monthStartOnDay : Date -> Int
monthStartOnDay date =
    let
        year = 
            Date.year date

        month =
            Date.month date
    in
        Date.Extra.weekdayNumber (Date.Extra.fromParts year month 1 0 0 0 0)


monthEndOnDay : Date -> Int
monthEndOnDay date =
    let
        year = 
            Date.year date

        month =
            Date.month date

        day =
            daysInMonth year month
    in
        Date.Extra.weekdayNumber (Date.Extra.fromParts year month day 0 0 0 0)


isDay : Date -> Date -> Bool
isDay day month =
    Date.Extra.equalBy Date.Extra.Day day month



calendarDates : Model -> List CalendarDate
calendarDates model =
    let
        previousMonth =
            subtractTime Date.Extra.Month model.activeMonth

        nextMonth =
            addTime Date.Extra.Month model.activeMonth

        daysInCurrentMonth = 
            daysInMonth (Date.year model.activeMonth) (Date.month model.activeMonth)

        daysInPreviousMonth =
            daysInMonth (Date.year previousMonth) (Date.month previousMonth)

        prefixDays =
            List.range 1 daysInPreviousMonth
            |> List.map (\number -> Date.Extra.fromParts (Date.year previousMonth) (Date.month previousMonth) number 0 0 0 0)
            |> List.reverse
            |> List.take ((monthStartOnDay model.activeMonth) - 1)
            |> List.reverse
            |> List.map (\date -> CalendarDate date False False False)

        days =
            List.range 1 daysInCurrentMonth
            |> List.map (\number -> Date.Extra.fromParts (Date.year model.activeMonth) (Date.month model.activeMonth) number 0 0 0 0)
            |> List.map (\date -> CalendarDate date True (isDay date model.today) (isDay date model.selectedDate))

        postfixDays =
            List.range 1 (7 - monthEndOnDay model.activeMonth)
            |> List.map (\number -> Date.Extra.fromParts (Date.year nextMonth) (Date.month nextMonth) number 0 0 0 0)
            |> List.map (\date -> CalendarDate date False False False)
    in
        List.concat [prefixDays, days, postfixDays]



dateView : CalendarDate -> Html Msg
dateView { date, inMonth, today, selected } =
    button 
        [ classList 
            [ ( "c-calendar__date", True )
            , ( "c-calendar__date--in-month", inMonth )
            , ( "c-calendar__date--today", today )
            , ( "c-calendar__date--selected", selected )
            ]
        , onClick (SelectDate date)
        ] 
        [ text <| toString (Date.day date) ]


view : Model -> Html Msg
view model =
    let
        year = 
            Date.Extra.toFormattedString "y" model.activeMonth

        month =
            Date.Extra.toFormattedString "MMMM" model.activeMonth

        dates =
            calendarDates model
    in
      
    div 
        [ class "c-calendar c-calendar--higher" ] 
        (List.append
            [ button 
                [ class "c-calendar__control" 
                , onClick DecrementYear ] 
                [ text "‹" ] 
            , div [ class "c-calendar__header" ] [ text year ]
            , button 
                [ class "c-calendar__control" 
                , onClick IncrementYear ] 
                [ text "›" ]
            , button 
                [ class "c-calendar__control" 
                , onClick DecrementMonth ] 
                [ text "‹" ] 
            , div [ class "c-calendar__header" ] [ text month ]
            , button 
                [ class "c-calendar__control" 
                , onClick IncrementMonth ] 
                [ text "›" ]
            , div [ class "c-calendar__day" ] [ text "Mo" ]
            , div [ class "c-calendar__day" ] [ text "Tu" ]
            , div [ class "c-calendar__day" ] [ text "We" ]
            , div [ class "c-calendar__day" ] [ text "Th" ]
            , div [ class "c-calendar__day" ] [ text "Fr" ]
            , div [ class "c-calendar__day" ] [ text "Sa" ]
            , div [ class "c-calendar__day" ] [ text "Su" ]
            ]
            (List.map dateView dates))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        IncrementYear -> 
            { model | activeMonth = addTime Date.Extra.Year model.activeMonth } ! []

        DecrementYear -> 
            { model | activeMonth = subtractTime Date.Extra.Year model.activeMonth } ! []

        IncrementMonth -> 
            { model | activeMonth = addTime Date.Extra.Month model.activeMonth } ! []

        DecrementMonth -> 
            { model | activeMonth = subtractTime Date.Extra.Month model.activeMonth } ! []

        SetInitialDate date ->
            { model | selectedDate = date, today = date } ! []

        SelectDate date -> 
            case Date.Extra.equalBy Date.Extra.Month date model.activeMonth of
                True ->
                    { model | selectedDate = date } ! []
                
                False ->
                    model ! []

        SetMonth date -> 
            { model | activeMonth = date } ! []