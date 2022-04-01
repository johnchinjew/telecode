module Main exposing (main)

import Browser
import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
import List.Extra as List
import Set exposing (Set)


main : Program (List String) Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        }



-- MODEL


type alias Model =
    { turn : Turn
    , score : Int
    , clueValue : String
    , clueSelected : Set Int
    , guessSelected : Set Int
    , quotaIndex : Int
    , quotas : List Int
    , activeWords : List String
    , remainingWords : List String
    }


type Turn
    = ClueGiver
    | Guesser


init : List String -> ( Model, Cmd Msg )
init words =
    ( Model ClueGiver 0 "" Set.empty Set.empty 0 [ 1, 2, 2, 3, 1, 2, 3, 2, 1, 4 ] (List.take 9 words) (List.drop 9 words)
    , Cmd.none
    )



-- UPDATE


type Msg
    = NoOp
    | ToggleWord Int
    | ClueValueChanged String
    | SubmitClue
    | SubmitGuess


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        ToggleWord index ->
            case model.turn of
                ClueGiver ->
                    case Set.member index model.clueSelected of
                        True ->
                            ( { model | clueSelected = Set.remove index model.clueSelected }, Cmd.none )

                        False ->
                            ( { model | clueSelected = Set.insert index model.clueSelected }, Cmd.none )

                Guesser ->
                    case Set.member index model.guessSelected of
                        True ->
                            ( { model | guessSelected = Set.remove index model.guessSelected }, Cmd.none )

                        False ->
                            ( { model | guessSelected = Set.insert index model.guessSelected }, Cmd.none )

        ClueValueChanged newClueValue ->
            ( { model | clueValue = newClueValue }, Cmd.none )

        SubmitClue ->
            ( { model | turn = Guesser }, Cmd.none )

        SubmitGuess ->
            case model.guessSelected == model.clueSelected of
                True ->
                    ( { model
                        | score = model.score + 1
                        , quotaIndex = model.quotaIndex + 1
                        , turn = ClueGiver
                        , clueValue = ""
                        , activeWords =
                            model.activeWords
                                |> List.indexedMap Tuple.pair
                                |> List.filterNot (\( i, _ ) -> Set.member i model.clueSelected)
                                |> List.map (\( _, word ) -> word)
                                |> List.append (List.take (Set.size model.clueSelected) model.remainingWords)
                        , remainingWords = List.drop (Set.size model.clueSelected) model.remainingWords
                        , clueSelected = Set.empty
                        , guessSelected = Set.empty
                      }
                    , Cmd.none
                    )

                False ->
                    init model.remainingWords



-- VIEW


view : Model -> Html Msg
view model =
    case model.turn of
        ClueGiver ->
            Html.div
                []
                [ Html.p [] [ Html.text <| "Score: " ++ String.fromInt model.score ]
                , Html.p [] [ Html.text <| "Create a single-word clue connecting " ++ (String.fromInt <| currentQuota model) ++ " words." ]
                , wordGrid model.clueSelected model
                , Html.br [] []
                , Html.input [ Attributes.value model.clueValue, Events.onInput ClueValueChanged ] []
                , Html.button
                    [ Events.onClick SubmitClue
                    , Attributes.disabled <| (Set.size model.clueSelected /= currentQuota model) || (1 /= (List.length <| String.words model.clueValue))
                    ]
                    [ Html.text <| "Submit (" ++ (String.fromInt <| Set.size model.clueSelected) ++ "/" ++ (String.fromInt <| currentQuota model) ++ ")" ]
                ]

        Guesser ->
            Html.div
                []
                [ Html.p [] [ Html.text <| "Score: " ++ String.fromInt model.score ]
                , Html.p [] [ Html.text <| "Connect " ++ (String.fromInt <| currentQuota model) ++ " words using the clue: '" ++ model.clueValue ++ "'." ]
                , wordGrid model.guessSelected model
                , Html.br [] []
                , Html.button
                    [ Events.onClick SubmitGuess
                    , Attributes.disabled (Set.size model.guessSelected /= currentQuota model)
                    ]
                    [ Html.text <| "Submit (" ++ (String.fromInt <| Set.size model.guessSelected) ++ "/" ++ (String.fromInt <| currentQuota model) ++ ")" ]
                ]


currentQuota : Model -> Int
currentQuota model =
    Maybe.withDefault 0 <| List.getAt model.quotaIndex model.quotas


wordGrid : Set Int -> Model -> Html Msg
wordGrid selected model =
    Html.fieldset [ Attributes.style "display" "inline-block" ]
        [ model.activeWords
            |> List.drop 0
            |> List.take 3
            |> List.indexedMap (\i word -> checkbox (ToggleWord i) word (Set.member i selected))
            |> Html.div [ Attributes.style "padding" "10px 0" ]
        , model.activeWords
            |> List.drop 3
            |> List.take 3
            |> List.indexedMap (\i word -> checkbox (ToggleWord <| i + 3) word (Set.member (i + 3) selected))
            |> Html.div [ Attributes.style "padding" "10px 0" ]
        , model.activeWords
            |> List.drop 6
            |> List.take 3
            |> List.indexedMap (\i word -> checkbox (ToggleWord <| i + 6) word (Set.member (i + 6) selected))
            |> Html.div [ Attributes.style "padding" "10px 0" ]
        ]


checkbox : msg -> String -> Bool -> Html msg
checkbox msg name isChecked =
    Html.label
        [ Attributes.style "padding" "10px 20px" ]
        [ Html.input [ Attributes.type_ "checkbox", Attributes.checked isChecked, Events.onClick msg ] []
        , Html.text name
        ]
