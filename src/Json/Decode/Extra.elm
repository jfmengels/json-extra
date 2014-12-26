module Json.Decode.Extra where
{-| Convenience functions for working with Json

# Date
@docs date

# Incremental Decoding
@docs andApply

-}

import Json.Decode (..)
import Date
import Time

{-| Can be helpful when decoding large objects incrementally.

    import Date (Date)

    type alias User =
      { id                : Int
      , createdAt         : Date
      , updatedAt         : Date
      , deletedAt         : Maybe Date
      , username          : Maybe String
      , email             : Maybe String
      , fullname          : Maybe String
      , avatar            : Maybe String
      , isModerator       : Bool
      , isOrganization    : Bool
      , isAdmin           : Bool
      }

    metaDecoder : (Int -> Date -> Date -> Maybe Date -> b) -> Decoder b
    metaDecoder f = f
      `map`      ("id"        := int)
      `andApply` ("createdAt" := date)
      `andApply` ("updatedAt" := date)
      `andApply` ("deletedAt" := maybe date)

    userDecoder : Decoder User
    userDecoder = metaDecoder User
      `andApply` ("username"          := maybe string)
      `andApply` ("email"             := maybe string)
      `andApply` ("fullname"          := maybe string)
      `andApply` ("avatar"            := maybe string)
      `andApply` ("isModerator"       := bool)
      `andApply` ("isOrganization"    := bool)
      `andApply` ("isAdmin"           := bool)

This is a shortened form of

    metaDecoder : (Int -> Date -> Date -> Maybe Date -> b) -> Decoder b
    metaDecoder f = f
      `map`      ("id"        := int)
      `andThen` \f -> f `map` ("createdAt" := date)
      `andThen` \f -> f `map` ("updatedAt" := date)
      `andThen` \f -> f `map` ("deletedAt" := maybe date)

    userDecoder : Decoder User
    userDecoder = metaDecoder User
      `andThen` \f -> f `map` ("username"          := maybe string)
      `andThen` \f -> f `map` ("email"             := maybe string)
      `andThen` \f -> f `map` ("fullname"          := maybe string)
      `andThen` \f -> f `map` ("avatar"            := maybe string)
      `andThen` \f -> f `map` ("isModerator"       := bool)
      `andThen` \f -> f `map` ("isOrganization"    := bool)
      `andThen` \f -> f `map` ("isAdmin"           := bool)

-}
andApply : Decoder (a -> b) -> Decoder a -> Decoder b
andApply f aDecoder =
  f `andThen` (\f' -> f' `map` aDecoder)

{-| Extract a date.

Note that this function is not total, it will throw an exception given an incorrectly formatted date.
See 'Date.fromString' and 'Json.customDecoder'.

-}
date : Decoder Date.Date
date = customDecoder string Date.fromString

-- {-| Extract a time value.
-- 
-- Note that this function is not total, it will throw an exception given an incorrectly formatted time value.
-- See 'Time.fromString' and 'Json.customDecoder'.
-- 
-- -}
-- time : Decoder Time.Time
-- time = customDecoder string (Date.fromString >> Date.toTime)