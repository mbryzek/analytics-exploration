name := "Exploration of amazon kinesis"

version := "0.1"

scalaVersion := "2.10.3"

seq(bintrayResolverSettings:_*)

libraryDependencies ++= Seq(
  "io.spray" %%  "spray-json" % "1.2.5",
  "org.json4s" %% "json4s-native" % "3.2.6",
  "io.github.cloudify" %% "scalazon" % "0.5"
)
