# Change Log

## Changes for version 1.3.3:
* Move web content to GitHub Pages https://github.com/ruby-snmp/ruby-snmp/pull/66
* Modernize project structure: README, gemspec, Rakefile, and development dependencies https://github.com/ruby-snmp/ruby-snmp/pull/65
  * This change includes: Ship license file in gem. https://github.com/ruby-snmp/ruby-snmp/pull/65
* Migrate from Travis CI to GitHub Actions https://github.com/ruby-snmp/ruby-snmp/pull/64
* Transfer repository from `hallidave/ruby-snmp` to `ruby-snmp/ruby-snmp` https://github.com/ruby-snmp/ruby-snmp/pull/63
* Allow MIB dir to be specified when loading additional modules (Fixes: https://github.com/ruby-snmp/ruby-snmp/issues/55 )
* Name lookup hash values were set to nil when overwriting (Fixes: https://github.com/ruby-snmp/ruby-snmp/issues/54 )

## Changes for version 1.3.2:
* Accept non-standard error status codes

## Changes for version 1.3.1:
* Cleaned up deprecation warnings
* Fixed SNMP::Integer#<=> method for Ruby 2.3.0 and later
* Removed artificial limit on number of non-repeaters for GetBulkRequest
* SNMP::BER module no longer pollutes global namespace

## Changes for version 1.2.0:
* Removed support for Ruby 1.8
* Changed license to MIT License

## Changes for version 1.1.1:

* Incorporate various small pull requests

## Changes for version 1.1.0:

* Added MIB support to ObjectId and Varbind, so that to_s can return symbolic information
* Added to_str method to ObjectId to return a numeric OID string (old to_s behavior)
* TrapListener can now support multiple community strings

## Changes for version 1.0.4:

* New option handling and added lower-case versions of all options
* Added SNMP::VERSION constant
* Experimental support for IPv6
* Removed support for installation with setup.rb

## Changes for version 1.0.3:

* Minor changes to Manager class.  The :Transport option may now be an
  object or a class.  Explicity call Timeout.timeout so that a timeout
  method may be defined in subclasses.  Thanks to Eric Monti.

## Changes for version 1.0.2:

* Internal code changes to make this library compatible with both Ruby 1.8
  and Ruby 1.9.  Note that an ord() method is now added to the Fixnum class
  for Ruby 1.8.  See the ber.rb file for details.

## Changes for version 1.0.1:

* Made the host configurable for the TrapListener.  Previously defaulted
  to 'localhost'.

## Changes for version 1.0.0:

* Added to_s method to TimeTicks.  Displays time in human-readable form
  instead of just a number.  The to_i method can still be used to get the
  number of ticks.
