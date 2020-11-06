module Model exposing (Model, init)

import Material -- TODO

-- the data definition for the chat application
type alias Model =
    { title : String
    , chatMsgs : List String
    , current Msg : String
    , mdl : Material.Model
    }

init : ( Model, Cmd a )
init = (
    { title = "Chat Application"
    , chatMsgs = []
    , currentMsg = ""
    , mdl = Material.model
    }, Cmd.none)
