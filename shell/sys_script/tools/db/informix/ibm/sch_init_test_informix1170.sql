DATABASE sysadmin;

EXECUTE FUNCTION task("create dbspace", "physdbs", "/home/informix/test_informix1170/dbspaces/plogdbs", 50176, 0);


EXECUTE FUNCTION task("create dbspace", "logdbs", "/home/informix/test_informix1170/dbspaces/llogdbs", 61440, 0);


EXECUTE FUNCTION task("create dbspace", "datadbs", "/home/informix/test_informix1170/dbspaces/datadbs", 51200, 0);


EXECUTE FUNCTION task("create sbspace", "sbspace", "/home/informix/test_informix1170/dbspaces/sbspace", 32768, 0);


EXECUTE FUNCTION task("create tempdbspace", "tempdbs", "/home/informix/test_informix1170/dbspaces/tempdbs", 51200, 0);

close DATABASE;


DATABASE sysadmin;

EXECUTE FUNCTION task("alter plog", "physdbs", "49152");



EXECUTE FUNCTION task("add log", "logdbs", "9216", "6");

EXECUTE FUNCTION task("onmode", "l");

EXECUTE FUNCTION task("onmode", "l");

EXECUTE FUNCTION task("onmode", "l");

EXECUTE FUNCTION task("onmode", "l");

EXECUTE FUNCTION task("onmode", "l");

EXECUTE FUNCTION task("onmode", "l");
EXECUTE FUNCTION task("onmode", "c");
EXECUTE FUNCTION task("drop log", "1");
EXECUTE FUNCTION task("drop log", "2");
EXECUTE FUNCTION task("drop log", "3");
EXECUTE FUNCTION task("drop log", "4");
EXECUTE FUNCTION task("drop log", "5");
EXECUTE FUNCTION task("drop log", "6");

close DATABASE;


