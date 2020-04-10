{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}

import           Data.Text
import           Test.Hspec
import           Text.RawString.QQ

import           CV                             ( readMarkdownCV )
import           CV.Types

exampleInput :: Text
exampleInput = [r|
let types = (./dhall/types/package.dhall).mkTypes Text

in  { basics =
        { name = { firstName = "", lastName = "" }
        , email = ""
        , phone = Some ""
        , location =
            types.Location.StreetAddress
              { address = "", city = "", postalCode = "", country = Some "" }
        }
    , profiles =
        { homepage = Some ""
        , linkedin = Some { user = "", url = Some "" }
        , github = Some { user = "", url = Some "" }
        , twitter = Some { user = "", url = Some "" }
        }
    , headline = Some ""
    , sections =
      [ { heading = ""
        , content =
            types.SectionContent.Work
              [ { position = ""
                , company = ""
                , jobStartDate = { year = 1, month = 1 }
                , jobEndDate = Some { year = 1, month = 1 }
                , jobLocation = Some ""
                , companyUrl = Some ""
                , jobSummary = Some ""
                }
              ]
        }
      , { heading = ""
        , content =
            types.SectionContent.Volunteering
              [ { volunteerPosition = ""
                , organization = ""
                , volunteerStartDate = { year = 1, month = 1 }
                , volunteerEndDate = Some { year = 1, month = 1 }
                , volunteerLocation = Some ""
                , organizationUrl = Some ""
                , volunteerSummary = Some ""
                }
              ]
        }
      , { heading = ""
        , content =
            types.SectionContent.Skills
              [ { skillArea = ""
                , skillKeywords = [ "" ]
                , skillSummary = Some ""
                }
              ]
        }
      , { heading = ""
        , content =
            types.SectionContent.Education
              [ { studyType = ""
                , area = ""
                , institution = ""
                , studyStartDate = { year = 1, month = 1 }
                , studyEndDate = Some { year = 1, month = 1 }
                , studyLocation = Some ""
                , institutionUrl = Some ""
                , gpa = Some ""
                , courses = [ "" ]
                , studySummary = Some ""
                }
              ]
        }
      , { heading = ""
        , content =
            types.SectionContent.Awards
              [ { awardTitle = ""
                , awardDate = { year = 1, month = 1 }
                , awarder = ""
                , awardSummary = Some ""
                }
              ]
        }
      , { heading = ""
        , content =
            types.SectionContent.Publications
              [ { publicationTitle = ""
                , publisher = ""
                , publicationDate = { year = 1, month = 1 }
                , publicationUrl = Some ""
                , publicationSummary = Some ""
                }
              ]
        }
      , { heading = ""
        , content =
            types.SectionContent.Interests
              [ { interest = "", keywords = [ "" ] } ]
        }
      , { heading = ""
        , content =
            types.SectionContent.Languages [ { language = "", fluency = "" } ]
        }
      ]
    }
|]

exampleCV :: CV Markdown
exampleCV = Markdown <$> CV
  { basics   = Basics
                 { name     = Name "" ""
                 , email    = ""
                 , phone    = Just ""
                 , location = StreetAddress { city       = ""
                                            , address    = ""
                                            , postalCode = ""
                                            , country    = Just ""
                                            }
                 }
  , profiles = Profiles { homepage = Just ""
                        , linkedin = Just $ Social "" $ Just ""
                        , github   = Just $ Social "" $ Just ""
                        , twitter  = Just $ Social "" $ Just ""
                        }
  , headline = Just ""
  , sections =
    [ CVSection
      { heading = ""
      , content = Work
                    [ Job { position     = ""
                          , company      = ""
                          , jobStartDate = CVDate 1 1
                          , jobEndDate   = Just $ CVDate 1 1
                          , jobLocation  = Just ""
                          , companyUrl   = Just ""
                          , jobSummary   = Just ""
                          }
                    ]
      }
    , CVSection
      { heading = ""
      , content = Volunteering
                    [ Volunteer { volunteerPosition  = ""
                                , organization       = ""
                                , volunteerStartDate = CVDate 1 1
                                , volunteerEndDate   = Just $ CVDate 1 1
                                , volunteerLocation  = Just ""
                                , organizationUrl    = Just ""
                                , volunteerSummary   = Just ""
                                }
                    ]
      }
    , CVSection
      { heading = ""
      , content = Skills
        [Skill { skillArea = "", skillKeywords = [""], skillSummary = Just "" }]
      }
    , CVSection
      { heading = ""
      , content = Education
                    [ Study { studyType      = ""
                            , area           = ""
                            , institution    = ""
                            , studyStartDate = CVDate 1 1
                            , studyEndDate   = Just $ CVDate 1 1
                            , studyLocation  = Just ""
                            , institutionUrl = Just ""
                            , gpa            = Just ""
                            , courses        = [""]
                            , studySummary   = Just ""
                            }
                    ]
      }
    , CVSection
      { heading = ""
      , content = Awards
                    [ Award { awardTitle   = ""
                            , awardDate    = CVDate 1 1
                            , awarder      = ""
                            , awardSummary = Just ""
                            }
                    ]
      }
    , CVSection
      { heading = ""
      , content = Publications
                    [ Publication { publicationTitle   = ""
                                  , publisher          = ""
                                  , publicationDate    = CVDate 1 1
                                  , publicationUrl     = Just ""
                                  , publicationSummary = Just ""
                                  }
                    ]
      }
    , CVSection
      { heading = ""
      , content = Interests [Interest { interest = "", keywords = [""] }]
      }
    , CVSection { heading = ""
                , content = Languages [Language { language = "", fluency = "" }]
                }
    ]
  }

main :: IO ()
main = hspec $ do
  describe "Frontend" $ do
    it "should parse simple example" $ do
      readMarkdownCV exampleInput `shouldReturn` exampleCV
