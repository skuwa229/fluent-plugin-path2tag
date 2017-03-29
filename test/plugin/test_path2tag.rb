require 'helper'

class Path2tagTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG_OK = %[
    path2tag request_uri request_body
  ]

  CONFIG_NO_RULE = %[
  ]

  CONFIG_INVALID_RULE = %[
    path2tag request_uri
  ]

  CONFIG_NOT_START_WITH_PATH2TAG = %[
    path_to_tag request_uri request_body
  ]

  CONFIG_NO_PATH_KEY = %[
    path2tag uri request_body
  ]

  CONFIG_NO_DATA_KEY = %[
    path2tag request_uri body
  ]

  def create_driver(conf=CONFIG_OK,tag='test')
    Fluent::Test::OutputTestDriver.new(Fluent::Path2tagOutput, tag).configure(conf)
  end

  def test_configure
    assert_raise(Fluent::ConfigError) {
      create_driver(CONFIG_NO_RULE)
    }
    assert_raise(Fluent::ConfigError) {
      create_driver(CONFIG_INVALID_RULE)
    }
    assert_raise(Fluent::ConfigError) {
      create_driver(CONFIG_NOT_START_WITH_PATH2TAG)
    }
    d = create_driver %[
      path2tag URL BODY
    ]
    assert_equal 'URL BODY', d.instance.config['path2tag']
  end

  def test_emit_ok
    d1 = create_driver(CONFIG_OK, 'nginx.access')
    body = '[{"fluentd_time":"2017-02-20 10:39:14 UTC","unique_id":"123ABC","device_token":"ABC123"}]'
    d1.run do
      d1.emit({'request_uri' => '/path/foo/bar', 'request_body' => body})
    end
    emits = d1.emits
    assert_equal 1, emits.length
    assert_equal 'path.foo.bar', emits[0][0]
    assert_equal JSON.parse(body), emits[0][2]
  end

  def test_emit_no_path_key
    d1 = create_driver(CONFIG_NO_PATH_KEY, 'nginx.access')
    body = '[{"fluentd_time":"2017-02-20 10:39:14 UTC","unique_id":"123ABC","device_token":"ABC123"}]'
    d1.run do
      d1.emit({'request_uri' => '/path/foo/bar', 'request_body' => body})
    end
    emits = d1.emits
    assert_equal 0, emits.length
  end

  def test_emit_no_data_key
    d1 = create_driver(CONFIG_NO_DATA_KEY, 'nginx.access')
    body = '[{"fluentd_time":"2017-02-20 10:39:14 UTC","unique_id":"123ABC","device_token":"ABC123"}]'
    d1.run do
      d1.emit({'request_uri' => '/path/foo/bar', 'request_body' => body})
    end
    emits = d1.emits
    assert_equal 0, emits.length
  end

  def test_emit_path_format_1
    d1 = create_driver(CONFIG_OK, 'nginx.access')
    body = '[{"fluentd_time":"2017-02-20 10:39:14 UTC","unique_id":"123ABC","device_token":"ABC123"}]'
    d1.run do
       d1.emit({'request_uri' => '/path/foo/bar', 'request_body' => body})
    end
    emits = d1.emits
    assert_equal 1, emits.length
    assert_equal 'path.foo.bar', emits[0][0]
    assert_equal JSON.parse(body), emits[0][2]
  end

  def test_emit_path_format_2
    d1 = create_driver(CONFIG_OK, 'nginx.access')
    body = '[{"fluentd_time":"2017-02-20 10:39:14 UTC","unique_id":"123ABC","device_token":"ABC123"}]'
    d1.run do
       d1.emit({'request_uri' => 'path/foo/bar', 'request_body' => body})
    end
    emits = d1.emits
    assert_equal 1, emits.length
    assert_equal 'path.foo.bar', emits[0][0]
    assert_equal JSON.parse(body), emits[0][2]
  end

  def test_emit_path_format_3
    d1 = create_driver(CONFIG_OK, 'nginx.access')
    body = '[{"fluentd_time":"2017-02-20 10:39:14 UTC","unique_id":"123ABC","device_token":"ABC123"}]'
    d1.run do
       d1.emit({'request_uri' => '/path/foo/bar/', 'request_body' => body})
    end
    emits = d1.emits
    assert_equal 1, emits.length
    assert_equal 'path.foo.bar', emits[0][0]
    assert_equal JSON.parse(body), emits[0][2]
  end

  def test_emit_path_format_4
    d1 = create_driver(CONFIG_OK, 'nginx.access')
    body = '[{"fluentd_time":"2017-02-20 10:39:14 UTC","unique_id":"123ABC","device_token":"ABC123"}]'
    d1.run do
       d1.emit({'request_uri' => 'path', 'request_body' => body})
    end
    emits = d1.emits
    assert_equal 1, emits.length
    assert_equal 'path', emits[0][0]
    assert_equal JSON.parse(body), emits[0][2]
  end
  
  def test_emit_json_parse
    d1 = create_driver(CONFIG_OK, 'nginx.access')
    body = '{"fluentd_time":"2017-02-20 10:39:14 UTC","unique_id":"123ABC","device_token":"ABC123"}'
    d1.run do
       d1.emit({'request_uri' => 'path/foo/bar', 'request_body' => body})
    end
    emits = d1.emits
    assert_equal 1, emits.length
    assert_equal 'path.foo.bar', emits[0][0]
    assert_equal JSON.parse(body), emits[0][2]
  end
  
  def test_emit_json_parse_2
    d1 = create_driver(CONFIG_OK, 'nginx.access')
    body = '-'
    d1.run do
       d1.emit({'request_uri' => 'path/foo/bar', 'request_body' => body})
    end
    emits = d1.emits
    assert_equal 0, emits.length
  end


end

