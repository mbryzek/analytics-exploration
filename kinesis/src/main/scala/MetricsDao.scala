import com.novus.salat._
import com.novus.salat.global._
import com.novus.salat.annotations._
import com.novus.salat.dao._
import com.mongodb.casbah.Imports._
import com.mongodb.casbah.MongoConnection
import java.util.UUID

/*
 db.metrics.ensureIndex( { guid: 1 }, { unique: true } )
 db.metrics.ensureIndex( { name: 1 } )
 db.metrics.ensureIndex( { timestamp: 1 } )
*/
object MetricsDao extends SalatDAO[Metric, Int](collection = MongoConnection()("analytics-exploration-stream-test-json")("metrics")) {

  def findByGuid(guid: UUID): Option[Metric] = {
    MetricsDao.find(ref = MongoDBObject("guid" -> guid)).toList.headOption
  }

}
