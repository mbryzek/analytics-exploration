import io.github.cloudify.scala.aws.kinesis.Client
import io.github.cloudify.scala.aws.kinesis.Client.ImplicitExecution._
import io.github.cloudify.scala.aws.kinesis.KinesisDsl._
import io.github.cloudify.scala.aws.auth.CredentialsProvider.DefaultHomePropertiesFile
import java.nio.ByteBuffer
import scala.concurrent.duration._
import scala.concurrent.{Future, Await}
import scala.concurrent.ExecutionContext.Implicits.global

object Hi {
  val StreamName = "analytics-exploration-stream-test"

  def main(args: Array[String]) = {
    println("Hi!")
    implicit val kinesisClient = Client.fromCredentials(DefaultHomePropertiesFile)
    println("CLIENT: " + kinesisClient)

    val createStream = for {
      s <- Kinesis.streams.create(StreamName)
    } yield s

    val s = Await.result(createStream, 60.seconds)
    println(s"stream '$StreamName' created")

    Await.result(s.waitActive.retrying(60), 60.seconds)
    println(s"stream '$StreamName' active")

    val description = Await.result(s.describe, 10.seconds)
    println(s"Status: $description.status")
    println(s"Active: $description.isActive")

    val putData = for {
      _ <- s.put(ByteBuffer.wrap("hello".getBytes), "k1")
      _ <- s.put(ByteBuffer.wrap("how".getBytes), "k1")
      _ <- s.put(ByteBuffer.wrap("are you?".getBytes), "k2")
    } yield ()
    Await.result(putData, 30.seconds)
    println("data stored")

    val getRecords = for {
      shards <- s.shards.list
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
    println("data retrieved: " + records)

    // Then we delete the stream.
    val deleteStream = for {
      _ <- s.delete
    } yield ()
      Await.result(deleteStream, 30.seconds)
    println("stream deleted")
  }

}
