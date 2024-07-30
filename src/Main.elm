port module Main exposing (..)

import Browser
import Html exposing (Html, button, div, strong, text)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import Json.Decode as JD



-- MAIN


type alias Flags =
    ()


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { wallet : WalletStatus
    }


type Wallet
    = Wallet ChainId Address


type alias ChainId =
    Int


type alias Address =
    String


type WalletStatus
    = NotConnected
    | Connected Wallet
    | ConnectionError String
    | Disconnected


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( { wallet = NotConnected }
    , Cmd.none
    )



-- UPDATE


type Msg
    = ConnectWalletClicked
    | DisconnectWalletClicked
    | ReceivedAddress JD.Value


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ConnectWalletClicked ->
            ( model
            , connectWallet ()
            )

        DisconnectWalletClicked ->
            ( { model | wallet = Disconnected }
            , disconnectWallet ()
            )

        ReceivedAddress value ->
            case JD.decodeValue addressDecoder value of
                Ok wallet ->
                    ( { model | wallet = Connected wallet }
                    , Cmd.none
                    )

                Err err ->
                    ( model
                    , Cmd.none
                    )


addressDecoder : JD.Decoder Wallet
addressDecoder =
    JD.map2 Wallet
        (JD.field "chainId" JD.int)
        (JD.field "address" JD.string)



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container", style "margin" "2em" ]
        [ viewConnectWallet model.wallet
        , div [ style "margin-top" "1em" ]
            [ viewWallet model.wallet ]
        ]


viewConnectWallet : WalletStatus -> Html Msg
viewConnectWallet walletStatus =
    case walletStatus of
        NotConnected ->
            div [] [ button [ onClick ConnectWalletClicked ] [ text "Connect Wallet" ] ]

        Connected (Wallet chainId address) ->
            div [] [ button [ onClick DisconnectWalletClicked ] [ text "Disconnect from the Wallet" ] ]

        ConnectionError string ->
            text "error"

        Disconnected ->
            div [] [ button [ onClick ConnectWalletClicked ] [ text "Connect Wallet" ] ]


viewWallet : WalletStatus -> Html Msg
viewWallet walletStatus =
    case walletStatus of
        NotConnected ->
            text "NOT CONNECTED"

        Connected (Wallet chainId address) ->
            div [ style "margin-top" "1em" ]
                [ div [] [ text "CONNECTED" ]
                , div []
                    [ text "Chain ID: "
                    , strong [] [ text (String.fromInt chainId) ]
                    ]
                , div []
                    [ text "Address: "
                    , strong [] [ text address ]
                    ]
                ]

        ConnectionError string ->
            text "error"

        Disconnected ->
            text "Disconnected"



-- PORTS


port connectWallet : () -> Cmd msg


port disconnectWallet : () -> Cmd msg


port addressReceived : (JD.Value -> msg) -> Sub msg



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    addressReceived ReceivedAddress
