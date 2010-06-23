package meetupnow;

import javax.jdo.JDOHelper;
import javax.jdo.PersistenceManagerFactory;
import org.compass.core.Compass;
import org.compass.gps.CompassGps;
import org.compass.gps.CompassGpsDevice;
import org.compass.gps.CompassGpsException;
import org.compass.core.config.CompassEnvironment;
import org.compass.core.xml.jdom.*;
import org.compass.gps.impl.SingleCompassGps;
import org.compass.gps.device.jdo.Jdo2GpsDevice;
import org.compass.core.config.CompassConfiguration;


public final class PMF {
	private static final PersistenceManagerFactory pmfInstance =
 		JDOHelper.getPersistenceManagerFactory("transactions-optional");

	private PMF() {}

	private static final Compass compass;
	private static final CompassGps compassGps;

	static {
		compass = new CompassConfiguration().setConnection("gae://index").setSetting(CompassEnvironment.ExecutorManager.EXECUTOR_MANAGER_TYPE, "disabled").addScan("meetupnow").buildCompass();

		compassGps = new SingleCompassGps(compass);
		compassGps.addGpsDevice(new Jdo2GpsDevice("appengine", pmfInstance));
		compassGps.start();

		compassGps.index();
	}


	public static PersistenceManagerFactory get() {
		return pmfInstance;
	}

	public static Compass getCompass(){
		return compass;
	}


}
