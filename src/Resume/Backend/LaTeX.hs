{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

module Resume.Backend.LaTeX
  ( renderText,
  )
where

import Control.Monad.Reader
import Data.Default
import Data.Maybe
import qualified Data.Text as T
import Resume.Types as R
import Text.LaTeX
import Text.LaTeX.Base.Class
import Text.LaTeX.Packages.BibLaTeX
import Text.LaTeX.Packages.Inputenc
import Text.Pandoc (PandocError)
import qualified Text.Pandoc as P

data LaTeXBackendOptions
  = LaTeXBackendOptions {bibFile :: Maybe FilePath}

instance Default LaTeXBackendOptions where
  def = LaTeXBackendOptions {bibFile = Nothing}

-- | Render Resume with Markdown-formatted text as LaTeX
renderText :: LaTeXBackendOptions -> Resume Markdown -> Either PandocError Text
renderText opts r =
  render . flip runReader opts . execLaTeXT . resume <$> traverse fromMarkdown r
  where
    fromMarkdown =
      P.runPure . (P.readMarkdown def >=> P.writeLaTeX def) . unMarkdown

type LaTeXReader = LaTeXT (Reader LaTeXBackendOptions)

resume :: Resume Text -> LaTeXReader ()
resume Resume {..} = do
  documentclass [FontSize (Pt 11), Paper A4] "moderncv"
  usepackage [raw "scale=0.8"] "geometry"
  usepackage [utf8] inputenc
  lift (asks bibFile)
    >>= foldMap
      ( \f -> do
          usepackage ["backend=biber"] biblatex
          addbibresource f
      )
  pandocHeader
  comm1 "moderncvstyle" "casual"
  comm1 "moderncvcolor" "blue"
  foldMap (title . raw) headline
  foldMap
    (\Name {..} -> comm2 "name" (raw firstName) (raw lastName))
    (name basics)
  comm1 "email" $ raw $ email basics
  foldMap (\R.Link {url = url} -> comm1 "homepage" $ raw url) $
    homepage profiles
  foldMap (mkSocial "linkedin") $ linkedin profiles
  foldMap (mkSocial "twitter") $ twitter profiles
  foldMap (mkSocial "github") $ github profiles
  case location basics of
    StreetAddress {..} ->
      comm3
        "address"
        (raw address)
        (raw $ T.unwords [city, postalCode])
        (raw $ fromMaybe "" country)
    _ -> mempty
  foldMap (\t -> optFixComm "phone" 1 ["mobile", raw t]) (phone basics)
  document $ do
    comm0 "makecvtitle"
    mapM_ mkSection sections

pandocHeader :: LaTeXReader ()
pandocHeader = comm2 "providecommand" (comm0 "tightlist") $ do
  comm2 "setlength" (commS "itemsep") "0pt"
  comm2 "setlength" (commS "parskip") "0pt"

mkSocial :: Text -> Social -> LaTeXReader ()
mkSocial service Social {..} = optFixComm "social" 1 [raw service, raw user]

mkSection :: Section Text -> LaTeXReader ()
mkSection Section {..} = do
  section (raw heading)
  case content of
    Paragraph t -> raw t
    Work xs -> mapM_ mkJob xs
    Volunteering xs -> mapM_ mkVolunteer xs
    Education xs -> mapM_ mkStudy xs
    Skills xs -> mapM_ mkSkill xs
    BibTeXPublications xs -> lift (asks bibFile) >>= \bibFile ->
      when (isJust bibFile) $ do
        mapM_ (comm1 "nocite" . raw) xs
        optFixComm "printbibliography" 1 [raw "heading=none"]
    _ -> error "not implemented"

mkJob :: Job Text -> LaTeXReader ()
mkJob Job {..} =
  comm6
    "cventry"
    (mkDateRange jobStartDate jobEndDate)
    (raw position)
    (raw company)
    (foldMap raw jobLocation)
    ""
    (foldMap raw jobSummary)

mkVolunteer :: Volunteer Text -> LaTeXReader ()
mkVolunteer Volunteer {..} =
  comm6
    "cventry"
    (mkDateRange volunteerStartDate volunteerEndDate)
    (raw volunteerPosition)
    (raw organization)
    (foldMap raw volunteerLocation)
    ""
    (foldMap raw volunteerSummary)

mkStudy :: Study Text -> LaTeXReader ()
mkStudy Study {..} =
  comm6
    "cventry"
    (mkDateRange studyStartDate studyEndDate)
    (raw studyType)
    (raw institution)
    (foldMap raw studyLocation)
    ""
    (foldMap raw studySummary)

mkDateRange :: LaTeXC l => Date -> Maybe Date -> l
mkDateRange startDate =
  maybe (mkDate startDate) (\d -> mkDate startDate <> "--" <> mkDate d)

mkDate :: LaTeXC l => Date -> l
mkDate Date {..} = fromString $ show month ++ "/" ++ show year

mkSkill :: Skill Text -> LaTeXReader ()
mkSkill Skill {..} = case skillSummary of
  Just summary -> comm2 "cvitem" (raw skillArea) (raw summary)
  Nothing ->
    error
      "Rendering skill keyword lists is not yet implemented. Please use 'skillSummary' instead."
