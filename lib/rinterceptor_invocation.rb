class RinterceptorInvocation
  attr_accessor :object, :method, :args, :options
  def initialize(object, method, *args)
    @object = object
    @method = method
    @args = args
    @options = {}
  end
  def invoke(*args)
    unless @options.nil? || @options.empty?
      @args = @args + [@options]
      @options = nil
    end
    @object.send("old4rinter_#{@method}".to_sym, *(args.empty? ? @args : args))
  end
end
