name := "Exploration of amazon kinesis"

version := "0.1"

scalaVersion := "2.10.3"

seq(bintrayResolverSettings:_*)

libraryDependencies ++= Seq(
  "io.spray" %%  "spray-json" % "1.2.5",
  "io.github.cloudify" %% "scalazon" % "0.5",
  "com.github.nscala-time" %% "nscala-time" % "0.8.0",
  "com.novus" %% "salat" % "1.9.5"
)
