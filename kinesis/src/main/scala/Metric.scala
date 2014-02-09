import java.util.{Date, UUID}

object Metric {

  def fromMap(map: Map[String, String]): Metric = {
    Metric(guid = UUID.fromString(get(map, "guid")),
           timestamp = new Date(get(map, "timestamp").toLong),
           name = get(map, "name"),
           value = BigDecimal(get(map, "value")))
  }

  private def get(map: Map[String, String], field: String): String = {
    map.get(field).getOrElse {
      sys.error("Map is missing key[%s]: %s".format(field, map.toString))
    }
  }

}

case class Metric(guid: UUID, timestamp: Date, name: String, value: BigDecimal) {

  def toMap: Map[String, String] = {
    Map("guid" -> guid.toString,
        "timestamp" -> timestamp.getTime.toString,
        "name" -> name,
        "value" -> value.toString)
  }

}
