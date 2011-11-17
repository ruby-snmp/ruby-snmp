#
# Copyright (c) 2004 David R. Halliday
# All rights reserved.
#
# This SNMP library is free software.  Redistribution is permitted under the
# same terms and conditions as the standard Ruby distribution.  See the
# COPYING file in the Ruby distribution for details.
#

module SNMP

  ##
  # Helper class for processing options Hash.
  #
  class Options #:nodoc:

    class << self
      attr_reader :alternates

      def option(symbol, alternate, defaulter=nil)
        @alternates ||= {}
        @alternates[symbol] = alternate
        define_method(symbol) do
          alternate_symbol = self.class.alternates[symbol]
          option_value = @config[symbol] || @config[alternate_symbol] ||
            (defaulter.kind_of?(Proc) ? defaulter.call(self) : defaulter)
          @applied_config[symbol] = @applied_config[alternate_symbol] = option_value
        end
      end

      def default_modules
        ["SNMPv2-SMI", "SNMPv2-MIB", "IF-MIB", "IP-MIB", "TCP-MIB", "UDP-MIB"]
      end

      def choose_transport(klass, config)
        address_family = config.use_IPv6 ? Socket::AF_INET6 : Socket::AF_INET
        klass.new(address_family)
      end

      def ipv6_address?(config)
        hostname = config.host.to_s
        hostname.include?("::") || hostname.split(":").size == 8
      end
    end

    attr_reader :applied_config

    def initialize(config)
      @config = validate_keys(config)
      @applied_config = {}
    end

    def validate_keys(config)
      valid_symbols = self.class.alternates.keys + self.class.alternates.values
      config.each_key { |k| raise "Invalid option: #{k}" unless valid_symbols.include? k }
      config
    end

    def socket_address_family
      use_IPv6 ? Socket::AF_INET6 : Socket::AF_INET
    end
  end

end
