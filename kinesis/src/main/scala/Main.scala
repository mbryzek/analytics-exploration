import java.util.{Date, UUID}

object Hi {
  val MetricName = "heartrate-v1"
  val StreamName = "analytics-exploration-stream-%s".format(MetricName)

  def main(args: Array[String]) = {
    MetricsDao.findByGuid(UUID.randomUUID)

    implicit val kinesisClient = KinesisClient()

    print(s"stream '$StreamName':  creating...")
    val stream = kinesisClient.createActiveStream(StreamName)
    println("active")

    stream.put(Metric(UUID.randomUUID, new Date(), "heartrate", BigDecimal("60")))
    println("data stored")

    stream.get.foreach { d =>
      val existing = MetricsDao.findByGuid(d.guid)
      if (existing.isEmpty) {
        println(s"Storing new metric: $d")
        MetricsDao.insert(d)
      } else {
        println(s"Guid[${d.guid}] already processed")
      }
    }
  }

}
