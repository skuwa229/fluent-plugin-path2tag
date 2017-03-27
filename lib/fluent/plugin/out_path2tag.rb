class Fluent::Path2tagOutput < Fluent::Output
  Fluent::Plugin.register_output('path2tag', self)

  def configure(conf)
    super

    @rewriterules = []
    conf.keys.select{|k| k =~ /^path2tag$/}.each do |key|
      path_key, data_key = conf[key].split(" ")
      if path_key.nil? || data_key.nil?
        raise Fluent::ConfigError, "failed to parse path2tag at #{key} #{conf[key]}"
      end

      @rewriterules.push([path_key, data_key])
      log.info "adding path2tag rule: #{key} #{@rewriterules.last}"
    end

    unless @rewriterules.length > 0
      raise Fluent::ConfigError, "missing path2tag rule"
    end
  end

  def emit(tag, es, chain)
    es.each do |time,record|
      rewrited_tag, newrecord = rewrite_tag_record(tag, record)
      if newrecord.nil? then
        router.emit(rewrited_tag, time, record)
      else
        router.emit(rewrited_tag, time, newrecord)
      end
    end

    chain.next
  end

  def rewrite_tag_record(tag, record)
    path_key, data_key = @rewriterules[0]

    unless record.has_key?(path_key)
      log.warn "record has no path_key <#{path_key}>"
      return "path2tag.clear", nil
    end

    unless record.has_key?(data_key)
      log.warn "record has no data_key <#{data_key}>"
      return "path2tag.clear", nil
    end

    newtag = record[path_key]
    if newtag.start_with?("/")
      newtag = newtag.sub("/", "")
    end
    newtag = newtag.gsub("/", ".")
    return newtag, record[data_key]
  end
end
