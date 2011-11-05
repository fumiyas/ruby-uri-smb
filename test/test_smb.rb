require 'test/unit'
require 'uri/smb'

module URI

class SMBTest < Test::Unit::TestCase
  def setup
  end

  def teardown
  end

  def uri_to_ary(uri)
    uri.class.component.collect {|c| uri.send(c)}
  end

  def test_parse
    uri = 'smb://example.jp/share/path'
    u = URI.parse(uri)
    assert_kind_of(URI::SMB, u)
    assert_equal(uri, u.to_s)
    assert_equal('smb', u.scheme)
    assert_equal('example.jp', u.host)
    assert_equal('/share/path', u.path)

    uri = 'smb://domain;user:pass@example.jp/share/path'
    u = URI.parse(uri)
    assert_equal('domain;user:pass', u.userinfo)

    uris = {
      'smb://server' =>
      ['smb', nil, 'server', URI::SMB::DEFAULT_PORT,
       '', '',
       nil, nil, nil, nil,
       nil, nil, nil],
      'smb://server/share/path' =>
      ['smb', nil, 'server', URI::SMB::DEFAULT_PORT,
       'share', '/share/path',
       nil, nil, nil, nil,
       nil, nil, nil],
      'smb://server/share?nbns=10.0.0.1&workgroup=DOMAIN' =>
      ['smb', nil, 'server', URI::SMB::DEFAULT_PORT,
       'share', '/share',
       '10.0.0.1', 'DOMAIN', nil, nil,
       nil, nil, nil],
      'smb://server/share?wins=10.0.0.1&ntdomain=DOMAIN' =>
      ['smb', nil, 'server', URI::SMB::DEFAULT_PORT,
       'share', '/share',
       '10.0.0.1', 'DOMAIN', nil, nil,
       nil, nil, nil],
      'smb://server/share/path?calling=src&called=dst' =>
      ['smb', nil, 'server', URI::SMB::DEFAULT_PORT,
       'share', '/share/path',
       nil, nil, 'src', 'dst',
       nil, nil, nil],
      'smb://server/share/path?broadcast=10.255.255.255&nodetype=P&scopeid=foo' =>
      ['smb', nil, 'server', URI::SMB::DEFAULT_PORT,
       'share', '/share/path',
       nil, nil, nil, nil,
       '10.255.255.255', 'P', 'foo'],
    }.each do |uri, ary|
      u = URI.parse(uri)
      assert_equal(ary, uri_to_ary(u))
    end

    assert_raise(URI::InvalidURIError) do
      URI.parse('smb://foo_bar/share/path')
    end
  end

  def test_parse_netbioshostname
    uri = 'smb://foo_bar/share/path'
    u = URI::SMB.parse(uri)
    assert_kind_of(URI::SMB, u)
    assert_equal(uri, u.to_s)
    assert_equal('smb', u.scheme)
    assert_equal('foo_bar', u.host)
    assert_equal('/share/path', u.path)

    assert_nothing_raised(URI::InvalidURIError) do
      URI::SMB.parse('smb://foo_barxxxxxxxx/share/path')
    end
    assert_raise(URI::InvalidURIError) do
      URI::SMB.parse('smb://foo_barxxxxxxxxx/share/path')
    end
  end

  def test_modify
    uri = 'smb://example.jp/share/path'
    u = URI.parse(uri)

    share = 'foo'
    uri.sub!(/share/, share)
    u.share = share
    assert_equal(uri, u.to_s)
    assert_equal(share, u.share)
    assert_raise(URI::InvalidURIError) do
      u.share = 'invalid/name'
    end

    nbns = '10.0.0.1'
    uri += "?nbns=#{nbns}"
    u.nbns = nbns
    assert_equal(uri, u.to_s)
    assert_equal(nbns, u.nbns)
    assert_raise(URI::InvalidURIError) do
      u.nbns = 'invalid value'
    end

    workgroup = 'domain'
    uri += "&workgroup=#{workgroup}"
    u.workgroup = workgroup
    assert_equal(uri, u.to_s)
    assert_equal(workgroup, u.workgroup)
    assert_raise(URI::InvalidURIError) do
      u.workgroup = 'invalid value'
    end

    calling = 'source'
    uri += "&calling=#{calling}"
    u.calling = calling
    assert_equal(uri, u.to_s)
    assert_equal(calling, u.calling)
    assert_raise(URI::InvalidURIError) do
      u.called = 'invalid value'
    end

    called = 'source'
    uri += "&called=#{called}"
    u.called = called
    assert_equal(uri, u.to_s)
    assert_equal(called, u.called)
    assert_raise(URI::InvalidURIError) do
      u.called = 'invalid value'
    end

    broadcast = '10.255.255.255'
    uri += "&broadcast=#{broadcast}"
    u.broadcast = broadcast
    assert_equal(uri, u.to_s)
    assert_equal(broadcast, u.broadcast)
    ## FIXME
    #assert_raise(URI::InvalidURIError) do
    #  u.broadcast = 'invalid value'
    #end

    nodetype = 'p'
    uri += "&nodetype=#{nodetype}"
    u.nodetype = nodetype
    assert_equal(uri, u.to_s)
    assert_equal(nodetype, u.nodetype)
    assert_raise(URI::InvalidURIError) do
      u.nodetype = 'invalid value'
    end

    scopeid = 'scope'
    uri += "&scopeid=#{scopeid}"
    u.scopeid = scopeid
    assert_equal(uri, u.to_s)
    assert_equal(scopeid, u.scopeid)
    ## FIXME
    #assert_raise(URI::InvalidURIError) do
    #  u.scopeid = 'invalid value'
    #end
  end
end

end

