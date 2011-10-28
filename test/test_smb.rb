require 'test/unit'
require 'uri/smb'

module URI

class TestSMB < Test::Unit::TestCase
  def setup
  end

  def teardown
  end

  def uri_to_ary(uri)
    uri.class.component.collect {|c| uri.send(c)}
  end

  def test_parse
    url = 'smb://example.jp/share/path'
    u = URI.parse(url)
    assert_kind_of(URI::SMB, u)
    assert_equal(url, u.to_s)
    assert_equal('smb', u.scheme)
    assert_equal('example.jp', u.host)
    assert_equal('/share/path', u.path)

    url = 'smb://domain;user:pass@example.jp/share/path'
    u = URI.parse(url)
    assert_equal('domain;user:pass', u.userinfo)

    urls = {
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
       'share', '/share/path',
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
    }.each do |url, ary|
      u = URI.parse(url)
      assert_equal(ary, uri_to_ary(u))
    end
  end
end

end

