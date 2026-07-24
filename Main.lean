import VersoSlides
import Slides

open VersoSlides

def main : IO UInt32 :=
  slidesMain
    (config := { theme := "simple", slideNumber := true, transition := "slide" })
    (doc := %doc Slides)
