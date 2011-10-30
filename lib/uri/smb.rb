## Ruby: URI::SMB class
##
## Author:: SATOH Fumiyasu
## Copyright:: (c) 2007-2011 SATOH Fumiyasu @ OSS Technology, Corp.
## License:: You can redistribute it and/or modify it under the same term as Ruby.
## Date:: 2011-10-28, since 2007-07-06

require 'uri'
require 'cgi'

module URI

  ## SMB URI class. See also: Implementing CIFS - Appendix D: The SMB URL:
  ## http://ubiqx.org/cifs/Appendix-D.html
  class SMB < Generic
    ## A default port of 445 for URI::SMB
    DEFAULT_PORT = 445
    ## An Array of the available components for URI::SMB
    COMPONENT = [
      :scheme,
      :userinfo, :host, :port,
      :share, :path,
      :nbns, :workgroup, :calling, :called,
      :broadcast, :nodetype, :scopeid,
    ].freeze

    NODETYPE = [
      NODETYPE_BROADCAST =      'b',
      NODETYPE_P2P =            'p',
      NODETYPE_MIXED =          'm',
      NODETYPE_HYBRID =         'h',
    ].freeze

    URI::REGEXP::PATTERN.const_set(
      :NETBIOSHOSTNAME,
      '[a-zA-Z\d_][a-zA-Z\d_\-]{1,14}'
    )
    URI.const_set(
      :NETBIOSHOSTNAME,
      Regexp.new("^#{URI::REGEXP::PATTERN::NETBIOSHOSTNAME}$")
    )
    URI::REGEXP::PATTERN.const_set(
      :SMBHOSTNAME,
      "#{URI::REGEXP::PATTERN::HOSTNAME}|#{URI::REGEXP::PATTERN::NETBIOSHOSTNAME}"
    )
    URI.const_set(
      :SMBHOSTNAME,
      Regexp.new("^#{URI::REGEXP::PATTERN::SMBHOSTNAME}$")
    )

    DEFAULT_PARSER = URI::Parser.new(:HOSTNAME=>URI::REGEXP::PATTERN::SMBHOSTNAME)

    def self.parse(uri)
      DEFAULT_PARSER.parse(uri)
    end

    def initialize(scheme,
                   userinfo, host, port, registry,
                   path, opaque,
                   query,
                   fragment,
		   parser = DEFAULT_PARSER,
                   arg_check = false)
      super(scheme,
        userinfo, host, port, registry,
        path, opaque,
        query,
        fragment,
        parser,
        arg_check)

      if @fragment
        raise InvalidURIError, 'bad SMB URI'
      end

      parse_path
      parse_query
    end

    def parse_path
      @share = @path ? @path.match(%r#/([^/]+)#) ? $1 : nil : nil;
    end
    private :parse_path

    def build_path
      if @share
        @path = '/' + @share + @path.sub(%r#^/[^/]*#, '')
      else
        @path = ''
      end
    end
    private :build_path

    def parse_query
      params = {}
      if @query
        @query.split(/[&;]/).each do |param|
          next if param.empty?
          name, value = param.split('=', 2)
          params[name] = value ? value : nil
        end
      end

      @nbns = params.delete('nbns') || params.delete('wins')
      @workgroup = params.delete('workgroup') || params.delete('ntdomain')
      @calling = params.delete('calling')
      @called = params.delete('called')
      @broadcast = params.delete('broadcast')
      @nodetype = params.delete('nodetype')
      @scopeid = params.delete('scopeid')

      unless params.empty?
        raise InvalidURIError,
              "bad query parameter(s) in SMB URI: #{params.keys.join(',')}"
      end
      build_query
    end
    private :parse_query

    def build_query
      params = []
      params << 'nbns=' + @nbns if @nbns && @nbns.size > 0
      params << 'workgroup=' + @workgroup if @workgroup && @workgroup.size > 0
      params << 'calling=' + @calling if @calling && @calling.size > 0
      params << 'called=' + @called if @called && @called.size > 0
      params << 'broadcast=' + @broadcast if @broadcast && @broadcast.size > 0
      params << 'nodetype=' + @nodetype if @nodetype && @nodetype.size > 0
      params << 'scopeid=' + @scopeid if @scopeid && @scopeid.size > 0

      @query = !params.empty? ? params.join('&') : nil
    end
    private :build_query

    def share
      return @share ? @share : ''
    end

    def check_share(v)
      check_path('/' + v)
      if v && v.include?('/')
        raise InvalidURIError,
              "bad share conponent ('/' not allowed): #{v}"
      end
    end
    private :check_share

    def set_share(v)
      @share = v
      build_path
      return @share
    end
    protected :set_share

    def share=(v)
      check_share(v)
      set_share(v)
    end

    ## returns the NetBIOS name server (WINS) address.
    def nbns
      return @nbns
    end
    alias :wins :nbns

    def check_nbns(v)
      if v && v!='' && self.parser.regexp[:HOST] !~ v
        raise InvalidURIError,
              "bad NetBIOS name server (WINS) address: #{v}"
      end
    end
    private :check_nbns

    def set_nbns(v)
      @nbns = v
      build_query
      return @nbns
    end
    protected :set_nbns

    def nbns=(v)
      check_nbns(v)
      set_nbns(v)
    end

    ## returns the workgroup (or NT domain) name.
    def workgroup
      return @workgroup
    end
    alias :ntdomain :workgroup

    def check_workgroup(v)
      if v && v!='' && self.parser.regexp[:HOST] !~ v
        raise InvalidURIError,
              "bad NetBIOS workgroup (or NT domain) name: #{v}"
      end
    end
    private :check_workgroup

    def set_workgroup(v)
      @workgroup = v
      build_query
      return @workgroup
    end
    protected :set_workgroup

    def workgroup=(v)
      check_workgroup(v)
      set_workgroup(v)
    end

    ## returns the NetBIOS source name or address.
    def calling
      return @calling
    end

    def check_calling(v)
      if v && v!='' && self.parser.regexp[:HOST] !~ v
        raise InvalidURIError,
              "bad NetBIOS calling (source) name: #{v}"
      end
    end
    private :check_calling

    def set_calling(v)
      @calling = v
      build_query
      return @calling
    end
    protected :set_calling

    def calling=(v)
      check_calling(v)
      set_calling(v)
    end

    ## returns the NetBIOS destination name or address.
    def called
      return @called
    end

    def check_called(v)
      if v && v!='' && self.parser.regexp[:HOST] !~ v
        raise InvalidURIError,
              "bad NetBIOS called (destination) name: #{v}"
      end
    end
    private :check_called

    def set_called(v)
      @called = v
      build_query
      return @called
    end
    protected :set_called

    def called=(v)
      check_called(v)
      set_called(v)
    end

    ## returns the broadcast address.
    def broadcast
      return @broadcast
    end

    def check_broadcast(v)
      ## FIXME
    end
    private :check_broadcast

    def set_broadcast(v)
      @broadcast = v
      build_query
      return @broadcast
    end
    protected :set_broadcast

    def broadcast=(v)
      check_broadcast(v)
      set_broadcast(v)
    end

    ## returns the NetBIOS node type.
    def nodetype
      return @nodetype
    end

    def check_nodetype(v)
      if v && v!='' && !NODETYPE.include?(v.downcase)
        raise InvalidURIError,
              "bad nodetype in SMB URI: #{v}"
      end
    end
    private :check_nodetype

    def set_nodetype(v)
      @nodetype = v
      build_query
      return @nodetype
    end
    protected :set_nodetype

    def nodetype=(v)
      check_nodetype(v)
      set_nodetype(v)
    end

    ## returns the NetBIOS scope ID.
    def scopeid
      return @scopeid
    end

    def check_scopeid(v)
      ## FIXME
    end
    private :check_scopeid

    def set_scopeid(v)
      @scopeid = v
      build_query
      return @scopeid
    end
    protected :set_scopeid

    def scopeid=(v)
      check_scopeid(v)
      set_scopeid(v)
    end
  end

  @@schemes['SMB'] = SMB
end

