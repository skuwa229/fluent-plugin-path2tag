class Fluent::Path2tagOutput < Fluent::Output
  Fluent::Plugin.register_output('path2tag', self)

  # Define `router` method of v0.12 to support v0.10 or earlier
  unless method_defined?(:router)
    define_method("router") { Fluent::Engine }
  end

  def configure(conf)
    super

    @rewriterules = []
    conf.keys.select{|k| k =~ /^path2tag$/}.each do |key|
      path_key, data_key = conf[key].split(" ")
      if path_key.nil? || data_key.nil?
        raise Fluent::ConfigError, "[path2tag] failed to parse path2tag at #{key} #{conf[key]}"
      end

      @rewriterules.push([path_key, data_key])
      log.info "[path2tag] adding path2tag rule: #{key} #{@rewriterules.last}"
    end

    unless @rewriterules.length > 0
      raise Fluent::ConfigError, "[path2tag] missing path2tag rule"
    end
  end

  def emit(tag, es, chain)
    es.each do |time,record|
      rewrited_tag, newrecords = rewrite_tag_record(tag, record)
      next if newrecords.nil? || tag == rewrited_tag
      
      log.info "[path2tag] change tag to #{rewrited_tag}"
      
      if newrecords.kind_of?(Array)
        newrecords.each do |r|
          router.emit(rewrited_tag, time, r)
        end
      else
        router.emit(rewrited_tag, time, newrecords)
      end
    end

    chain.next
  end

  def parse(str = '')
    array = str.scan(/(?:\\x..)+/).uniq.sort{ |a, b| b.length <=> a.length }
    array.each do |reg|
      s = [reg.gsub('\\x', 'x').split('x').slice(1..-1).join('')].pack('H*').force_encoding('utf-8')
      str = str.gsub(reg, s)
    end
    return JSON.parse(str)
  end

  def rewrite_tag_record(tag, record)
    path_key, data_key = @rewriterules[0]
    
    unless record.has_key?(path_key)
      log.warn "[path2tag] record has no path_key <#{path_key}>"
      return tag, nil
    end

    unless record.has_key?(data_key)
      log.warn "[path2tag] record has no data_key <#{data_key}>"
      return tag, nil
    end

    if record[data_key].empty?
      log.warn "[path2tag] record is empty <#{data_key}>"
      return tag, nil
    end

    begin
      newrecords = parse(record[data_key])
    rescue => e
      log.warn "[path2tag] JSON parse error!"
      return tag, nil
    end

    newtag = record[path_key]
    if newtag.start_with?("/")
      newtag = newtag.sub("/", "")
    end

    if newtag.end_with?("/")
      newtag = newtag.chop
    end
    newtag = newtag.gsub("/", ".")
    
    return newtag, newrecords
  end
end
