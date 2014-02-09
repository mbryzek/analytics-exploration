import io.github.cloudify.scala.aws.kinesis.Client
import io.github.cloudify.scala.aws.kinesis.Client.ImplicitExecution._
import io.github.cloudify.scala.aws.kinesis.KinesisDsl.Kinesis
import io.github.cloudify.scala.aws.kinesis.Definitions.Stream
import io.github.cloudify.scala.aws.auth.CredentialsProvider.DefaultHomePropertiesFile

import scala.concurrent.duration._
import scala.concurrent.Await
import scala.concurrent.ExecutionContext.Implicits.global

case class KinesisClient() {

  private implicit val kinesisClient = Client.fromCredentials(DefaultHomePropertiesFile)

  def createActiveStream(streamName: String) = {
    val createStream = for {
      s <- Kinesis.streams.create(streamName)
    } yield s

    val s = Await.result(createStream, 60.seconds)
    Await.result(s.waitActive.retrying(60), 60.seconds)
    MetricStream(kinesisClient, streamName, s)
  }

}

