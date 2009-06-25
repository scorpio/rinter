module RinterceptorHelper
  def self.match_method?(method, includes, excludes)
    excludes.each {|i| return false if method =~ i}
    real_includes = includes.is_a?(Array) ? includes : []
    if includes.is_a?(Hash)
      includes.each{|k, v| real_includes += v}
    end
    real_includes.each {|i| return true if method =~ i}
    false
  end
  def self.process_include_methods(methods)
    if methods.is_a?(Hash)
      methods.each do |k, v|
        if v.is_a?(String) || v.is_a?(Symbol)
          v = Regexp.new("^#{v}$")
        elsif v.is_a?(Array)
          v.each_index{|i| v[i] = Regexp.new("^#{v[i]}$") if v[i].is_a?(String) || v[i].is_a?(Symbol)}
        end
        v = [v] if v.is_a?(Regexp)
        methods[k] = v
      end
    end
    methods
  end
end