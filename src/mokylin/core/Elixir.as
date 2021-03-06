package mokylin.core
{
  /**
   * This class contains global information about ILOG Elixir applications.
   */
  public final class Elixir
  {    
    /**
     * The major version of the ILOG Elixir release.
     */
    public static const VERSION_MAJOR:int = 1; // NEVER CHANGE THIS VALUE
    
    /**
     * The minor version of the ILOG Elixir release.
     */
    public static const VERSION_MINOR:int = 0; // NEVER CHANGE THIS VALUE
    
    /**
     * The service version of ILOG Elixir. This corresponds to an in-between-two-releases version.
     */
    public static const VERSION_SERVICE:int = 0; // NEVER CHANGE THIS VALUE
    
    /**
     * The ILOG Elixir version qualifier. This corresponds to the library build number.
     */
    public static const VERSION_QUALIFIER:String = "1789"; // NEVER CHANGE THIS VALUE
    
    /**
     * A <code>String</code> representing the ILOG Elixir version.
     */
    public static function get VERSION():String 
	{
      return VERSION_MAJOR+"."+VERSION_MINOR+"."+VERSION_SERVICE+"."+VERSION_QUALIFIER;
    }
  }
}
