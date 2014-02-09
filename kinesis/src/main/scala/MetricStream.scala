import io.github.cloudify.scala.aws.kinesis.Client
import io.github.cloudify.scala.aws.kinesis.Client.ImplicitExecution._
import io.github.cloudify.scala.aws.kinesis.Definitions.Stream
import java.nio.ByteBuffer
import scala.concurrent.duration._
import scala.concurrent.{Future, Await}
import scala.concurrent.ExecutionContext.Implicits.global

case class MetricStream(client: Client, streamName: String, stream: Stream) {
  import spray.json._
  import DefaultJsonProtocol._

  private implicit val kinesisClient = client

  def put(data: Metric) {

    val putData = for {
      _ <- stream.put(ByteBuffer.wrap(data.toMap.toJson.compactPrint.getBytes), streamName)
    } yield ()
    Await.result(putData, 30.seconds)
  }

  def get(): Iterable[Metric] = {
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
    records.map { rec =>
      val json = new String(rec.data.array).asJson
      Metric.fromMap(json.convertTo[Map[String, String]])
    }
  }

  def delete() {
    val deleteStream = for {
      _ <- stream.delete
    } yield ()
    Await.result(deleteStream, 30.seconds)
  }

}
