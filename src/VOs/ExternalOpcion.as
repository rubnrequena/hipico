/**
 * Created by Ruben on 26-03-2014.
 */
package VOs {
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

public class ExternalOpcion {
    public static var externalFile:File = File.applicationStorageDirectory.resolvePath("extOpt.cfg");
	
    public var dividendo:Boolean=false;
	public var randomID:Boolean=false;
	public var randomSeed:int=99999;
	
    public function ExternalOpcion() {
    }

    public function save():void {
        var fs:FileStream = new FileStream();
        fs.open(ExternalOpcion.externalFile,FileMode.WRITE);
        fs.writeObject(this);
        fs.close();
    }
}
}
