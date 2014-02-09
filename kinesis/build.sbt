name := "Exploration of amazon kinesis"

version := "0.1"

scalaVersion := "2.10.3"

seq(bintrayResolverSettings:_*)

libraryDependencies ++= Seq("io.github.cloudify" %% "scalazon" % "0.5")
