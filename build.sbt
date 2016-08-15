name := "eva4s"

version := "0.1.0-SNAPSHOT"

organization in ThisBuild := "com.github.wookietreiber"

scalaVersion in ThisBuild := "2.11.8"

scaliteratePandocPDFOptions in Compile ++= Seq (
  "-V", "mainfont=Droid Serif",
	"-V", "sansfont=Droid Sans",
	"-V", "monofont=Droid Sans Mono Slashed"
)
