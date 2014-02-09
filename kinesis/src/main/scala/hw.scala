import io.github.cloudify.scala.aws.kinesis.Client
import io.github.cloudify.scala.aws.kinesis.Client.ImplicitExecution._
import io.github.cloudify.scala.aws.kinesis.KinesisDsl._
import io.github.cloudify.scala.aws.auth.CredentialsProvider.DefaultHomePropertiesFile
import java.nio.ByteBuffer
import scala.concurrent.duration._
import scala.concurrent.{Future, Await}
import scala.concurrent.ExecutionContext.Implicits.global
import io.github.cloudify.scala.aws.kinesis.Definitions.Stream
import java.util.UUID

object Data {

  object Keys {

    val Guid = "guid"
    val Value = "v"

  }

  def fromMap(map: Map[String, String]): Data = {
    Data(guid = UUID.fromString(get(map, Keys.Guid)),
         value = get(map, Keys.Value))
  }

  private def get(map: Map[String, String], field: String): String = {
    map.get(field).getOrElse {
      sys.error("Map is missing key[%s]: %s".format(field, map.toString))
    }
  }

}

case class Data(guid: UUID, value: String) {

  def toMap: Map[String, String] = {
    Map(Data.Keys.Guid -> guid.toString,
        Data.Keys.Value -> value)
  }

}

case class MyStream(client: Client, streamName: String, stream: Stream) {
  import spray.json._
  import DefaultJsonProtocol._

  private implicit val kinesisClient = client

  def put(data: Data) {

    val putData = for {
      _ <- stream.put(ByteBuffer.wrap(data.toMap.toJson.compactPrint.getBytes), streamName)
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

    val records = Await.result(getRecords, 30.seconds).flatMap(_.records)
    // io.github.cloudify.scala.aws.kinesis.Definitions.NextRecords
    // records.map { bytes => Data(new String(bytes)) }
    //records.flatMap { result => result.records.map { r => Data(r.data.toString) }}
    records.map { rec =>
      val json = new String(rec.data.array).asJson
      Data.fromMap(json.convertTo[Map[String, String]])
    }
  }

  def delete() {
    val deleteStream = for {
      _ <- stream.delete
    } yield ()
    Await.result(deleteStream, 30.seconds)
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
  val StreamName = "analytics-exploration-stream-test-json"

  def main(args: Array[String]) = {
    println("Hi!")
    implicit val kinesisClient = KinesisClient()

    print(s"stream '$StreamName':  creating...")
    val stream = kinesisClient.createActiveStream(StreamName)
    println("active")

    stream.put(Data(UUID.randomUUID, "testing"))
    println("data stored")

    stream.get.foreach { d =>
      println(d)
    }

  }

}
