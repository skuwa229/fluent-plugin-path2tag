# fluent-plugin-path2tag

## Overview
A fluent output filter plugin for Nginx's logging.  
Convert uri to tag. And reformat json data.

## Installation
```
# for system installed fluentd
$ gem install fluent-plugin-path2tag

# for td-agent (Legacy)
$ sudo /usr/lib64/fluent/ruby/bin/fluent-gem install ffluent-plugin-path2tag -v 1.0.2

# for td-agent2 (with fluentd v0.12)
$ sudo td-agent-gem install fluent-plugin-path2tag -v 1.0.2
```

## Configuration

### Syntax
```
path2tag <path_key_name> <data_key_name>
```

### Usage
```
<source>
  @type tail
  format ltsv
  tag nginx.access
  path /var/log/nginx/access.log
  pos_file /var/log/td-agent/buffer/access.log.pos
</source>

<match nginx.access>
    @type path2tag
    path2tag request_uri request_body
</match>
```

## License

Copyright (c) 2017- Shota Kuwahara  
[MIT License](http://opensource.org/licenses/MIT)

