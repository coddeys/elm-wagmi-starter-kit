port module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as D
import Json.Encode as E



-- MAIN


main : Program E.Value Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { address : String
    }


init : E.Value -> ( Model, Cmd Msg )
init flags =
    ( case D.decodeValue decoder flags of
        Ok model ->
            model

        Err _ ->
            { address = "" }
    , Cmd.none
    )



-- UPDATE


type Msg
    = ConnectWalletClicked
    | ReceivedAddress String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ConnectWalletClicked ->
            ( model
            , connectWallet ()
            )

        ReceivedAddress str ->
            ( { model | address = str }
            , Cmd.none
            )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container", style "margin" "2em" ]
        [ div [] [ button [ onClick ConnectWalletClicked ] [ text "Connect Wallet" ] ]
        , div [ style "margin-top" "1em" ]
            [ text "Address: "
            , strong [] [ text model.address ]
            ]
        ]



-- PORTS


port connectWallet : () -> Cmd msg


port addressReceived : (String -> msg) -> Sub msg



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    addressReceived ReceivedAddress



-- JSON ENCODE/DECODE


encode : Model -> E.Value
encode model =
    E.object
        [ ( "address", E.string model.address )
        ]


decoder : D.Decoder Model
decoder =
    D.map Model
        (D.field "address" D.string)
