import io.github.cloudify.scala.aws.kinesis.Client
import io.github.cloudify.scala.aws.kinesis.Client.ImplicitExecution._
import io.github.cloudify.scala.aws.kinesis.KinesisDsl._
import io.github.cloudify.scala.aws.auth.CredentialsProvider.DefaultHomePropertiesFile
import java.nio.ByteBuffer
import scala.concurrent.duration._
import scala.concurrent.{Future, Await}
import scala.concurrent.ExecutionContext.Implicits.global
import io.github.cloudify.scala.aws.kinesis.Definitions.Stream

case class Data(value: String)

case class MyStream(client: Client, streamName: String, stream: Stream) {

  import org.json4s._
  import org.json4s.JsonDSL._

  private implicit val kinesisClient = client

  def put(key: String, data: Data) {
    val putData = for {
//      _ <- stream.put(ByteBuffer.wrap(compact(render(data))), key)
      _ <- stream.put(ByteBuffer.wrap("test".getBytes), key)
    } yield ()
    Await.result(putData, 30.seconds)
  }

  def get(): Iterable[Data] = {
    val getRecords = for {
      shards <- stream.shards.list
      iterators <- Future.sequence(shards.map {
        shard =>
          implicitExecute(shard.iterator)
      })
      records <- Future.sequence(iterators.map {
        iterator =>
          implicitExecute(iterator.nextRecords)
      })
    } yield records
    val records = Await.result(getRecords, 30.seconds)
    // io.github.cloudify.scala.aws.kinesis.Definitions.NextRecords
    records.map { bytes => Data(bytes.toString) }
  }

}

case class KinesisClient() {

  private implicit val kinesisClient = Client.fromCredentials(DefaultHomePropertiesFile)

  def createActiveStream(streamName: String) = {
    val createStream = for {
      s <- Kinesis.streams.create(streamName)
    } yield s

    val s = Await.result(createStream, 60.seconds)
    Await.result(s.waitActive.retrying(60), 60.seconds)
    MyStream(kinesisClient, streamName, s)
  }

}

object Hi {
  val StreamName = "analytics-exploration-stream"

  def main(args: Array[String]) = {
    println("Hi!")
    implicit val kinesisClient = KinesisClient()

    print(s"stream '$StreamName':  creating...")
    val stream = kinesisClient.createActiveStream(StreamName)
    println("active")

    stream.put("test", Data("value"))
    println("data stored")

    stream.get.foreach { d =>
      println(d)
    }

    /*
    // Then we delete the stream.
    val deleteStream = for {
      _ <- s.delete
    } yield ()
      Await.result(deleteStream, 30.seconds)
    println("stream deleted")
    */
  }

}
