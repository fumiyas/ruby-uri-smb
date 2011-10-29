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

    URI::REGEXP::PATTERN.const_set(
      :NETBIOSHOSTNAME,
      '[a-zA-Z\d_][a-zA-Z\d_\-]{1,14}'
    )
    URI.const_set(
      :NETBIOSHOSTNAME,
      Regexp.new(URI::REGEXP::PATTERN::NETBIOSHOSTNAME)
    )
    URI::REGEXP::PATTERN.const_set(
      :SMBHOSTNAME,
      "#{URI::REGEXP::PATTERN::HOSTNAME}|#{URI::REGEXP::PATTERN::NETBIOSHOSTNAME}"
    )
    URI.const_set(
      :SMBHOSTNAME,
      Regexp.new(URI::REGEXP::PATTERN::SMBHOSTNAME)
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

    def set_share(v)
      @share = v
      build_path
      return @share
    end
    protected :set_share

    def nbns
      return @nbns
    end
    alias :wins :nbns

    def set_nbns(v)
      @nbns = v
      build_query
      return @nbns
    end
    protected :set_nbns

    def workgroup
      return @workgroup
    end
    alias :ntdoain :workgroup

    def set_workgroup(v)
      @workgroup = v
      build_query
      return @workgroup
    end
    protected :set_workgroup

    def calling
      return @calling
    end

    def set_calling(v)
      @calling = v
      build_query
      return @calling
    end
    protected :set_calling

    def called
      return @called
    end

    def set_called(v)
      @called = v
      build_query
      return @called
    end
    protected :set_called

    def broadcast
      return @broadcast
    end

    def set_broadcast(v)
      @broadcast = v
      build_query
      return @broadcast
    end
    protected :set_broadcast

    def nodetype
      return @nodetype
    end

    def set_nodetype(v)
      @nodetype = v
      build_query
      return @nodetype
    end
    protected :set_nodetype

    def scopeid
      return @scopeid
    end

    def set_scopeid(v)
      @scopeid = v
      build_query
      return @scopeid
    end
    protected :set_scopeid
  end

  @@schemes['SMB'] = SMB
end

