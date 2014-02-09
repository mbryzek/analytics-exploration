import java.util.{Date, UUID}

object Metric {

  object Keys {

    val Guid = "guid"
    val Timestamp = "ts"
    val Name = "n"
    val Value = "v"

  }

  def fromMap(map: Map[String, String]): Metric = {
    Metric(guid = UUID.fromString(get(map, Keys.Guid)),
         timestamp = new Date(get(map, Keys.Timestamp).toLong),
         name = get(map, Keys.Name),
         value = BigDecimal(get(map, Keys.Value)))
  }

  private def get(map: Map[String, String], field: String): String = {
    map.get(field).getOrElse {
      sys.error("Map is missing key[%s]: %s".format(field, map.toString))
    }
  }

}

case class Metric(guid: UUID, timestamp: Date, name: String, value: BigDecimal) {

  def toMap: Map[String, String] = {
    Map(Metric.Keys.Guid -> guid.toString,
        Metric.Keys.Timestamp -> timestamp.getTime.toString,
        Metric.Keys.Name -> name,
        Metric.Keys.Value -> value.toString)
  }

}

